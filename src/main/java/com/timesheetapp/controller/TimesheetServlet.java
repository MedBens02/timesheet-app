package com.timesheetapp.controller;

import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.Timesheet;
import com.timesheetapp.entity.TimesheetEntry;
import com.timesheetapp.entity.User;
import com.timesheetapp.service.TaskService;
import com.timesheetapp.service.TimesheetService;
import com.timesheetapp.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "TimesheetServlet", urlPatterns = {"/timesheet/list", "/timesheet/create", "/timesheet/view", "/timesheet/submit", "/timesheet/validate", "/timesheet/reject"})
public class TimesheetServlet extends HttpServlet {

    private TimesheetService timesheetService;
    private TaskService taskService;

    @Override
    public void init() throws ServletException {
        super.init();
        timesheetService = new TimesheetService();
        taskService = new TaskService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = SessionUtil.getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            switch (path) {
                case "/timesheet/list":
                    showTimesheetList(request, response, currentUser);
                    break;
                case "/timesheet/create":
                    showTimesheetCreate(request, response, currentUser);
                    break;
                case "/timesheet/view":
                    showTimesheetView(request, response, currentUser);
                    break;
                case "/timesheet/validate":
                    showTimesheetsForValidation(request, response, currentUser);
                    break;
                case "/timesheet/submit":
                    submitTimesheet(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = SessionUtil.getCurrentUser(request);

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            switch (path) {
                case "/timesheet/create":
                    saveTimesheet(request, response, currentUser);
                    break;
                case "/timesheet/validate":
                    validateTimesheet(request, response, currentUser);
                    break;
                case "/timesheet/reject":
                    rejectTimesheet(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    private void showTimesheetList(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        List<Timesheet> timesheets = timesheetService.getTimesheetsByUser(currentUser);

        request.setAttribute("timesheets", timesheets);
        request.getRequestDispatcher("/jsp/timesheet/timesheet-list.jsp").forward(request, response);
    }

    private void showTimesheetCreate(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        // Get current week
        LocalDate today = LocalDate.now();
        LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = weekStart.plusDays(6);

        // Check if timesheet already exists for this week
        Optional<Timesheet> timesheetOpt = timesheetService.getTimesheetByUserAndWeek(currentUser, weekStart);
        Timesheet timesheet;

        if (timesheetOpt.isPresent()) {
            timesheet = timesheetOpt.get();
        } else {
            // Create new timesheet
            timesheet = timesheetService.createTimesheet(currentUser, weekStart);
        }

        // Get user's active tasks - filter by EN_COURS status
        List<Task> activeTasks = taskService.getTasksByUser(currentUser).stream()
                .filter(t -> t.getStatus() == Task.TaskStatus.EN_COURS)
                .collect(java.util.stream.Collectors.toList());

        request.setAttribute("timesheet", timesheet);
        request.setAttribute("activeTasks", activeTasks);
        request.setAttribute("weekStart", weekStart);
        request.setAttribute("weekEnd", weekEnd);
        request.getRequestDispatcher("/jsp/timesheet/timesheet-create.jsp").forward(request, response);
    }

    private void showTimesheetView(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/timesheet/list");
            return;
        }

        Long timesheetId = Long.parseLong(idParam);
        Timesheet timesheet = timesheetService.getTimesheetById(timesheetId);

        if (timesheet == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Timesheet not found");
            return;
        }

        // Check permissions - user can view their own or managers can view their team's
        if (!canUserViewTimesheet(currentUser, timesheet)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        request.setAttribute("timesheet", timesheet);
        request.getRequestDispatcher("/jsp/timesheet/timesheet-view.jsp").forward(request, response);
    }

    private void showTimesheetsForValidation(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        // Only managers can validate timesheets
        if (currentUser.getRole() != User.UserRole.PROJECT_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only project managers can validate timesheets");
            return;
        }

        List<Timesheet> timesheets = timesheetService.getTimesheetsForValidation();

        request.setAttribute("timesheets", timesheets);
        request.getRequestDispatcher("/jsp/timesheet/timesheet-validate.jsp").forward(request, response);
    }

    private void saveTimesheet(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        try {
            LocalDate weekStart = LocalDate.parse(request.getParameter("weekStart"));

            // Find or create timesheet
            Optional<Timesheet> timesheetOpt = timesheetService.getTimesheetByUserAndWeek(currentUser, weekStart);
            Timesheet timesheet;
            if (timesheetOpt.isPresent()) {
                timesheet = timesheetOpt.get();
            } else {
                timesheet = timesheetService.createTimesheet(currentUser, weekStart);
            }

            // Process each task entry
            String[] taskIds = request.getParameterValues("taskId[]");
            if (taskIds != null) {
                for (String taskIdStr : taskIds) {
                    Long taskId = Long.parseLong(taskIdStr);
                    Task task = taskService.getTaskById(taskId);

                    if (task != null) {
                        for (int day = 0; day < 7; day++) {
                            String hoursParam = request.getParameter("hours_" + taskId + "_" + day);
                            if (hoursParam != null && !hoursParam.isEmpty()) {
                                int hours = Integer.parseInt(hoursParam);
                                if (hours > 0) {
                                    LocalDate entryDate = weekStart.plusDays(day);

                                    // Add entry using service method
                                    timesheetService.addTimesheetEntry(
                                        timesheet.getId(),
                                        task,
                                        entryDate,
                                        java.math.BigDecimal.valueOf(hours),
                                        null  // description
                                    );
                                }
                            }
                        }
                    }
                }
            }

            SessionUtil.setSuccessMessage(request, "Timesheet saved successfully!");
            response.sendRedirect(request.getContextPath() + "/timesheet/list");

        } catch (Exception e) {
            request.setAttribute("error", "Error saving timesheet: " + e.getMessage());
            showTimesheetCreate(request, response, currentUser);
        }
    }

    private void submitTimesheet(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/timesheet/list");
            return;
        }

        try {
            Long timesheetId = Long.parseLong(idParam);
            Timesheet timesheet = timesheetService.getTimesheetById(timesheetId);

            if (timesheet == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if (!timesheet.getUser().getId().equals(currentUser.getId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            timesheetService.submitTimesheet(timesheetId);

            SessionUtil.setSuccessMessage(request, "Timesheet submitted for validation!");
            response.sendRedirect(request.getContextPath() + "/timesheet/list");

        } catch (Exception e) {
            SessionUtil.setErrorMessage(request, "Error submitting timesheet: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/timesheet/list");
        }
    }

    private void validateTimesheet(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (currentUser.getRole() != User.UserRole.PROJECT_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/timesheet/validate");
            return;
        }

        try {
            Long timesheetId = Long.parseLong(idParam);
            timesheetService.validateTimesheet(timesheetId, currentUser);

            SessionUtil.setSuccessMessage(request, "Timesheet validated successfully!");
            response.sendRedirect(request.getContextPath() + "/timesheet/validate");

        } catch (Exception e) {
            SessionUtil.setErrorMessage(request, "Error validating timesheet: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/timesheet/validate");
        }
    }

    private void rejectTimesheet(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (currentUser.getRole() != User.UserRole.PROJECT_MANAGER) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String idParam = request.getParameter("id");
        String comments = request.getParameter("comments");

        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/timesheet/validate");
            return;
        }

        try {
            Long timesheetId = Long.parseLong(idParam);
            timesheetService.rejectTimesheet(timesheetId, currentUser, comments);

            SessionUtil.setSuccessMessage(request, "Timesheet rejected!");
            response.sendRedirect(request.getContextPath() + "/timesheet/validate");

        } catch (Exception e) {
            SessionUtil.setErrorMessage(request, "Error rejecting timesheet: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/timesheet/validate");
        }
    }

    private boolean canUserViewTimesheet(User user, Timesheet timesheet) {
        // User can view their own timesheet
        if (timesheet.getUser().getId().equals(user.getId())) {
            return true;
        }

        // Managers can view timesheets (simplified - in real app, check if employee is in their team)
        if (user.getRole() == User.UserRole.PROJECT_MANAGER || user.getRole() == User.UserRole.ADMIN) {
            return true;
        }

        return false;
    }
}
