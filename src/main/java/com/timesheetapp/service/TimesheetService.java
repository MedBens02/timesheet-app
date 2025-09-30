package com.timesheetapp.service;

import com.timesheetapp.dao.TimesheetDAO;
import com.timesheetapp.dao.TimesheetEntryDAO;
import com.timesheetapp.dao.TaskDAO;
import com.timesheetapp.dao.impl.TimesheetDAOImpl;
import com.timesheetapp.dao.impl.TimesheetEntryDAOImpl;
import com.timesheetapp.dao.impl.TaskDAOImpl;
import com.timesheetapp.entity.Task;
import com.timesheetapp.entity.Timesheet;
import com.timesheetapp.entity.TimesheetEntry;
import com.timesheetapp.entity.User;
import com.timesheetapp.util.ValidationUtil;
import jakarta.ejb.Stateless;
import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Stateless
public class TimesheetService {

    private final TimesheetDAO timesheetDAO;
    private final TimesheetEntryDAO timesheetEntryDAO;
    private final TaskDAO taskDAO;

    public TimesheetService() {
        this.timesheetDAO = new TimesheetDAOImpl();
        this.timesheetEntryDAO = new TimesheetEntryDAOImpl();
        this.taskDAO = new TaskDAOImpl();
    }

    // Timesheet creation

    public Timesheet createTimesheet(User user, LocalDate weekStartDate) {
        if (user == null) {
            throw new IllegalArgumentException("User is required");
        }

        if (weekStartDate == null) {
            throw new IllegalArgumentException("Week start date is required");
        }

        // Ensure week starts on Monday
        LocalDate adjustedStartDate = getWeekStartDate(weekStartDate);
        LocalDate weekEndDate = adjustedStartDate.plusDays(6);

        // Check if timesheet already exists for this week
        Optional<Timesheet> existing = timesheetDAO.findByUserAndWeek(user, adjustedStartDate);
        if (existing.isPresent()) {
            throw new IllegalStateException("Timesheet already exists for week starting " + adjustedStartDate);
        }

        Timesheet timesheet = new Timesheet(user, adjustedStartDate, weekEndDate);
        timesheet.setStatus(Timesheet.TimesheetStatus.DRAFT);

        return timesheetDAO.save(timesheet);
    }

    public Timesheet getOrCreateTimesheet(User user, LocalDate weekStartDate) {
        LocalDate adjustedStartDate = getWeekStartDate(weekStartDate);
        Optional<Timesheet> existing = timesheetDAO.findByUserAndWeek(user, adjustedStartDate);

        if (existing.isPresent()) {
            return existing.get();
        }

        return createTimesheet(user, adjustedStartDate);
    }

    // Timesheet retrieval

    public Timesheet getTimesheetById(Long id) {
        return timesheetDAO.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Timesheet not found with id: " + id));
    }

    public Optional<Timesheet> findTimesheetById(Long id) {
        return timesheetDAO.findById(id);
    }

    public List<Timesheet> getAllTimesheets() {
        return timesheetDAO.findAll();
    }

    public List<Timesheet> getTimesheetsByUser(User user) {
        return timesheetDAO.findByUser(user);
    }

    public Optional<Timesheet> getTimesheetByUserAndWeek(User user, LocalDate weekStartDate) {
        LocalDate adjustedStartDate = getWeekStartDate(weekStartDate);
        return timesheetDAO.findByUserAndWeek(user, adjustedStartDate);
    }

    public List<Timesheet> getTimesheetsByStatus(Timesheet.TimesheetStatus status) {
        return timesheetDAO.findByStatus(status);
    }

    public List<Timesheet> getSubmittedTimesheets() {
        return timesheetDAO.findSubmittedTimesheets();
    }

    public List<Timesheet> getValidatedTimesheets() {
        return timesheetDAO.findValidatedTimesheets();
    }

    public List<Timesheet> getRejectedTimesheets() {
        return timesheetDAO.findRejectedTimesheets();
    }

    public List<Timesheet> getDraftTimesheets() {
        return timesheetDAO.findDraftTimesheets();
    }

    public List<Timesheet> getTimesheetsForValidation() {
        return timesheetDAO.findTimesheetsForValidation();
    }

