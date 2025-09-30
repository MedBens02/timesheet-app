package com.timesheetapp.dao;

import com.timesheetapp.entity.Timesheet;
import com.timesheetapp.entity.User;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface TimesheetDAO extends BaseDAO<Timesheet, Long> {
    
    List<Timesheet> findByUser(User user);
    
    List<Timesheet> findByStatus(Timesheet.TimesheetStatus status);
    
    Optional<Timesheet> findByUserAndWeek(User user, LocalDate weekStartDate);
    
    List<Timesheet> findByUserAndDateRange(User user, LocalDate startDate, LocalDate endDate);
    
    List<Timesheet> findSubmittedTimesheets();
    
    List<Timesheet> findValidatedTimesheets();
    
    List<Timesheet> findRejectedTimesheets();
    
    List<Timesheet> findDraftTimesheets();
    
    List<Timesheet> findTimesheetsForValidation();
    
    List<Timesheet> findTimesheetsByValidator(User validator);
    
    List<Timesheet> findTimesheetsInWeek(LocalDate weekStartDate);
    
    List<Timesheet> findTimesheetsInMonth(int year, int month);
    
    List<Timesheet> findTimesheetsInYear(int year);
}