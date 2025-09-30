package com.timesheetapp.dao.impl;

import com.timesheetapp.dao.TimesheetEntryDAO;
import com.timesheetapp.entity.TimesheetEntry;
import com.timesheetapp.entity.Timesheet;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.User;
import com.timesheetapp.util.EntityManagerUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public class TimesheetEntryDAOImpl extends BaseDAOImpl<TimesheetEntry, Long> implements TimesheetEntryDAO {

    @Override
    public List<TimesheetEntry> findByTimesheet(Timesheet timesheet) {
        return executeQuery("SELECT te FROM TimesheetEntry te WHERE te.timesheet = ?1", timesheet);
    }

    @Override
    public List<TimesheetEntry> findByTask(Task task) {
        return executeQuery("SELECT te FROM TimesheetEntry te WHERE te.task = ?1", task);
    }

    @Override
    public List<TimesheetEntry> findByWorkDate(LocalDate workDate) {
        return executeQuery("SELECT te FROM TimesheetEntry te WHERE te.workDate = ?1", workDate);
    }

    @Override
    public Optional<TimesheetEntry> findByTimesheetAndTaskAndDate(Timesheet timesheet, Task task, LocalDate workDate) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<TimesheetEntry> query = em.createQuery(
                "SELECT te FROM TimesheetEntry te WHERE te.timesheet = :timesheet AND te.task = :task AND te.workDate = :workDate",
                TimesheetEntry.class);
            query.setParameter("timesheet", timesheet);
            query.setParameter("task", task);
            query.setParameter("workDate", workDate);
            return Optional.of(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        } catch (Exception e) {
            throw new RuntimeException("Error finding timesheet entry by timesheet, task and date: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    @Override
    public List<TimesheetEntry> findByTimesheetAndTask(Timesheet timesheet, Task task) {
        return executeQuery("SELECT te FROM TimesheetEntry te WHERE te.timesheet = ?1 AND te.task = ?2", timesheet, task);
    }

    @Override
    public List<TimesheetEntry> findValidatedEntries() {
        return executeQuery("SELECT te FROM TimesheetEntry te WHERE te.isValidated = true");
    }

    @Override
    public List<TimesheetEntry> findUnvalidatedEntries() {
        return executeQuery("SELECT te FROM TimesheetEntry te WHERE te.isValidated = false");
    }

    @Override
    public List<TimesheetEntry> findEntriesForValidation() {
        return executeQuery(
            "SELECT te FROM TimesheetEntry te WHERE te.isValidated = false AND te.timesheet.status = 'SUBMITTED'");
    }

    @Override
    public List<TimesheetEntry> findEntriesByValidator(User validator) {
        return executeQuery("SELECT te FROM TimesheetEntry te WHERE te.validatedBy = ?1", validator);
    }

    @Override
    public List<TimesheetEntry> findEntriesInDateRange(LocalDate startDate, LocalDate endDate) {
        return executeQuery(
            "SELECT te FROM TimesheetEntry te WHERE te.workDate >= ?1 AND te.workDate <= ?2",
            startDate, endDate);
    }

    @Override
    public List<TimesheetEntry> findEntriesByTaskInDateRange(Task task, LocalDate startDate, LocalDate endDate) {
        return executeQuery(
            "SELECT te FROM TimesheetEntry te WHERE te.task = ?1 AND te.workDate >= ?2 AND te.workDate <= ?3",
            task, startDate, endDate);
    }

    @Override
    public List<TimesheetEntry> findEntriesByUserInDateRange(User user, LocalDate startDate, LocalDate endDate) {
        return executeQuery(
            "SELECT te FROM TimesheetEntry te WHERE te.timesheet.user = ?1 AND te.workDate >= ?2 AND te.workDate <= ?3",
            user, startDate, endDate);
    }
}