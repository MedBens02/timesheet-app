package com.timesheetapp.dao.impl;

import com.timesheetapp.dao.ProjectDAO;
import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.User;
import java.time.LocalDate;
import java.util.List;

public class ProjectDAOImpl extends BaseDAOImpl<Project, Long> implements ProjectDAO {
    
    @Override
    public List<Project> findByManager(User manager) {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE p.manager = ?1", manager);
    }

    @Override
    public List<Project> findByStatus(Project.ProjectStatus status) {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE p.status = ?1", status);
    }
    
    @Override
    public List<Project> findActiveProjects() {
        return findByStatus(Project.ProjectStatus.ACTIF);
    }

    @Override
    public List<Project> findCompletedProjects() {
        return findByStatus(Project.ProjectStatus.TERMINE);
    }
    
    @Override
    public List<Project> findValidatedProjects() {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE p.isValidated = true");
    }

    @Override
    public List<Project> findUnvalidatedProjects() {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE p.isValidated = false");
    }

    @Override
    public List<Project> findProjectsEndingBefore(LocalDate date) {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE p.endDate < ?1", date);
    }

    @Override
    public List<Project> findProjectsStartingAfter(LocalDate date) {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE p.startDate > ?1", date);
    }
    
    @Override
    public List<Project> findProjectsInDateRange(LocalDate startDate, LocalDate endDate) {
        return executeQuery(
            "SELECT p FROM Project p JOIN FETCH p.manager WHERE p.startDate >= ?1 AND p.endDate <= ?2",
            startDate, endDate);
    }

    @Override
    public List<Project> findOverBudgetProjects() {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE p.actualCost > p.estimatedCost");
    }

    @Override
    public List<Project> searchByName(String searchTerm) {
        String pattern = "%" + searchTerm.toLowerCase() + "%";
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager WHERE LOWER(p.name) LIKE ?1", pattern);
    }

    @Override
    public List<Project> findAll() {
        return executeQuery("SELECT p FROM Project p JOIN FETCH p.manager");
    }
}