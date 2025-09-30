package com.timesheetapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "tasks")
public class Task {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    @NotNull(message = "Project is required")
    private Project project;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_to", nullable = false)
    @NotNull(message = "Task must be assigned to a user")
    private User assignedTo;
    
    @Column(nullable = false, length = 100)
    @NotBlank(message = "Task name is required")
    @Size(max = 100, message = "Task name cannot exceed 100 characters")
    private String name;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "estimated_hours")
    @Min(value = 0, message = "Estimated hours must be positive")
    private Integer estimatedHours = 0;
    
    @Column(name = "actual_hours", precision = 8, scale = 2)
    @DecimalMin(value = "0.0", message = "Actual hours must be positive")
    private BigDecimal actualHours = BigDecimal.ZERO;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskStatus status = TaskStatus.TODO;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskPriority priority = TaskPriority.MEDIUM;
    
    @Column(name = "due_date")
    private LocalDate dueDate;
    
    @Column(name = "completed_at")
    private LocalDateTime completedAt;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @OneToMany(mappedBy = "task", fetch = FetchType.LAZY)
    private List<TimesheetEntry> timesheetEntries;
    
    public enum TaskStatus {
        TODO, IN_PROGRESS, COMPLETED, CANCELLED
    }
    
    public enum TaskPriority {
        LOW, MEDIUM, HIGH, URGENT
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
        if (status == TaskStatus.COMPLETED && completedAt == null) {
            completedAt = LocalDateTime.now();
        }
    }
    
    public Task() {}
    
    public Task(String name, String description, Project project, User assignedTo) {
        this.name = name;
        this.description = description;
        this.project = project;
        this.assignedTo = assignedTo;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Project getProject() { return project; }
    public void setProject(Project project) { this.project = project; }
    
    public User getAssignedTo() { return assignedTo; }
    public void setAssignedTo(User assignedTo) { this.assignedTo = assignedTo; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public Integer getEstimatedHours() { return estimatedHours; }
    public void setEstimatedHours(Integer estimatedHours) { this.estimatedHours = estimatedHours; }
    
    public BigDecimal getActualHours() { return actualHours; }
    public void setActualHours(BigDecimal actualHours) { this.actualHours = actualHours; }
    
    public TaskStatus getStatus() { return status; }
    public void setStatus(TaskStatus status) { this.status = status; }
    
    public TaskPriority getPriority() { return priority; }
    public void setPriority(TaskPriority priority) { this.priority = priority; }
    
    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }
    
    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public List<TimesheetEntry> getTimesheetEntries() { return timesheetEntries; }
    public void setTimesheetEntries(List<TimesheetEntry> timesheetEntries) { this.timesheetEntries = timesheetEntries; }
    
    public double getProgressPercentage() {
        if (estimatedHours == null || estimatedHours == 0) {
            return status == TaskStatus.COMPLETED ? 100.0 : 0.0;
        }
        return Math.min((actualHours.doubleValue() / estimatedHours) * 100.0, 100.0);
    }
    
    public boolean isOverdue() {
        return dueDate != null && dueDate.isBefore(LocalDate.now()) && status != TaskStatus.COMPLETED;
    }
    
    public boolean isCompleted() {
        return status == TaskStatus.COMPLETED;
    }
    
    public boolean isInProgress() {
        return status == TaskStatus.IN_PROGRESS;
    }
    
    public boolean isHighPriority() {
        return priority == TaskPriority.HIGH || priority == TaskPriority.URGENT;
    }
    
    @Override
    public String toString() {
        return "Task{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", status=" + status +
                ", priority=" + priority +
                ", assignedTo=" + (assignedTo != null ? assignedTo.getUsername() : "null") +
                '}';
    }
}