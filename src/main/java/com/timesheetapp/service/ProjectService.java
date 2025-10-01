package com.timesheetapp.service;

import com.timesheetapp.dao.ProjectDAO;
import com.timesheetapp.dao.TaskDAO;
import com.timesheetapp.dao.impl.ProjectDAOImpl;
import com.timesheetapp.dao.impl.TaskDAOImpl;
import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.User;
import com.timesheetapp.util.ValidationUtil;
import jakarta.ejb.Stateless;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Stateless
public class ProjectService {

    private final ProjectDAO projectDAO;
    private final TaskDAO taskDAO;

    public ProjectService() {
        this.projectDAO = new ProjectDAOImpl();
        this.taskDAO = new TaskDAOImpl();
    }

    // Project creation

    // Overloaded method for servlet convenience
    public Project createProject(Project project) {
        return projectDAO.save(project);
    }

    public Project createProject(String name, String description, User manager,
                                Integer estimatedHours, BigDecimal estimatedCost,
                                LocalDate startDate, LocalDate endDate) {

        // Validate inputs
        if (!ValidationUtil.isNotEmpty(name)) {
            throw new IllegalArgumentException("Project name is required");
        }

        if (manager == null) {
            throw new IllegalArgumentException("Project manager is required");
        }

        if (!manager.canManageProjects()) {
            throw new IllegalArgumentException("User does not have permission to manage projects");
        }

        if (startDate != null && endDate != null && !ValidationUtil.isValidDateRange(startDate, endDate)) {
            throw new IllegalArgumentException("Invalid date range: end date must be after start date");
        }

        if (estimatedHours != null && estimatedHours < 0) {
            throw new IllegalArgumentException("Estimated hours must be positive");
        }

        if (estimatedCost != null && estimatedCost.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Estimated cost must be positive");
        }

        // Create project
        Project project = new Project(name, description, manager);
        project.setEstimatedHours(estimatedHours != null ? estimatedHours : 0);
        project.setEstimatedCost(estimatedCost != null ? estimatedCost : BigDecimal.ZERO);
        project.setStartDate(startDate);
        project.setEndDate(endDate);
        project.setStatus(Project.ProjectStatus.EN_ATTENTE);
        project.setIsValidated(false);

        return projectDAO.save(project);
    }

    // Project retrieval

    public Project getProjectById(Long id) {
        return projectDAO.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Project not found with id: " + id));
    }

    public Optional<Project> findProjectById(Long id) {
        return projectDAO.findById(id);
    }

    // Alias methods for servlet convenience
    public Optional<Project> findById(Long id) {
        return projectDAO.findById(id);
    }

    public List<Project> getAllProjects() {
        return projectDAO.findAll();
    }

    public List<Project> findAll() {
        return projectDAO.findAll();
    }

    public List<Project> findByManager(User manager) {
        return projectDAO.findByManager(manager);
    }

    public List<Project> findByStatus(Project.ProjectStatus status) {
        return projectDAO.findByStatus(status);
    }

    public List<Project> getProjectsByManager(User manager) {
        return projectDAO.findByManager(manager);
    }

    public List<Project> getProjectsByStatus(Project.ProjectStatus status) {
        return projectDAO.findByStatus(status);
    }

    public List<Project> getActiveProjects() {
        return projectDAO.findByStatus(Project.ProjectStatus.ACTIF);
    }

    public List<Project> getCompletedProjects() {
        return projectDAO.findByStatus(Project.ProjectStatus.TERMINE);
    }

    public List<Project> getValidatedProjects() {
        return projectDAO.findValidatedProjects();
    }

    public List<Project> getUnvalidatedProjects() {
        return projectDAO.findUnvalidatedProjects();
    }

    public List<Project> getProjectsForValidation() {
        return projectDAO.findUnvalidatedProjects();
    }

    public List<Project> getProjectsInDateRange(LocalDate startDate, LocalDate endDate) {
        return projectDAO.findProjectsInDateRange(startDate, endDate);
    }

