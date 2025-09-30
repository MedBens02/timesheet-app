package com.timesheetapp.dao;

import com.timesheetapp.entity.TimesheetEntry;
import com.timesheetapp.entity.Timesheet;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.User;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface TimesheetEntryDAO extends BaseDAO<TimesheetEntry, Long> {
    
    List<TimesheetEntry> findByTimesheet(Timesheet timesheet);
    
    List<TimesheetEntry> findByTask(Task task);
    
    List<TimesheetEntry> findByWorkDate(LocalDate workDate);
    
    Optional<TimesheetEntry> findByTimesheetAndTaskAndDate(Timesheet timesheet, Task task, LocalDate workDate);
    
    List<TimesheetEntry> findByTimesheetAndTask(Timesheet timesheet, Task task);
    
    List<TimesheetEntry> findValidatedEntries();
    
    List<TimesheetEntry> findUnvalidatedEntries();
    
    List<TimesheetEntry> findEntriesForValidation();
    
    List<TimesheetEntry> findEntriesByValidator(User validator);
    
    List<TimesheetEntry> findEntriesInDateRange(LocalDate startDate, LocalDate endDate);
    
    List<TimesheetEntry> findEntriesByTaskInDateRange(Task task, LocalDate startDate, LocalDate endDate);
    
    List<TimesheetEntry> findEntriesByUserInDateRange(User user, LocalDate startDate, LocalDate endDate);
}