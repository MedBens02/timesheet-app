package com.timesheetapp.dao;

import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.User;
import java.time.LocalDate;
import java.util.List;

public interface TaskDAO extends BaseDAO<Task, Long> {
    
    List<Task> findByProject(Project project);
    
    List<Task> findByAssignedUser(User user);
    
    List<Task> findByStatus(Task.TaskStatus status);
    
    List<Task> findByPriority(Task.TaskPriority priority);
    
    List<Task> findByProjectAndUser(Project project, User user);
    
    List<Task> findByProjectAndStatus(Project project, Task.TaskStatus status);
    
    List<Task> findByUserAndStatus(User user, Task.TaskStatus status);
    
    List<Task> findOverdueTasks();
    
    List<Task> findTasksDueToday();
    
    List<Task> findTasksDueBefore(LocalDate date);
    
    List<Task> findCompletedTasks();
    
    List<Task> findInProgressTasks();
    
    List<Task> findHighPriorityTasks();
    
    List<Task> searchByName(String searchTerm);
}