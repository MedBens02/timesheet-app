package com.timesheetapp.service;

import com.timesheetapp.dao.TaskDAO;
import com.timesheetapp.dao.TimesheetEntryDAO;
import com.timesheetapp.dao.impl.TaskDAOImpl;
import com.timesheetapp.dao.impl.TimesheetEntryDAOImpl;
import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.TimesheetEntry;
import com.timesheetapp.entity.User;
import com.timesheetapp.util.ValidationUtil;
import jakarta.ejb.Stateless;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Stateless
public class TaskService {

    private final TaskDAO taskDAO;
    private final TimesheetEntryDAO timesheetEntryDAO;

    public TaskService() {
        this.taskDAO = new TaskDAOImpl();
        this.timesheetEntryDAO = new TimesheetEntryDAOImpl();
    }

    // Task creation

    public Task createTask(String name, String description, Project project, User assignedTo,
                          Integer estimatedHours, Task.TaskPriority priority, LocalDate dueDate) {

        // Validate inputs
        if (!ValidationUtil.isNotEmpty(name)) {
            throw new IllegalArgumentException("Task name is required");
        }

        if (project == null) {
            throw new IllegalArgumentException("Project is required");
        }

        if (assignedTo == null) {
            throw new IllegalArgumentException("Assigned user is required");
        }

        if (estimatedHours != null && estimatedHours < 0) {
            throw new IllegalArgumentException("Estimated hours must be positive");
        }

        if (dueDate != null && project.getEndDate() != null && dueDate.isAfter(project.getEndDate())) {
            throw new IllegalArgumentException("Task due date cannot be after project end date");
        }

        // Create task
        Task task = new Task(name, description, project, assignedTo);
        task.setEstimatedHours(estimatedHours != null ? estimatedHours : 0);
        task.setPriority(priority != null ? priority : Task.TaskPriority.MEDIUM);
        task.setDueDate(dueDate);
        task.setStatus(Task.TaskStatus.TODO);

        return taskDAO.save(task);
    }

    // Task retrieval

    public Task getTaskById(Long id) {
        return taskDAO.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Task not found with id: " + id));
    }

    public Optional<Task> findTaskById(Long id) {
        return taskDAO.findById(id);
    }

    public List<Task> getAllTasks() {
        return taskDAO.findAll();
    }

    public List<Task> getTasksByProject(Project project) {
        return taskDAO.findByProject(project);
    }

    public List<Task> getTasksByUser(User user) {
        return taskDAO.findByAssignedUser(user);
    }

    public List<Task> getTasksByStatus(Task.TaskStatus status) {
        return taskDAO.findByStatus(status);
    }

    public List<Task> getTasksByPriority(Task.TaskPriority priority) {
        return taskDAO.findByPriority(priority);
    }

    public List<Task> getTasksByProjectAndUser(Project project, User user) {
        return taskDAO.findByProjectAndUser(project, user);
    }

    public List<Task> getTasksByProjectAndStatus(Project project, Task.TaskStatus status) {
        return taskDAO.findByProjectAndStatus(project, status);
    }

    public List<Task> getOverdueTasks() {
        return taskDAO.findOverdueTasks();
    }

    public List<Task> getTasksDueBefore(LocalDate date) {
        return taskDAO.findTasksDueBefore(date);
    }

    public List<Task> getHighPriorityTasks() {
        return taskDAO.findHighPriorityTasks();
    }

    public List<Task> getCompletedTasks() {
        return taskDAO.findByStatus(Task.TaskStatus.COMPLETED);
    }

    public List<Task> getInProgressTasks() {
        return taskDAO.findByStatus(Task.TaskStatus.IN_PROGRESS);
    }

    public List<Task> getTodoTasks() {
        return taskDAO.findByStatus(Task.TaskStatus.TODO);
    }

    // Task updates

    public Task updateTask(Task task) {
        if (task.getId() == null || !taskDAO.exists(task.getId())) {
            throw new IllegalArgumentException("Task does not exist");
        }

        // Validate due date against project end date
        if (task.getDueDate() != null && task.getProject() != null
            && task.getProject().getEndDate() != null
            && task.getDueDate().isAfter(task.getProject().getEndDate())) {
            throw new IllegalArgumentException("Task due date cannot be after project end date");
        }

        return taskDAO.update(task);
    }

    public Task updateTaskDetails(Long taskId, String name, String description,
                                 Integer estimatedHours, Task.TaskPriority priority, LocalDate dueDate) {
        Task task = getTaskById(taskId);

        if (ValidationUtil.isNotEmpty(name)) {
            task.setName(name);
        }

        if (description != null) {
            task.setDescription(description);
        }

        if (estimatedHours != null) {
            if (estimatedHours < 0) {
                throw new IllegalArgumentException("Estimated hours must be positive");
            }
            task.setEstimatedHours(estimatedHours);
        }

        if (priority != null) {
            task.setPriority(priority);
        }

        if (dueDate != null) {
            if (task.getProject().getEndDate() != null && dueDate.isAfter(task.getProject().getEndDate())) {
                throw new IllegalArgumentException("Task due date cannot be after project end date");
            }
            task.setDueDate(dueDate);
        }

        return taskDAO.update(task);
    }

