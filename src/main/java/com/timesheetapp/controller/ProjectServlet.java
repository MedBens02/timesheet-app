package com.timesheetapp.controller;

import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.User;
import com.timesheetapp.entity.Project.ProjectStatus;
import com.timesheetapp.service.ProjectService;
import com.timesheetapp.service.UserService;
import com.timesheetapp.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ProjectServlet", urlPatterns = {
    "/project/list",
    "/project/create",
    "/project/edit",
    "/project/delete",
    "/project/save",
    "/project/request-validation",
    "/project/validate",
    "/project/reject",
    "/project/assign-employees",
    "/project/save-assignments"
})
public class ProjectServlet extends HttpServlet {

    private final ProjectService projectService = new ProjectService();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = SessionUtil.getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        try {
            switch (path) {
                case "/project/list":
                    showProjectList(request, response, currentUser);
                    break;
                case "/project/create":
                    showCreateForm(request, response, currentUser);
                    break;
                case "/project/edit":
                    showEditForm(request, response, currentUser);
                    break;
                case "/project/delete":
                    deleteProject(request, response, currentUser);
                    break;
                case "/project/request-validation":
                    requestValidation(request, response, currentUser);
                    break;
                case "/project/validate":
                    showValidationForm(request, response, currentUser);
                    break;
                case "/project/reject":
                    rejectProject(request, response, currentUser);
                    break;
                case "/project/assign-employees":
                    showAssignEmployeesForm(request, response, currentUser);
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

        User currentUser = SessionUtil.getCurrentUser(request);
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        try {
            switch (path) {
                case "/project/save":
                    saveProject(request, response, currentUser);
                    break;
                case "/project/validate":
                    validateProject(request, response, currentUser);
                    break;
                case "/project/save-assignments":
                    saveEmployeeAssignments(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    private void showProjectList(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String statusFilter = request.getParameter("status");
        List<Project> projects;

        if (currentUser.getRole() == User.UserRole.ADMIN) {
            // Admin sees all projects
            if (statusFilter != null && !statusFilter.isEmpty()) {
                ProjectStatus status = ProjectStatus.valueOf(statusFilter);
                projects = projectService.findByStatus(status);
            } else {
                projects = projectService.findAll();
            }
        } else if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER) {
            // PM sees only their projects
            projects = projectService.findByManager(currentUser);
            if (statusFilter != null && !statusFilter.isEmpty()) {
                ProjectStatus status = ProjectStatus.valueOf(statusFilter);
                projects = projects.stream()
                    .filter(p -> p.getStatus() == status)
                    .toList();
            }
        } else {
            // Employees see projects they're assigned to
            projects = projectService.findAll().stream()
                .filter(p -> p.getAssignedEmployees() != null &&
                           p.getAssignedEmployees().contains(currentUser))
                .toList();
        }

        request.setAttribute("projects", projects);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("statusFilter", statusFilter);
        request.getRequestDispatcher("/jsp/project/project-list.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        // Only PM and Admin can create projects
        if (currentUser.getRole() != User.UserRole.PROJECT_MANAGER &&
            currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to create projects");
            return;
        }

        // Get list of managers for project assignment (Admin only)
        if (currentUser.getRole() == User.UserRole.ADMIN) {
            List<User> managers = userService.findByRole(User.UserRole.PROJECT_MANAGER);
            request.setAttribute("managers", managers);
        }

        request.setAttribute("currentUser", currentUser);
        request.setAttribute("action", "create");
        request.getRequestDispatcher("/jsp/project/project-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        Long projectId = Long.parseLong(request.getParameter("id"));
        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        // Check permissions
        if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER &&
            !project.getManager().getId().equals(currentUser.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You can only edit your own projects");
            return;
        }

        // Get list of managers for project assignment (Admin only)
        if (currentUser.getRole() == User.UserRole.ADMIN) {
            List<User> managers = userService.findByRole(User.UserRole.PROJECT_MANAGER);
            request.setAttribute("managers", managers);
        }

        request.setAttribute("project", project);
        request.setAttribute("currentUser", currentUser);
        request.setAttribute("action", "edit");
        request.getRequestDispatcher("/jsp/project/project-form.jsp").forward(request, response);
    }

    private void saveProject(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("create".equals(action)) {
                // Create new project
                Project project = new Project();
                project.setName(request.getParameter("name"));
                project.setDescription(request.getParameter("description"));
                project.setClientName(request.getParameter("clientName"));

                // Set manager
                if (currentUser.getRole() == User.UserRole.ADMIN) {
                    Long managerId = Long.parseLong(request.getParameter("managerId"));
                    User manager = userService.findById(managerId)
                        .orElseThrow(() -> new ServletException("Manager not found"));
                    project.setManager(manager);
                } else {
                    project.setManager(currentUser);
                }

                // Set dates
                String startDateStr = request.getParameter("startDate");
                String endDateStr = request.getParameter("endDate");
                if (startDateStr != null && !startDateStr.isEmpty()) {
                    project.setStartDate(LocalDate.parse(startDateStr));
                }
                if (endDateStr != null && !endDateStr.isEmpty()) {
                    project.setEndDate(LocalDate.parse(endDateStr));
                }

                // Set estimates
                String estimatedHoursStr = request.getParameter("estimatedHours");
                String estimatedCostStr = request.getParameter("estimatedCost");
                if (estimatedHoursStr != null && !estimatedHoursStr.isEmpty()) {
                    project.setEstimatedHours(Integer.parseInt(estimatedHoursStr));
                }
                if (estimatedCostStr != null && !estimatedCostStr.isEmpty()) {
                    project.setEstimatedCost(new BigDecimal(estimatedCostStr));
                }

                project.setStatus(ProjectStatus.EN_ATTENTE);
                project = projectService.createProject(project);

                request.getSession().setAttribute("successMessage", "Project created successfully. Waiting for validation.");
                response.sendRedirect(request.getContextPath() + "/project/list");

            } else if ("edit".equals(action)) {
                // Update existing project
                Long projectId = Long.parseLong(request.getParameter("projectId"));
                Project project = projectService.findById(projectId)
                    .orElseThrow(() -> new ServletException("Project not found"));

                // Check permissions
                if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER &&
                    !project.getManager().getId().equals(currentUser.getId())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }

                project.setName(request.getParameter("name"));
                project.setDescription(request.getParameter("description"));
                project.setClientName(request.getParameter("clientName"));

                // Update dates
                String startDateStr = request.getParameter("startDate");
                String endDateStr = request.getParameter("endDate");
                if (startDateStr != null && !startDateStr.isEmpty()) {
                    project.setStartDate(LocalDate.parse(startDateStr));
                }
                if (endDateStr != null && !endDateStr.isEmpty()) {
                    project.setEndDate(LocalDate.parse(endDateStr));
                }

                // Update estimates
                String estimatedHoursStr = request.getParameter("estimatedHours");
                String estimatedCostStr = request.getParameter("estimatedCost");
                if (estimatedHoursStr != null && !estimatedHoursStr.isEmpty()) {
                    project.setEstimatedHours(Integer.parseInt(estimatedHoursStr));
                }
                if (estimatedCostStr != null && !estimatedCostStr.isEmpty()) {
                    project.setEstimatedCost(new BigDecimal(estimatedCostStr));
                }

                projectService.updateProject(project);

                request.getSession().setAttribute("successMessage", "Project updated successfully.");
                response.sendRedirect(request.getContextPath() + "/project/list");
            }
        } catch (Exception e) {
            request.setAttribute("error", "Failed to save project: " + e.getMessage());
            request.getRequestDispatcher("/jsp/project/project-form.jsp").forward(request, response);
        }
    }

    private void deleteProject(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        Long projectId = Long.parseLong(request.getParameter("id"));
        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        // Check permissions
        if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER &&
            !project.getManager().getId().equals(currentUser.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        projectService.deleteProject(projectId);
        request.getSession().setAttribute("successMessage", "Project deleted successfully.");
        response.sendRedirect(request.getContextPath() + "/project/list");
    }

    private void requestValidation(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        Long projectId = Long.parseLong(request.getParameter("id"));
        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        // Check permissions - only the project manager can request validation
        if (!project.getManager().getId().equals(currentUser.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (project.getStatus() != ProjectStatus.EN_ATTENTE) {
            request.getSession().setAttribute("errorMessage", "Only projects in 'En attente' status can request validation.");
        } else {
            // Status stays EN_ATTENTE, but we could add a flag or notification here
            request.getSession().setAttribute("successMessage", "Validation request sent to admin.");
        }

        response.sendRedirect(request.getContextPath() + "/project/list");
    }

    private void showValidationForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        // Only admin can validate
        if (currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Long projectId = Long.parseLong(request.getParameter("id"));
        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        request.setAttribute("project", project);
        request.setAttribute("currentUser", currentUser);
        request.getRequestDispatcher("/jsp/project/validate-project.jsp").forward(request, response);
    }

    private void validateProject(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        // Only admin can validate
        if (currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Long projectId = Long.parseLong(request.getParameter("projectId"));
        String decision = request.getParameter("decision");

        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        if ("approve".equals(decision)) {
            projectService.validateProject(projectId, currentUser);
            request.getSession().setAttribute("successMessage", "Project validated successfully.");
        } else if ("reject".equals(decision)) {
            project.setStatus(ProjectStatus.ABANDONNE);
            projectService.updateProject(project);
            request.getSession().setAttribute("successMessage", "Project rejected.");
        }

        response.sendRedirect(request.getContextPath() + "/project/list");
    }

    private void rejectProject(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        // Only admin can reject
        if (currentUser.getRole() != User.UserRole.ADMIN) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Long projectId = Long.parseLong(request.getParameter("id"));
        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        project.setStatus(ProjectStatus.ABANDONNE);
        projectService.updateProject(project);

        request.getSession().setAttribute("successMessage", "Project rejected.");
        response.sendRedirect(request.getContextPath() + "/project/list");
    }

    private void showAssignEmployeesForm(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        Long projectId = Long.parseLong(request.getParameter("id"));
        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        // Check permissions
        if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER &&
            !project.getManager().getId().equals(currentUser.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // Get all employees
        List<User> allEmployees = userService.findByRole(User.UserRole.EMPLOYEE);
        List<User> assignedEmployees = project.getAssignedEmployees() != null ?
            project.getAssignedEmployees() : new ArrayList<>();

        request.setAttribute("project", project);
        request.setAttribute("allEmployees", allEmployees);
        request.setAttribute("assignedEmployees", assignedEmployees);
        request.setAttribute("currentUser", currentUser);
        request.getRequestDispatcher("/jsp/project/assign-employees.jsp").forward(request, response);
    }

    private void saveEmployeeAssignments(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        Long projectId = Long.parseLong(request.getParameter("projectId"));
        String[] employeeIds = request.getParameterValues("employeeIds");

        Project project = projectService.findById(projectId)
            .orElseThrow(() -> new ServletException("Project not found"));

        // Check permissions
        if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER &&
            !project.getManager().getId().equals(currentUser.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<User> assignedEmployees = new ArrayList<>();
        if (employeeIds != null) {
            for (String empId : employeeIds) {
                Long employeeId = Long.parseLong(empId);
                userService.findById(employeeId).ifPresent(assignedEmployees::add);
            }
        }

        project.setAssignedEmployees(assignedEmployees);
        projectService.updateProject(project);

        request.getSession().setAttribute("successMessage", "Employees assigned successfully.");
        response.sendRedirect(request.getContextPath() + "/project/list");
    }
}