    public List<Timesheet> getTimesheetsByValidator(User validator) {
        return timesheetDAO.findTimesheetsByValidator(validator);
    }

    public List<Timesheet> getTimesheetsInDateRange(User user, LocalDate startDate, LocalDate endDate) {
        if (!ValidationUtil.isValidDateRange(startDate, endDate)) {
            throw new IllegalArgumentException("Invalid date range");
        }
        return timesheetDAO.findByUserAndDateRange(user, startDate, endDate);
    }

    // Timesheet entry management

    public TimesheetEntry addTimesheetEntry(Long timesheetId, Task task, LocalDate workDate,
                                           BigDecimal hoursWorked, String description) {
        Timesheet timesheet = getTimesheetById(timesheetId);

        // Validation
        if (!timesheet.isEditable()) {
            throw new IllegalStateException("Timesheet is not editable. Status: " + timesheet.getStatus());
        }

        if (task == null) {
            throw new IllegalArgumentException("Task is required");
        }

        if (workDate == null) {
            throw new IllegalArgumentException("Work date is required");
        }

        if (!isDateInWeek(workDate, timesheet.getWeekStartDate(), timesheet.getWeekEndDate())) {
            throw new IllegalArgumentException("Work date must be within the timesheet week");
        }

        if (hoursWorked == null || hoursWorked.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Hours worked must be positive");
        }

        if (hoursWorked.compareTo(new BigDecimal("24")) > 0) {
            throw new IllegalArgumentException("Hours worked cannot exceed 24 hours per day");
        }

        // Check if entry already exists for this task and date
        Optional<TimesheetEntry> existing = timesheetEntryDAO.findByTimesheetAndTaskAndDate(timesheet, task, workDate);
        if (existing.isPresent()) {
            throw new IllegalStateException("Entry already exists for this task and date. Use update instead.");
        }

        // Create entry
        TimesheetEntry entry = new TimesheetEntry(timesheet, task, workDate, hoursWorked, description);
        TimesheetEntry savedEntry = timesheetEntryDAO.save(entry);

        // Recalculate timesheet totals
        recalculateTimesheetTotals(timesheetId);

        return savedEntry;
    }

    public TimesheetEntry updateTimesheetEntry(Long entryId, BigDecimal hoursWorked, String description) {
        TimesheetEntry entry = timesheetEntryDAO.findById(entryId)
            .orElseThrow(() -> new IllegalArgumentException("Timesheet entry not found"));

        if (!entry.isEditable()) {
            throw new IllegalStateException("Timesheet entry is not editable");
        }

        if (hoursWorked != null) {
            if (hoursWorked.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Hours worked must be positive");
            }
            if (hoursWorked.compareTo(new BigDecimal("24")) > 0) {
                throw new IllegalArgumentException("Hours worked cannot exceed 24 hours per day");
            }
            entry.setHoursWorked(hoursWorked);
        }

        if (description != null) {
            entry.setDescription(description);
        }

        TimesheetEntry updatedEntry = timesheetEntryDAO.update(entry);

        // Recalculate timesheet totals
        recalculateTimesheetTotals(entry.getTimesheet().getId());

        return updatedEntry;
    }

    public void deleteTimesheetEntry(Long entryId) {
        TimesheetEntry entry = timesheetEntryDAO.findById(entryId)
            .orElseThrow(() -> new IllegalArgumentException("Timesheet entry not found"));

        if (!entry.isEditable()) {
            throw new IllegalStateException("Timesheet entry cannot be deleted");
        }

        Long timesheetId = entry.getTimesheet().getId();
        timesheetEntryDAO.delete(entryId);

        // Recalculate timesheet totals
        recalculateTimesheetTotals(timesheetId);
    }

    public List<TimesheetEntry> getTimesheetEntries(Long timesheetId) {
        Timesheet timesheet = getTimesheetById(timesheetId);
        return timesheetEntryDAO.findByTimesheet(timesheet);
    }

    // Timesheet workflow

