package com.timesheetapp.dao.impl;

import com.timesheetapp.dao.ProjectDAO;
import com.timesheetapp.entity.Project;
import com.timesheetapp.entity.User;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public class ProjectDAOImpl extends BaseDAOImpl<Project, Long> implements ProjectDAO {

    @Override
    public Optional<Project> findById(Long id) {
        List<Project> results = executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.id = ?1", id);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }
    
    @Override
    public List<Project> findByManager(User manager) {
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.manager = ?1", manager);
    }

    @Override
    public List<Project> findByStatus(Project.ProjectStatus status) {
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.status = ?1", status);
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
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.isValidated = true");
    }

    @Override
    public List<Project> findUnvalidatedProjects() {
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.isValidated = false");
    }

    @Override
    public List<Project> findProjectsEndingBefore(LocalDate date) {
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.endDate < ?1", date);
    }

    @Override
    public List<Project> findProjectsStartingAfter(LocalDate date) {
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.startDate > ?1", date);
    }

    @Override
    public List<Project> findProjectsInDateRange(LocalDate startDate, LocalDate endDate) {
        return executeQuery(
            "SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.startDate >= ?1 AND p.endDate <= ?2",
            startDate, endDate);
    }

    @Override
    public List<Project> findOverBudgetProjects() {
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE p.actualCost > p.estimatedCost");
    }

    @Override
    public List<Project> searchByName(String searchTerm) {
        String pattern = "%" + searchTerm.toLowerCase() + "%";
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees WHERE LOWER(p.name) LIKE ?1", pattern);
    }

    @Override
    public List<Project> findAll() {
        return executeQuery("SELECT DISTINCT p FROM Project p JOIN FETCH p.manager LEFT JOIN FETCH p.assignedEmployees");
    }
}