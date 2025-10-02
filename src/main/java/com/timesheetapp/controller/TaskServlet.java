package com.timesheetapp.controller;

import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.User;
import com.timesheetapp.service.ProjectService;
import com.timesheetapp.service.TaskService;
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
import java.util.Optional;

@WebServlet(name = "TaskServlet", urlPatterns = {"/task/list", "/task/create", "/task/edit", "/task/delete", "/task/view", "/task/update-status"})
public class TaskServlet extends HttpServlet {

    private TaskService taskService;
    private ProjectService projectService;
    private UserService userService;

    @Override
    public void init() throws ServletException {
        super.init();
        taskService = new TaskService();
        projectService = new ProjectService();
        userService = new UserService();
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
                case "/task/list":
                    showTaskList(request, response, currentUser);
                    break;
                case "/task/create":
                    showTaskForm(request, response, currentUser, null);
                    break;
                case "/task/edit":
                    showEditTask(request, response, currentUser);
                    break;
                case "/task/view":
                    showTaskView(request, response, currentUser);
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
                case "/task/create":
                    createTask(request, response, currentUser);
                    break;
                case "/task/edit":
                    updateTask(request, response, currentUser);
                    break;
                case "/task/delete":
                    deleteTask(request, response, currentUser);
                    break;
                case "/task/update-status":
                    updateTaskStatus(request, response, currentUser);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/jsp/error.jsp").forward(request, response);
        }
    }

    private void showTaskList(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String statusParam = request.getParameter("status");
        String priorityParam = request.getParameter("priority");
        String projectIdParam = request.getParameter("projectId");

        List<Task> tasks;

        if (currentUser.getRole() == User.UserRole.ADMIN) {
            tasks = taskService.getAllTasks();
        } else if (currentUser.getRole() == User.UserRole.PROJECT_MANAGER) {
            // Show tasks from projects managed by this user
            List<Project> managedProjects = projectService.findByManager(currentUser);
            tasks = new java.util.ArrayList<>();
            for (Project project : managedProjects) {
                tasks.addAll(taskService.getTasksByProject(project));
            }
        } else {
            // Employees see only their assigned tasks
            tasks = taskService.getTasksByUser(currentUser);
        }

        // Apply filters
        if (statusParam != null && !statusParam.isEmpty()) {
            Task.TaskStatus status = Task.TaskStatus.valueOf(statusParam);
            tasks = tasks.stream().filter(t -> t.getStatus() == status).toList();
        }

        if (priorityParam != null && !priorityParam.isEmpty()) {
            Task.TaskPriority priority = Task.TaskPriority.valueOf(priorityParam);
            tasks = tasks.stream().filter(t -> t.getPriority() == priority).toList();
        }

        if (projectIdParam != null && !projectIdParam.isEmpty()) {
            Long projectId = Long.parseLong(projectIdParam);
            tasks = tasks.stream().filter(t -> t.getProject().getId().equals(projectId)).toList();
        }

        request.setAttribute("tasks", tasks);
        request.getRequestDispatcher("/jsp/task/task-list.jsp").forward(request, response);
    }

    private void showTaskForm(HttpServletRequest request, HttpServletResponse response, User currentUser, Task task)
            throws ServletException, IOException {

        // Only managers and admins can create tasks
        if (currentUser.getRole() == User.UserRole.EMPLOYEE) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to create tasks");
            return;
        }

        List<Project> projects;
        if (currentUser.getRole() == User.UserRole.ADMIN) {
            projects = projectService.getAllProjects();
        } else {
            projects = projectService.findByManager(currentUser);
        }

        List<User> employees = userService.findByRole(User.UserRole.EMPLOYEE);

        request.setAttribute("projects", projects);
        request.setAttribute("employees", employees);
        request.setAttribute("task", task);
        request.getRequestDispatcher("/jsp/task/task-form.jsp").forward(request, response);
    }

    private void showEditTask(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/task/list");
            return;
        }

        Long taskId = Long.parseLong(idParam);
        Task task = taskService.getTaskById(taskId);

        if (task == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
            return;
        }

        // Check permissions
        if (!canUserManageTask(currentUser, task)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to edit this task");
            return;
        }

        showTaskForm(request, response, currentUser, task);
    }

    private void showTaskView(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/task/list");
            return;
        }

        Long taskId = Long.parseLong(idParam);
        Task task = taskService.getTaskById(taskId);

        if (task == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
            return;
        }
        request.setAttribute("task", task);
        request.getRequestDispatcher("/jsp/task/task-view.jsp").forward(request, response);
    }

    private void createTask(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        // Only managers and admins can create tasks
        if (currentUser.getRole() == User.UserRole.EMPLOYEE) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            Long projectId = Long.parseLong(request.getParameter("projectId"));
            Long assignedUserId = request.getParameter("assignedUserId") != null ?
                    Long.parseLong(request.getParameter("assignedUserId")) : null;
            String priorityStr = request.getParameter("priority");
            String dueDateStr = request.getParameter("dueDate");
            String estimatedHoursStr = request.getParameter("estimatedHours");

            Project project = projectService.getProjectById(projectId);
            User assignedUser = assignedUserId != null ? userService.getUserById(assignedUserId) : null;
            Task.TaskPriority priority = Task.TaskPriority.valueOf(priorityStr);
            LocalDate dueDate = dueDateStr != null && !dueDateStr.isEmpty() ? LocalDate.parse(dueDateStr) : null;
            Integer estimatedHours = estimatedHoursStr != null && !estimatedHoursStr.isEmpty() ?
                    Integer.parseInt(estimatedHoursStr) : null;

            Task task = taskService.createTask(name, description, project, assignedUser, estimatedHours, priority, dueDate);

            SessionUtil.setSuccessMessage(request, "Task created successfully!");
            response.sendRedirect(request.getContextPath() + "/task/list");

        } catch (Exception e) {
            request.setAttribute("error", "Error creating task: " + e.getMessage());
            showTaskForm(request, response, currentUser, null);
        }
    }

    private void updateTask(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        try {
            Long taskId = Long.parseLong(request.getParameter("id"));
            Task task = taskService.getTaskById(taskId);

            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if (!canUserManageTask(currentUser, task)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            String name = request.getParameter("name");
            String description = request.getParameter("description");
            Long assignedUserId = request.getParameter("assignedUserId") != null ?
                    Long.parseLong(request.getParameter("assignedUserId")) : null;
            String priorityStr = request.getParameter("priority");
            String dueDateStr = request.getParameter("dueDate");
            String estimatedHoursStr = request.getParameter("estimatedHours");

            task.setName(name);
            task.setDescription(description);
            task.setPriority(Task.TaskPriority.valueOf(priorityStr));

            if (dueDateStr != null && !dueDateStr.isEmpty()) {
                task.setDueDate(LocalDate.parse(dueDateStr));
            }

            if (estimatedHoursStr != null && !estimatedHoursStr.isEmpty()) {
                task.setEstimatedHours(Integer.parseInt(estimatedHoursStr));
            }

            if (assignedUserId != null) {
                User assignedUser = userService.getUserById(assignedUserId);
                task.setAssignedTo(assignedUser);
            }

            taskService.updateTask(task);

            SessionUtil.setSuccessMessage(request, "Task updated successfully!");
            response.sendRedirect(request.getContextPath() + "/task/list");

        } catch (Exception e) {
            request.setAttribute("error", "Error updating task: " + e.getMessage());
            showEditTask(request, response, currentUser);
        }
    }

    private void deleteTask(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/task/list");
            return;
        }

        try {
            Long taskId = Long.parseLong(idParam);
            Task task = taskService.getTaskById(taskId);

            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            if (!canUserManageTask(currentUser, task)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }

            taskService.deleteTask(taskId);

            SessionUtil.setSuccessMessage(request, "Task deleted successfully!");
            response.sendRedirect(request.getContextPath() + "/task/list");

        } catch (Exception e) {
            SessionUtil.setErrorMessage(request, "Error deleting task: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/task/list");
        }
    }

    private void updateTaskStatus(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        try {
            Long taskId = Long.parseLong(request.getParameter("id"));
            String statusStr = request.getParameter("status");

            Task task = taskService.getTaskById(taskId);
            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            Task.TaskStatus newStatus = Task.TaskStatus.valueOf(statusStr);

            // Employees can only update their own tasks
            if (currentUser.getRole() == User.UserRole.EMPLOYEE) {
                if (task.getAssignedTo() == null || !task.getAssignedTo().getId().equals(currentUser.getId())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
            }

            task.setStatus(newStatus);
            taskService.updateTask(task);

            SessionUtil.setSuccessMessage(request, "Task status updated!");
            response.sendRedirect(request.getContextPath() + "/task/list");

        } catch (Exception e) {
            SessionUtil.setErrorMessage(request, "Error updating status: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/task/list");
        }
    }

    private boolean canUserManageTask(User user, Task task) {
        if (user.getRole() == User.UserRole.ADMIN) {
            return true;
        }
        if (user.getRole() == User.UserRole.PROJECT_MANAGER) {
            return task.getProject().getManager().getId().equals(user.getId());
        }
        return false;
    }
}
