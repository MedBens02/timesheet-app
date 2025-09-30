package com.timesheetapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "timesheets")
public class Timesheet {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @NotNull(message = "User is required")
    private User user;
    
    @Column(name = "week_start_date", nullable = false)
    @NotNull(message = "Week start date is required")
    private LocalDate weekStartDate;
    
    @Column(name = "week_end_date", nullable = false)
    @NotNull(message = "Week end date is required")
    private LocalDate weekEndDate;
    
    @Column(name = "total_hours", precision = 8, scale = 2)
    @DecimalMin(value = "0.0", message = "Total hours must be positive")
    private BigDecimal totalHours = BigDecimal.ZERO;
    
    @Column(name = "overtime_hours", precision = 8, scale = 2)
    @DecimalMin(value = "0.0", message = "Overtime hours must be positive")
    private BigDecimal overtimeHours = BigDecimal.ZERO;
    
    @Column(name = "total_regular_pay", precision = 10, scale = 2)
    @DecimalMin(value = "0.0", message = "Regular pay must be positive")
    private BigDecimal totalRegularPay = BigDecimal.ZERO;
    
    @Column(name = "total_overtime_pay", precision = 10, scale = 2)
    @DecimalMin(value = "0.0", message = "Overtime pay must be positive")
    private BigDecimal totalOvertimePay = BigDecimal.ZERO;
    
    @Column(name = "total_pay", precision = 10, scale = 2)
    @DecimalMin(value = "0.0", message = "Total pay must be positive")
    private BigDecimal totalPay = BigDecimal.ZERO;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TimesheetStatus status = TimesheetStatus.DRAFT;
    
    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "validated_by")
    private User validatedBy;
    
    @Column(name = "validated_at")
    private LocalDateTime validatedAt;
    
    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @OneToMany(mappedBy = "timesheet", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    private List<TimesheetEntry> entries;
    
    public enum TimesheetStatus {
        DRAFT, SUBMITTED, VALIDATED, REJECTED
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        if (status == TimesheetStatus.SUBMITTED && submittedAt == null) {
            submittedAt = LocalDateTime.now();
        }
        if (status == TimesheetStatus.VALIDATED && validatedAt == null) {
            validatedAt = LocalDateTime.now();
        }
    }
    
    public Timesheet() {}
    
    public Timesheet(User user, LocalDate weekStartDate, LocalDate weekEndDate) {
        this.user = user;
        this.weekStartDate = weekStartDate;
        this.weekEndDate = weekEndDate;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    
    public LocalDate getWeekStartDate() { return weekStartDate; }
    public void setWeekStartDate(LocalDate weekStartDate) { this.weekStartDate = weekStartDate; }
    
    public LocalDate getWeekEndDate() { return weekEndDate; }
    public void setWeekEndDate(LocalDate weekEndDate) { this.weekEndDate = weekEndDate; }
    
    public BigDecimal getTotalHours() { return totalHours; }
    public void setTotalHours(BigDecimal totalHours) { this.totalHours = totalHours; }
    
    public BigDecimal getOvertimeHours() { return overtimeHours; }
    public void setOvertimeHours(BigDecimal overtimeHours) { this.overtimeHours = overtimeHours; }
    
    public BigDecimal getTotalRegularPay() { return totalRegularPay; }
    public void setTotalRegularPay(BigDecimal totalRegularPay) { this.totalRegularPay = totalRegularPay; }
    
    public BigDecimal getTotalOvertimePay() { return totalOvertimePay; }
    public void setTotalOvertimePay(BigDecimal totalOvertimePay) { this.totalOvertimePay = totalOvertimePay; }
    
    public BigDecimal getTotalPay() { return totalPay; }
    public void setTotalPay(BigDecimal totalPay) { this.totalPay = totalPay; }
    
    public TimesheetStatus getStatus() { return status; }
    public void setStatus(TimesheetStatus status) { this.status = status; }
    
    public LocalDateTime getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(LocalDateTime submittedAt) { this.submittedAt = submittedAt; }
    
    public User getValidatedBy() { return validatedBy; }
    public void setValidatedBy(User validatedBy) { this.validatedBy = validatedBy; }
    
    public LocalDateTime getValidatedAt() { return validatedAt; }
    public void setValidatedAt(LocalDateTime validatedAt) { this.validatedAt = validatedAt; }
    
    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public List<TimesheetEntry> getEntries() { return entries; }
    public void setEntries(List<TimesheetEntry> entries) { this.entries = entries; }
    
    public void calculateTotals() {
        if (entries == null || entries.isEmpty()) {
            return;
        }
        
        totalHours = entries.stream()
            .map(TimesheetEntry::getHoursWorked)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal regularHoursLimit = new BigDecimal("40");
        BigDecimal regularHours = totalHours.min(regularHoursLimit);
        overtimeHours = totalHours.subtract(regularHours).max(BigDecimal.ZERO);
        
        BigDecimal hourlyRate = user.getHourlyRate();
        totalRegularPay = regularHours.multiply(hourlyRate);
        totalOvertimePay = overtimeHours.multiply(hourlyRate).multiply(new BigDecimal("1.25"));
        totalPay = totalRegularPay.add(totalOvertimePay);
    }
    
    public boolean isEditable() {
        return status == TimesheetStatus.DRAFT || status == TimesheetStatus.REJECTED;
    }
    
    public boolean isSubmitted() {
        return status == TimesheetStatus.SUBMITTED;
    }
    
    public boolean isValidated() {
        return status == TimesheetStatus.VALIDATED;
    }
    
    public boolean isRejected() {
        return status == TimesheetStatus.REJECTED;
    }
    
    public String getWeekDescription() {
        return "Week of " + weekStartDate + " to " + weekEndDate;
    }
    
    @Override
    public String toString() {
        return "Timesheet{" +
                "id=" + id +
                ", user=" + (user != null ? user.getUsername() : "null") +
                ", weekStartDate=" + weekStartDate +
                ", status=" + status +
                ", totalHours=" + totalHours +
                '}';
    }
}