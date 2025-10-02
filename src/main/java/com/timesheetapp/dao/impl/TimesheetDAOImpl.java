package com.timesheetapp.dao.impl;

import com.timesheetapp.dao.TimesheetDAO;
import com.timesheetapp.entity.Timesheet;
import com.timesheetapp.entity.User;
import com.timesheetapp.util.EntityManagerUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public class TimesheetDAOImpl extends BaseDAOImpl<Timesheet, Long> implements TimesheetDAO {

    @Override
    public Optional<Timesheet> findById(Long id) {
        List<Timesheet> results = executeQuery("SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.id = ?1", id);
        return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
    }

    @Override
    public List<Timesheet> findAll() {
        return executeQuery("SELECT t FROM Timesheet t JOIN FETCH t.user");
    }

    @Override
    public List<Timesheet> findByUser(User user) {
        return executeQuery("SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.user = ?1", user);
    }

    @Override
    public List<Timesheet> findByStatus(Timesheet.TimesheetStatus status) {
        return executeQuery("SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.status = ?1", status);
    }
    
    @Override
    public Optional<Timesheet> findByUserAndWeek(User user, LocalDate weekStartDate) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<Timesheet> query = em.createQuery(
                "SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.user = :user AND t.weekStartDate = :weekStart",
                Timesheet.class);
            query.setParameter("user", user);
            query.setParameter("weekStart", weekStartDate);
            return Optional.of(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        } catch (Exception e) {
            throw new RuntimeException("Error finding timesheet by user and week: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    @Override
    public List<Timesheet> findByUserAndDateRange(User user, LocalDate startDate, LocalDate endDate) {
        return executeQuery(
            "SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.user = ?1 AND t.weekStartDate >= ?2 AND t.weekEndDate <= ?3",
            user, startDate, endDate);
    }
    
    @Override
    public List<Timesheet> findSubmittedTimesheets() {
        return findByStatus(Timesheet.TimesheetStatus.SUBMITTED);
    }
    
    @Override
    public List<Timesheet> findValidatedTimesheets() {
        return findByStatus(Timesheet.TimesheetStatus.VALIDATED);
    }
    
    @Override
    public List<Timesheet> findRejectedTimesheets() {
        return findByStatus(Timesheet.TimesheetStatus.REJECTED);
    }
    
    @Override
    public List<Timesheet> findDraftTimesheets() {
        return findByStatus(Timesheet.TimesheetStatus.DRAFT);
    }
    
    @Override
    public List<Timesheet> findTimesheetsForValidation() {
        return findByStatus(Timesheet.TimesheetStatus.SUBMITTED);
    }
    
    @Override
    public List<Timesheet> findTimesheetsByValidator(User validator) {
        return executeQuery("SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.validatedBy = ?1", validator);
    }

    @Override
    public List<Timesheet> findTimesheetsInWeek(LocalDate weekStartDate) {
        return executeQuery("SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.weekStartDate = ?1", weekStartDate);
    }

    @Override
    public List<Timesheet> findTimesheetsInMonth(int year, int month) {
        LocalDate startOfMonth = LocalDate.of(year, month, 1);
        LocalDate endOfMonth = startOfMonth.withDayOfMonth(startOfMonth.lengthOfMonth());
        return executeQuery(
            "SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.weekStartDate >= ?1 AND t.weekStartDate <= ?2",
            startOfMonth, endOfMonth);
    }

    @Override
    public List<Timesheet> findTimesheetsInYear(int year) {
        LocalDate startOfYear = LocalDate.of(year, 1, 1);
        LocalDate endOfYear = LocalDate.of(year, 12, 31);
        return executeQuery(
            "SELECT t FROM Timesheet t JOIN FETCH t.user WHERE t.weekStartDate >= ?1 AND t.weekStartDate <= ?2",
            startOfYear, endOfYear);
    }
}