    public Timesheet submitTimesheet(Long timesheetId) {
        Timesheet timesheet = getTimesheetById(timesheetId);

        if (!timesheet.isEditable()) {
            throw new IllegalStateException("Timesheet cannot be submitted. Current status: " + timesheet.getStatus());
        }

        List<TimesheetEntry> entries = timesheetEntryDAO.findByTimesheet(timesheet);
        if (entries.isEmpty()) {
            throw new IllegalStateException("Cannot submit empty timesheet");
        }

        // Recalculate totals before submission
        recalculateTimesheetTotals(timesheetId);

        timesheet.setStatus(Timesheet.TimesheetStatus.SUBMITTED);
        timesheet.setSubmittedAt(LocalDateTime.now());

        return timesheetDAO.update(timesheet);
    }

    public Timesheet validateTimesheet(Long timesheetId, User validator) {
        Timesheet timesheet = getTimesheetById(timesheetId);

        if (validator == null) {
            throw new IllegalArgumentException("Validator is required");
        }

        if (!validator.canManageProjects() && validator.getRole() != User.UserRole.ADMIN) {
            throw new IllegalArgumentException("User does not have permission to validate timesheets");
        }

        if (timesheet.getStatus() != Timesheet.TimesheetStatus.SUBMITTED) {
            throw new IllegalStateException("Only submitted timesheets can be validated. Current status: " + timesheet.getStatus());
        }

        // Validate all entries
        List<TimesheetEntry> entries = timesheetEntryDAO.findByTimesheet(timesheet);
        for (TimesheetEntry entry : entries) {
            entry.setIsValidated(true);
            entry.setValidatedBy(validator);
            entry.setValidatedAt(LocalDateTime.now());
            timesheetEntryDAO.update(entry);
        }

        timesheet.setStatus(Timesheet.TimesheetStatus.VALIDATED);
        timesheet.setValidatedBy(validator);
        timesheet.setValidatedAt(LocalDateTime.now());
        timesheet.setRejectionReason(null);

        return timesheetDAO.update(timesheet);
    }

    public Timesheet rejectTimesheet(Long timesheetId, User validator, String rejectionReason) {
        Timesheet timesheet = getTimesheetById(timesheetId);

        if (validator == null) {
            throw new IllegalArgumentException("Validator is required");
        }

        if (!validator.canManageProjects() && validator.getRole() != User.UserRole.ADMIN) {
            throw new IllegalArgumentException("User does not have permission to reject timesheets");
        }

        if (timesheet.getStatus() != Timesheet.TimesheetStatus.SUBMITTED) {
            throw new IllegalStateException("Only submitted timesheets can be rejected. Current status: " + timesheet.getStatus());
        }

        if (!ValidationUtil.isNotEmpty(rejectionReason)) {
            throw new IllegalArgumentException("Rejection reason is required");
        }

        timesheet.setStatus(Timesheet.TimesheetStatus.REJECTED);
        timesheet.setValidatedBy(validator);
        timesheet.setValidatedAt(LocalDateTime.now());
        timesheet.setRejectionReason(rejectionReason);

        return timesheetDAO.update(timesheet);
    }

    public Timesheet reopenTimesheet(Long timesheetId) {
        Timesheet timesheet = getTimesheetById(timesheetId);

        if (timesheet.getStatus() == Timesheet.TimesheetStatus.VALIDATED) {
            throw new IllegalStateException("Cannot reopen validated timesheet");
        }

        if (timesheet.getStatus() == Timesheet.TimesheetStatus.DRAFT) {
            throw new IllegalStateException("Timesheet is already in draft status");
        }

        timesheet.setStatus(Timesheet.TimesheetStatus.DRAFT);
        timesheet.setSubmittedAt(null);
        timesheet.setRejectionReason(null);

        return timesheetDAO.update(timesheet);
    }

    // Timesheet calculations

