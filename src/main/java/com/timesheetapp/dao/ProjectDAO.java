package com.timesheetapp.dao;

import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.User;
import java.time.LocalDate;
import java.util.List;

public interface ProjectDAO extends BaseDAO<Project, Long> {
    
    List<Project> findByManager(User manager);
    
    List<Project> findByStatus(Project.ProjectStatus status);
    
    List<Project> findActiveProjects();
    
    List<Project> findCompletedProjects();
    
    List<Project> findValidatedProjects();
    
    List<Project> findUnvalidatedProjects();
    
    List<Project> findProjectsEndingBefore(LocalDate date);
    
    List<Project> findProjectsStartingAfter(LocalDate date);
    
    List<Project> findProjectsInDateRange(LocalDate startDate, LocalDate endDate);
    
    List<Project> findOverBudgetProjects();
    
    List<Project> searchByName(String searchTerm);
}