    public List<Project> getOverBudgetProjects() {
        return projectDAO.findOverBudgetProjects();
    }

    // Project updates

    public Project updateProject(Project project) {
        if (project.getId() == null || !projectDAO.exists(project.getId())) {
            throw new IllegalArgumentException("Project does not exist");
        }

        // Validate dates
        if (project.getStartDate() != null && project.getEndDate() != null
            && !ValidationUtil.isValidDateRange(project.getStartDate(), project.getEndDate())) {
            throw new IllegalArgumentException("Invalid date range: end date must be after start date");
        }

        return projectDAO.update(project);
    }

    public Project updateProjectDetails(Long projectId, String name, String description,
                                       Integer estimatedHours, BigDecimal estimatedCost) {
        Project project = getProjectById(projectId);

        if (ValidationUtil.isNotEmpty(name)) {
            project.setName(name);
        }

        if (description != null) {
            project.setDescription(description);
        }

        if (estimatedHours != null) {
            if (estimatedHours < 0) {
                throw new IllegalArgumentException("Estimated hours must be positive");
            }
            project.setEstimatedHours(estimatedHours);
        }

        if (estimatedCost != null) {
            if (estimatedCost.compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("Estimated cost must be positive");
            }
            project.setEstimatedCost(estimatedCost);
        }

        return projectDAO.update(project);
    }

    public Project updateProjectDates(Long projectId, LocalDate startDate, LocalDate endDate) {
        Project project = getProjectById(projectId);

        if (startDate != null && endDate != null && !ValidationUtil.isValidDateRange(startDate, endDate)) {
            throw new IllegalArgumentException("Invalid date range: end date must be after start date");
        }

        if (startDate != null) {
            project.setStartDate(startDate);
        }

        if (endDate != null) {
            project.setEndDate(endDate);
        }

        return projectDAO.update(project);
    }

    public Project changeProjectStatus(Long projectId, Project.ProjectStatus newStatus) {
        Project project = getProjectById(projectId);

        if (newStatus == null) {
            throw new IllegalArgumentException("Status cannot be null");
        }

        // Business rules for status transitions
        if (project.getStatus() == Project.ProjectStatus.TERMINE && newStatus != Project.ProjectStatus.TERMINE) {
            throw new IllegalStateException("Cannot change status of completed project");
        }

        project.setStatus(newStatus);
        return projectDAO.update(project);
    }

    public Project activateProject(Long projectId) {
        Project project = getProjectById(projectId);

        if (!project.getIsValidated()) {
            throw new IllegalStateException("Project must be validated before activation");
        }

        project.setStatus(Project.ProjectStatus.ACTIF);
        return projectDAO.update(project);
    }

    public Project completeProject(Long projectId) {
        Project project = getProjectById(projectId);

        // Check if all tasks are completed
        List<Task> tasks = taskDAO.findByProject(project);
        long incompleteTasks = tasks.stream()
            .filter(task -> task.getStatus() != Task.TaskStatus.VALIDEE && task.getStatus() != Task.TaskStatus.ANNULEE)
            .count();

        if (incompleteTasks > 0) {
            throw new IllegalStateException("Cannot complete project with incomplete tasks. " + incompleteTasks + " task(s) remaining.");
        }

        project.setStatus(Project.ProjectStatus.TERMINE);
        return projectDAO.update(project);
    }

    public Project holdProject(Long projectId) {
        Project project = getProjectById(projectId);
        project.setStatus(Project.ProjectStatus.EN_ATTENTE);
        return projectDAO.update(project);
    }

    public Project cancelProject(Long projectId) {
        Project project = getProjectById(projectId);
        project.setStatus(Project.ProjectStatus.ABANDONNE);
        return projectDAO.update(project);
    }

    // Project validation

