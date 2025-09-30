package com.timesheetapp.controller;

import com.timesheetapp.entity.User;
import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.Timesheet;
import com.timesheetapp.service.ProjectService;
import com.timesheetapp.service.TaskService;
import com.timesheetapp.service.TimesheetService;
import com.timesheetapp.service.UserService;
import com.timesheetapp.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "DashboardServlet", urlPatterns = {
    "/dashboard",
    "/employee/dashboard",
    "/manager/dashboard",
    "/admin/dashboard"
})
public class DashboardServlet extends HttpServlet {

    private ProjectService projectService;
    private TaskService taskService;
    private TimesheetService timesheetService;
    private UserService userService;

    @Override
    public void init() throws ServletException {
        super.init();
        projectService = new ProjectService();
        taskService = new TaskService();
        timesheetService = new TimesheetService();
        userService = new UserService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = SessionUtil.getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        switch (currentUser.getRole()) {
            case ADMIN:
                showAdminDashboard(request, response, currentUser);
                break;
            case PROJECT_MANAGER:
                showManagerDashboard(request, response, currentUser);
                break;
            case EMPLOYEE:
                showEmployeeDashboard(request, response, currentUser);
                break;
            default:
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
        }
    }

    private void showEmployeeDashboard(HttpServletRequest request, HttpServletResponse response,
                                      User user) throws ServletException, IOException {

        // Get user's assigned tasks
        List<Task> myTasks = taskService.getTasksForUserDashboard(user);
        request.setAttribute("myTasks", myTasks);

        // Get overdue tasks
        List<Task> overdueTasks = taskService.getOverdueTasksForUser(user);
        request.setAttribute("overdueTasks", overdueTasks);

        // Get upcoming tasks (next 7 days)
        List<Task> upcomingTasks = taskService.getUpcomingTasksForUser(user, 7);
        request.setAttribute("upcomingTasks", upcomingTasks);

        // Get current week timesheet
        LocalDate currentWeekStart = timesheetService.getCurrentWeekStartDate();
        Timesheet currentTimesheet = timesheetService.getOrCreateTimesheet(user, currentWeekStart);
        request.setAttribute("currentTimesheet", currentTimesheet);

        // Get recent timesheets
        List<Timesheet> recentTimesheets = timesheetService.getTimesheetsByUser(user);
        if (recentTimesheets.size() > 5) {
            recentTimesheets = recentTimesheets.subList(0, 5);
        }
        request.setAttribute("recentTimesheets", recentTimesheets);

        // Statistics
        long totalTasks = myTasks.size();
        long completedTasks = myTasks.stream().filter(Task::isCompleted).count();
        long inProgressTasks = myTasks.stream().filter(Task::isInProgress).count();

        request.setAttribute("totalTasks", totalTasks);
        request.setAttribute("completedTasks", completedTasks);
        request.setAttribute("inProgressTasks", inProgressTasks);
        request.setAttribute("overdueCount", overdueTasks.size());

        request.getRequestDispatcher("/jsp/employee/dashboard.jsp").forward(request, response);
    }

    private void showManagerDashboard(HttpServletRequest request, HttpServletResponse response,
                                     User user) throws ServletException, IOException {

        // Get manager's projects
        List<Project> myProjects = projectService.getProjectsByManager(user);
        request.setAttribute("myProjects", myProjects);

        // Get active projects
        List<Project> activeProjects = myProjects.stream()
            .filter(Project::isActive)
            .toList();
        request.setAttribute("activeProjects", activeProjects);

        // Get all tasks from manager's projects
        List<Task> allTasks = myProjects.stream()
            .flatMap(project -> taskService.getTasksByProject(project).stream())
            .toList();

        // Get tasks requiring attention (overdue, high priority)
        List<Task> overdueTask = allTasks.stream()
            .filter(Task::isOverdue)
            .toList();
        request.setAttribute("overdueTasks", overdueTask);

        List<Task> highPriorityTasks = allTasks.stream()
            .filter(task -> task.isHighPriority() && !task.isCompleted())
            .toList();
        request.setAttribute("highPriorityTasks", highPriorityTasks);

        // Get timesheets for validation
        List<Timesheet> timesheetsForValidation = timesheetService.getTimesheetsForValidation();
        request.setAttribute("timesheetsForValidation", timesheetsForValidation);

        // Get unvalidated projects
        List<Project> unvalidatedProjects = projectService.getUnvalidatedProjects().stream()
            .filter(project -> project.getManager().getId().equals(user.getId()))
            .toList();
        request.setAttribute("unvalidatedProjects", unvalidatedProjects);

        // Statistics
        request.setAttribute("totalProjects", myProjects.size());
        request.setAttribute("activeProjectCount", activeProjects.size());
        request.setAttribute("totalTasks", allTasks.size());
        request.setAttribute("overdueTaskCount", overdueTask.size());
        request.setAttribute("pendingValidations", timesheetsForValidation.size());

        request.getRequestDispatcher("/jsp/manager/dashboard.jsp").forward(request, response);
    }

    private void showAdminDashboard(HttpServletRequest request, HttpServletResponse response,
                                   User user) throws ServletException, IOException {

        // Get all projects
        List<Project> allProjects = projectService.getAllProjects();
        request.setAttribute("allProjects", allProjects);

        // Get all users
        List<User> allUsers = userService.getAllUsers();
        request.setAttribute("allUsers", allUsers);

        // Get active users
        List<User> activeUsers = userService.getActiveUsers();
        request.setAttribute("activeUsers", activeUsers);

        // Get all tasks
        List<Task> allTasks = taskService.getAllTasks();
        request.setAttribute("allTasks", allTasks);

        // Get pending validations
        List<Timesheet> pendingTimesheets = timesheetService.getTimesheetsForValidation();
        request.setAttribute("pendingTimesheets", pendingTimesheets);

        List<Project> unvalidatedProjects = projectService.getUnvalidatedProjects();
        request.setAttribute("unvalidatedProjects", unvalidatedProjects);

        // Get overdue tasks across all projects
        List<Task> overdueTasks = taskService.getOverdueTasks();
        request.setAttribute("overdueTasks", overdueTasks);

        // Get over-budget projects
        List<Project> overBudgetProjects = projectService.getOverBudgetProjects();
        request.setAttribute("overBudgetProjects", overBudgetProjects);

        // Statistics
        long totalUsers = userService.getTotalUserCount();
        long totalProjects = projectService.getTotalProjectCount();
        long totalTasks = taskService.getTotalTaskCount();
        long totalTimesheets = timesheetService.getTotalTimesheetCount();

        long activeProjectCount = allProjects.stream().filter(Project::isActive).count();
        long completedProjectCount = allProjects.stream().filter(Project::isCompleted).count();

        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalProjects", totalProjects);
        request.setAttribute("totalTasks", totalTasks);
        request.setAttribute("totalTimesheets", totalTimesheets);
        request.setAttribute("activeProjectCount", activeProjectCount);
        request.setAttribute("completedProjectCount", completedProjectCount);
        request.setAttribute("overdueTaskCount", overdueTasks.size());
        request.setAttribute("pendingValidationCount", pendingTimesheets.size());

        // User statistics by role
        long adminCount = allUsers.stream().filter(User::isAdmin).count();
        long managerCount = allUsers.stream().filter(User::isProjectManager).count();
        long employeeCount = allUsers.stream().filter(User::isEmployee).count();

        request.setAttribute("adminCount", adminCount);
        request.setAttribute("managerCount", managerCount);
        request.setAttribute("employeeCount", employeeCount);

        request.getRequestDispatcher("/jsp/admin/dashboard.jsp").forward(request, response);
    }
}