    public void recalculateTimesheetTotals(Long timesheetId) {
        Timesheet timesheet = getTimesheetById(timesheetId);
        List<TimesheetEntry> entries = timesheetEntryDAO.findByTimesheet(timesheet);

        if (entries.isEmpty()) {
            timesheet.setTotalHours(BigDecimal.ZERO);
            timesheet.setOvertimeHours(BigDecimal.ZERO);
            timesheet.setTotalRegularPay(BigDecimal.ZERO);
            timesheet.setTotalOvertimePay(BigDecimal.ZERO);
            timesheet.setTotalPay(BigDecimal.ZERO);
            timesheetDAO.update(timesheet);
            return;
        }

        // Calculate total hours
        BigDecimal totalHours = entries.stream()
            .map(TimesheetEntry::getHoursWorked)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        // Calculate overtime (hours over 40 per week)
        BigDecimal regularHoursLimit = new BigDecimal("40");
        BigDecimal regularHours = totalHours.min(regularHoursLimit);
        BigDecimal overtimeHours = totalHours.subtract(regularHours).max(BigDecimal.ZERO);

        // Calculate pay
        BigDecimal hourlyRate = timesheet.getUser().getHourlyRate();
        BigDecimal overtimeRate = hourlyRate.multiply(new BigDecimal("1.25"));

        BigDecimal regularPay = regularHours.multiply(hourlyRate);
        BigDecimal overtimePay = overtimeHours.multiply(overtimeRate);
        BigDecimal totalPay = regularPay.add(overtimePay);

        // Update timesheet
        timesheet.setTotalHours(totalHours);
        timesheet.setOvertimeHours(overtimeHours);
        timesheet.setTotalRegularPay(regularPay);
        timesheet.setTotalOvertimePay(overtimePay);
        timesheet.setTotalPay(totalPay);

        timesheetDAO.update(timesheet);
    }

    // Reporting methods

    public BigDecimal calculateUserTotalHours(User user, LocalDate startDate, LocalDate endDate) {
        List<Timesheet> timesheets = timesheetDAO.findByUserAndDateRange(user, startDate, endDate);
        return timesheets.stream()
            .filter(t -> t.getStatus() == Timesheet.TimesheetStatus.VALIDATED)
            .map(Timesheet::getTotalHours)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public BigDecimal calculateUserTotalPay(User user, LocalDate startDate, LocalDate endDate) {
        List<Timesheet> timesheets = timesheetDAO.findByUserAndDateRange(user, startDate, endDate);
        return timesheets.stream()
            .filter(t -> t.getStatus() == Timesheet.TimesheetStatus.VALIDATED)
            .map(Timesheet::getTotalPay)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public List<Timesheet> getUserTimesheetsForMonth(User user, int year, int month) {
        return timesheetDAO.findTimesheetsInMonth(year, month).stream()
            .filter(t -> t.getUser().getId().equals(user.getId()))
            .toList();
    }

    // Delete operations

    public void deleteTimesheet(Long timesheetId) {
        Timesheet timesheet = getTimesheetById(timesheetId);

        if (timesheet.getStatus() == Timesheet.TimesheetStatus.VALIDATED) {
            throw new IllegalStateException("Cannot delete validated timesheet");
        }

        if (timesheet.getStatus() == Timesheet.TimesheetStatus.SUBMITTED) {
            throw new IllegalStateException("Cannot delete submitted timesheet. Reject it first.");
        }

        timesheetDAO.delete(timesheetId);
    }

    // Utility methods

    public LocalDate getWeekStartDate(LocalDate date) {
        // Adjust to Monday (start of week)
        DayOfWeek dayOfWeek = date.getDayOfWeek();
        int daysToSubtract = dayOfWeek.getValue() - DayOfWeek.MONDAY.getValue();
        return date.minusDays(daysToSubtract);
    }

    public LocalDate getCurrentWeekStartDate() {
        return getWeekStartDate(LocalDate.now());
    }

    public boolean isDateInWeek(LocalDate date, LocalDate weekStart, LocalDate weekEnd) {
        return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
    }

    public boolean canUserEditTimesheet(User user, Timesheet timesheet) {
        if (user == null || timesheet == null) {
            return false;
        }

        // User can only edit their own timesheets
        if (!user.getId().equals(timesheet.getUser().getId())) {
            return false;
        }

        // Timesheet must be editable
        return timesheet.isEditable();
    }

    public boolean canUserValidateTimesheet(User user, Timesheet timesheet) {
        if (user == null || timesheet == null) {
            return false;
        }

        // Admin can validate any timesheet
        if (user.getRole() == User.UserRole.ADMIN) {
            return true;
        }

        // Project managers can validate timesheets for tasks in their projects
        if (user.getRole() == User.UserRole.PROJECT_MANAGER) {
            return timesheet.getStatus() == Timesheet.TimesheetStatus.SUBMITTED;
        }

        return false;
    }

    public long getTotalTimesheetCount() {
        return timesheetDAO.count();
    }
}