    public Task updateTaskStatus(Long taskId, Task.TaskStatus newStatus) {
        Task task = getTaskById(taskId);

        if (newStatus == null) {
            throw new IllegalArgumentException("Status cannot be null");
        }

        // Business rules for status transitions
        if (task.getStatus() == Task.TaskStatus.COMPLETED && newStatus != Task.TaskStatus.COMPLETED) {
            throw new IllegalStateException("Cannot change status of completed task");
        }

        task.setStatus(newStatus);

        if (newStatus == Task.TaskStatus.COMPLETED) {
            task.setCompletedAt(LocalDateTime.now());
        }

        return taskDAO.update(task);
    }

    public Task startTask(Long taskId) {
        Task task = getTaskById(taskId);

        if (task.getStatus() == Task.TaskStatus.COMPLETED) {
            throw new IllegalStateException("Cannot start a completed task");
        }

        if (task.getStatus() == Task.TaskStatus.CANCELLED) {
            throw new IllegalStateException("Cannot start a cancelled task");
        }

        task.setStatus(Task.TaskStatus.IN_PROGRESS);
        return taskDAO.update(task);
    }

    public Task completeTask(Long taskId) {
        Task task = getTaskById(taskId);

        if (task.getStatus() == Task.TaskStatus.COMPLETED) {
            throw new IllegalStateException("Task is already completed");
        }

        if (task.getStatus() == Task.TaskStatus.CANCELLED) {
            throw new IllegalStateException("Cannot complete a cancelled task");
        }

        task.setStatus(Task.TaskStatus.COMPLETED);
        task.setCompletedAt(LocalDateTime.now());

        return taskDAO.update(task);
    }

    public Task cancelTask(Long taskId) {
        Task task = getTaskById(taskId);

        if (task.getStatus() == Task.TaskStatus.COMPLETED) {
            throw new IllegalStateException("Cannot cancel a completed task");
        }

        task.setStatus(Task.TaskStatus.CANCELLED);
        return taskDAO.update(task);
    }

    // Task assignment

    public Task reassignTask(Long taskId, User newAssignee) {
        Task task = getTaskById(taskId);

        if (newAssignee == null) {
            throw new IllegalArgumentException("Assignee is required");
        }

        if (task.getStatus() == Task.TaskStatus.COMPLETED) {
            throw new IllegalStateException("Cannot reassign completed task");
        }

        task.setAssignedTo(newAssignee);
        return taskDAO.update(task);
    }

    // Task progress tracking

    public Task updateActualHours(Long taskId, BigDecimal hours) {
        Task task = getTaskById(taskId);

        if (hours == null || hours.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Hours must be positive");
        }

        task.setActualHours(hours);
        return taskDAO.update(task);
    }

    public void recalculateTaskHours(Long taskId) {
        Task task = getTaskById(taskId);
        List<TimesheetEntry> entries = timesheetEntryDAO.findByTask(task);

        BigDecimal totalHours = entries.stream()
            .map(TimesheetEntry::getHoursWorked)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        task.setActualHours(totalHours);
        taskDAO.update(task);
    }

    public double getTaskProgress(Long taskId) {
        Task task = getTaskById(taskId);
        return task.getProgressPercentage();
    }

    public boolean isTaskOverdue(Long taskId) {
        Task task = getTaskById(taskId);
        return task.isOverdue();
    }

    // Delete operations

    public void deleteTask(Long taskId) {
        Task task = getTaskById(taskId);

        // Check if task has timesheet entries
        List<TimesheetEntry> entries = timesheetEntryDAO.findByTask(task);
        if (!entries.isEmpty()) {
            throw new IllegalStateException("Cannot delete task with timesheet entries. Complete or cancel the task instead.");
        }

        if (task.getStatus() == Task.TaskStatus.IN_PROGRESS) {
            throw new IllegalStateException("Cannot delete task in progress. Cancel or complete it first.");
        }

        taskDAO.delete(taskId);
    }

    // Utility methods

    public long getTotalTaskCount() {
        return taskDAO.count();
    }

    public List<Task> getTasksForUserDashboard(User user) {
        if (user == null) {
            throw new IllegalArgumentException("User is required");
        }

        // Return tasks assigned to the user that are not completed or cancelled
        return taskDAO.findByAssignedUser(user).stream()
            .filter(task -> task.getStatus() != Task.TaskStatus.COMPLETED
                         && task.getStatus() != Task.TaskStatus.CANCELLED)
            .toList();
    }

    public List<Task> getOverdueTasksForUser(User user) {
        List<Task> userTasks = getTasksByUser(user);
        return userTasks.stream()
            .filter(Task::isOverdue)
            .toList();
    }

    public List<Task> getUpcomingTasksForUser(User user, int daysAhead) {
        LocalDate futureDate = LocalDate.now().plusDays(daysAhead);
        List<Task> userTasks = getTasksByUser(user);

        return userTasks.stream()
            .filter(task -> task.getDueDate() != null
                         && !task.getDueDate().isBefore(LocalDate.now())
                         && !task.getDueDate().isAfter(futureDate)
                         && task.getStatus() != Task.TaskStatus.COMPLETED)
            .toList();
    }

    public boolean canUserEditTask(User user, Task task) {
        if (user == null || task == null) {
            return false;
        }

        // Admin can edit any task
        if (user.getRole() == User.UserRole.ADMIN) {
            return true;
        }

        // Project manager can edit tasks in their projects
        if (user.getRole() == User.UserRole.PROJECT_MANAGER
            && task.getProject().getManager().getId().equals(user.getId())) {
            return true;
        }

        // Employees can edit their own tasks (but not status changes beyond starting)
        return user.getId().equals(task.getAssignedTo().getId());
    }
}