    public Project validateProject(Long projectId, User validator) {
        Project project = getProjectById(projectId);

        if (validator == null) {
            throw new IllegalArgumentException("Validator is required");
        }

        if (!validator.canManageProjects() && validator.getRole() != User.UserRole.ADMIN) {
            throw new IllegalArgumentException("User does not have permission to validate projects");
        }

        if (project.getIsValidated()) {
            throw new IllegalStateException("Project is already validated");
        }

        project.setIsValidated(true);
        project.setValidatedBy(validator);
        project.setValidatedAt(LocalDateTime.now());

        return projectDAO.update(project);
    }

    public Project rejectProjectValidation(Long projectId) {
        Project project = getProjectById(projectId);

        if (!project.getIsValidated()) {
            throw new IllegalStateException("Project is not validated");
        }

        if (project.getStatus() == Project.ProjectStatus.ACTIF || project.getStatus() == Project.ProjectStatus.TERMINE) {
            throw new IllegalStateException("Cannot reject validation of active or completed project");
        }

        project.setIsValidated(false);
        project.setValidatedBy(null);
        project.setValidatedAt(null);

        return projectDAO.update(project);
    }

    // Project progress and cost tracking

    public Project updateActualHours(Long projectId, BigDecimal hours) {
        Project project = getProjectById(projectId);

        if (hours == null || hours.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Hours must be positive");
        }

        project.setActualHours(hours);
        return projectDAO.update(project);
    }

    public Project updateActualCost(Long projectId, BigDecimal cost) {
        Project project = getProjectById(projectId);

        if (cost == null || cost.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Cost must be positive");
        }

        project.setActualCost(cost);
        return projectDAO.update(project);
    }

    public void recalculateProjectMetrics(Long projectId) {
        Project project = getProjectById(projectId);
        List<Task> tasks = taskDAO.findByProject(project);

        // Calculate total actual hours from tasks
        BigDecimal totalHours = tasks.stream()
            .map(Task::getActualHours)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        project.setActualHours(totalHours);

        // Actual cost calculation would require timesheet data
        // This is a simplified version
        projectDAO.update(project);
    }

    public double getProjectProgress(Long projectId) {
        Project project = getProjectById(projectId);
        return project.getProgressPercentage();
    }

    public boolean isProjectOverBudget(Long projectId) {
        Project project = getProjectById(projectId);
        return project.isOverBudget();
    }

    // Project manager assignment

    public Project assignManager(Long projectId, User newManager) {
        Project project = getProjectById(projectId);

        if (newManager == null) {
            throw new IllegalArgumentException("Manager is required");
        }

        if (!newManager.canManageProjects()) {
            throw new IllegalArgumentException("User does not have permission to manage projects");
        }

        project.setManager(newManager);
        return projectDAO.update(project);
    }

    // Delete operations

    public void deleteProject(Long projectId) {
        Project project = getProjectById(projectId);

        // Check if project has tasks
        List<Task> tasks = taskDAO.findByProject(project);
        if (!tasks.isEmpty()) {
            throw new IllegalStateException("Cannot delete project with existing tasks. Delete or reassign tasks first.");
        }

        if (project.getStatus() == Project.ProjectStatus.ACTIF) {
            throw new IllegalStateException("Cannot delete active project. Cancel or complete it first.");
        }

        projectDAO.delete(projectId);
    }

    // Utility methods

    public long getTotalProjectCount() {
        return projectDAO.count();
    }

    public boolean canUserManageProject(User user, Project project) {
        if (user == null || project == null) {
            return false;
        }

        return user.getRole() == User.UserRole.ADMIN ||
               (user.getRole() == User.UserRole.PROJECT_MANAGER && project.getManager().getId().equals(user.getId()));
    }

    public List<Project> getProjectsForUser(User user) {
        if (user == null) {
            throw new IllegalArgumentException("User is required");
        }

        if (user.getRole() == User.UserRole.ADMIN) {
            return getAllProjects();
        } else if (user.getRole() == User.UserRole.PROJECT_MANAGER) {
            return getProjectsByManager(user);
        } else {
            // For employees, return projects they have tasks in
            List<Task> userTasks = taskDAO.findByAssignedUser(user);
            return userTasks.stream()
                .map(Task::getProject)
                .distinct()
                .toList();
        }
    }
}