package com.timesheetapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "projects")
public class Project {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    @NotBlank(message = "Project name is required")
    @Size(max = 100, message = "Project name cannot exceed 100 characters")
    private String name;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manager_id", nullable = false)
    @NotNull(message = "Project manager is required")
    private User manager;
    
    @Column(name = "estimated_hours")
    @Min(value = 0, message = "Estimated hours must be positive")
    private Integer estimatedHours = 0;
    
    @Column(name = "estimated_cost", precision = 12, scale = 2)
    @DecimalMin(value = "0.0", message = "Estimated cost must be positive")
    private BigDecimal estimatedCost = BigDecimal.ZERO;
    
    @Column(name = "actual_hours", precision = 8, scale = 2)
    @DecimalMin(value = "0.0", message = "Actual hours must be positive")
    private BigDecimal actualHours = BigDecimal.ZERO;
    
    @Column(name = "actual_cost", precision = 12, scale = 2)
    @DecimalMin(value = "0.0", message = "Actual cost must be positive")
    private BigDecimal actualCost = BigDecimal.ZERO;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProjectStatus status = ProjectStatus.PLANNING;
    
    @Column(name = "start_date")
    private LocalDate startDate;
    
    @Column(name = "end_date")
    private LocalDate endDate;
    
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
    
    @OneToMany(mappedBy = "project", fetch = FetchType.LAZY, cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Task> tasks;
    
    public enum ProjectStatus {
        PLANNING, ACTIVE, ON_HOLD, COMPLETED, CANCELLED
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    public Project() {}
    
    public Project(String name, String description, User manager) {
        this.name = name;
        this.description = description;
        this.manager = manager;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public User getManager() { return manager; }
    public void setManager(User manager) { this.manager = manager; }
    
    public Integer getEstimatedHours() { return estimatedHours; }
    public void setEstimatedHours(Integer estimatedHours) { this.estimatedHours = estimatedHours; }
    
    public BigDecimal getEstimatedCost() { return estimatedCost; }
    public void setEstimatedCost(BigDecimal estimatedCost) { this.estimatedCost = estimatedCost; }
    
    public BigDecimal getActualHours() { return actualHours; }
    public void setActualHours(BigDecimal actualHours) { this.actualHours = actualHours; }
    
    public BigDecimal getActualCost() { return actualCost; }
    public void setActualCost(BigDecimal actualCost) { this.actualCost = actualCost; }
    
    public ProjectStatus getStatus() { return status; }
    public void setStatus(ProjectStatus status) { this.status = status; }
    
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    
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
    
    public List<Task> getTasks() { return tasks; }
    public void setTasks(List<Task> tasks) { this.tasks = tasks; }
    
    public double getProgressPercentage() {
        if (estimatedHours == null || estimatedHours == 0) {
            return 0.0;
        }
        return (actualHours.doubleValue() / estimatedHours) * 100.0;
    }
    
    public boolean isOverBudget() {
        return actualCost.compareTo(estimatedCost) > 0;
    }
    
    public boolean isActive() {
        return status == ProjectStatus.ACTIVE;
    }
    
    public boolean isCompleted() {
        return status == ProjectStatus.COMPLETED;
    }
    
    @Override
    public String toString() {
        return "Project{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", status=" + status +
                ", manager=" + (manager != null ? manager.getUsername() : "null") +
                '}';
    }
}