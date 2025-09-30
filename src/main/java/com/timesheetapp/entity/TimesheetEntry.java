package com.timesheetapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "timesheet_entries")
public class TimesheetEntry {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "timesheet_id", nullable = false)
    @NotNull(message = "Timesheet is required")
    private Timesheet timesheet;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id", nullable = false)
    @NotNull(message = "Task is required")
    private Task task;
    
    @Column(name = "work_date", nullable = false)
    @NotNull(message = "Work date is required")
    private LocalDate workDate;
    
    @Column(name = "hours_worked", precision = 5, scale = 2, nullable = false)
    @NotNull(message = "Hours worked is required")
    @DecimalMin(value = "0.0", message = "Hours worked must be positive")
    @DecimalMax(value = "24.0", message = "Hours worked cannot exceed 24 hours per day")
    private BigDecimal hoursWorked = BigDecimal.ZERO;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "is_validated")
    private Boolean isValidated = false;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "validated_by")
    private User validatedBy;
    
    @Column(name = "validated_at")
    private LocalDateTime validatedAt;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        if (isValidated && validatedAt == null) {
            validatedAt = LocalDateTime.now();
        }
    }
    
    public TimesheetEntry() {}
    
    public TimesheetEntry(Timesheet timesheet, Task task, LocalDate workDate, BigDecimal hoursWorked) {
        this.timesheet = timesheet;
        this.task = task;
        this.workDate = workDate;
        this.hoursWorked = hoursWorked;
    }
    
    public TimesheetEntry(Timesheet timesheet, Task task, LocalDate workDate, BigDecimal hoursWorked, String description) {
        this(timesheet, task, workDate, hoursWorked);
        this.description = description;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Timesheet getTimesheet() { return timesheet; }
    public void setTimesheet(Timesheet timesheet) { this.timesheet = timesheet; }
    
    public Task getTask() { return task; }
    public void setTask(Task task) { this.task = task; }
    
    public LocalDate getWorkDate() { return workDate; }
    public void setWorkDate(LocalDate workDate) { this.workDate = workDate; }
    
    public BigDecimal getHoursWorked() { return hoursWorked; }
    public void setHoursWorked(BigDecimal hoursWorked) { this.hoursWorked = hoursWorked; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public Boolean getIsValidated() { return isValidated; }
    public void setIsValidated(Boolean isValidated) { this.isValidated = isValidated; }
    
    public User getValidatedBy() { return validatedBy; }
    public void setValidatedBy(User validatedBy) { this.validatedBy = validatedBy; }
    
    public LocalDateTime getValidatedAt() { return validatedAt; }
    public void setValidatedAt(LocalDateTime validatedAt) { this.validatedAt = validatedAt; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public boolean isValidated() {
        return Boolean.TRUE.equals(isValidated);
    }
    
    public boolean isEditable() {
        return !isValidated() && (timesheet != null && timesheet.isEditable());
    }
    
    public String getTaskName() {
        return task != null ? task.getName() : "";
    }
    
    public String getProjectName() {
        return task != null && task.getProject() != null ? task.getProject().getName() : "";
    }
    
    public BigDecimal getCalculatedPay() {
        if (timesheet == null || timesheet.getUser() == null) {
            return BigDecimal.ZERO;
        }
        
        BigDecimal hourlyRate = timesheet.getUser().getHourlyRate();
        
        LocalDate weekStart = timesheet.getWeekStartDate();
        if (weekStart == null) {
            return hoursWorked.multiply(hourlyRate);
        }
        
        BigDecimal weeklyHours = timesheet.getTotalHours();
        BigDecimal regularHoursLimit = new BigDecimal("40");
        
        if (weeklyHours.compareTo(regularHoursLimit) > 0) {
            BigDecimal overtimeRate = hourlyRate.multiply(new BigDecimal("1.25"));
            return hoursWorked.multiply(overtimeRate);
        }
        
        return hoursWorked.multiply(hourlyRate);
    }
    
    @Override
    public String toString() {
        return "TimesheetEntry{" +
                "id=" + id +
                ", workDate=" + workDate +
                ", hoursWorked=" + hoursWorked +
                ", task=" + (task != null ? task.getName() : "null") +
                ", isValidated=" + isValidated +
                '}';
    }
}