package com.timesheetapp.dao.impl;

import com.timesheetapp.dao.TaskDAO;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.User;
import java.time.LocalDate;
import java.util.List;

public class TaskDAOImpl extends BaseDAOImpl<Task, Long> implements TaskDAO {
    
    @Override
    public List<Task> findByProject(Project project) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.project = ?1", project);
    }

    @Override
    public List<Task> findByAssignedUser(User user) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.assignedTo = ?1", user);
    }

    @Override
    public List<Task> findByStatus(Task.TaskStatus status) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.status = ?1", status);
    }

    @Override
    public List<Task> findByPriority(Task.TaskPriority priority) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.priority = ?1", priority);
    }

    @Override
    public List<Task> findByProjectAndUser(Project project, User user) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.project = ?1 AND t.assignedTo = ?2",
                           project, user);
    }

    @Override
    public List<Task> findByProjectAndStatus(Project project, Task.TaskStatus status) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.project = ?1 AND t.status = ?2",
                           project, status);
    }

    @Override
    public List<Task> findByUserAndStatus(User user, Task.TaskStatus status) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.assignedTo = ?1 AND t.status = ?2",
                           user, status);
    }
    
    @Override
    public List<Task> findOverdueTasks() {
        LocalDate today = LocalDate.now();
        return executeQuery(
            "SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.dueDate < ?1 AND t.status != ?2",
            today, Task.TaskStatus.COMPLETED);
    }

    @Override
    public List<Task> findTasksDueToday() {
        LocalDate today = LocalDate.now();
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.dueDate = ?1", today);
    }

    @Override
    public List<Task> findTasksDueBefore(LocalDate date) {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.dueDate < ?1", date);
    }
    
    @Override
    public List<Task> findCompletedTasks() {
        return findByStatus(Task.TaskStatus.COMPLETED);
    }
    
    @Override
    public List<Task> findInProgressTasks() {
        return findByStatus(Task.TaskStatus.IN_PROGRESS);
    }
    
    @Override
    public List<Task> findHighPriorityTasks() {
        return executeQuery(
            "SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE t.priority IN (?1, ?2)",
            Task.TaskPriority.HIGH, Task.TaskPriority.URGENT);
    }

    @Override
    public List<Task> searchByName(String searchTerm) {
        String pattern = "%" + searchTerm.toLowerCase() + "%";
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo WHERE LOWER(t.name) LIKE ?1", pattern);
    }

    @Override
    public List<Task> findAll() {
        return executeQuery("SELECT t FROM Task t JOIN FETCH t.project JOIN FETCH t.assignedTo");
    }
}