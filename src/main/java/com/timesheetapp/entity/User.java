package com.timesheetapp.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users")
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false, length = 50)
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;
    
    @Column(unique = true, nullable = false, length = 100)
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @Column(name = "password_hash", nullable = false)
    @NotBlank(message = "Password is required")
    private String passwordHash;
    
    @Column(name = "first_name", nullable = false, length = 50)
    @NotBlank(message = "First name is required")
    private String firstName;
    
    @Column(name = "last_name", nullable = false, length = 50)
    @NotBlank(message = "Last name is required")
    private String lastName;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserRole role = UserRole.EMPLOYEE;
    
    @Column(name = "hourly_rate", precision = 10, scale = 2)
    @DecimalMin(value = "0.0", message = "Hourly rate must be positive")
    private BigDecimal hourlyRate = BigDecimal.ZERO;
    
    @Column(name = "is_active")
    private Boolean isActive = true;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @OneToMany(mappedBy = "manager", fetch = FetchType.LAZY)
    private List<Project> managedProjects;
    
    @OneToMany(mappedBy = "assignedTo", fetch = FetchType.LAZY)
    private List<Task> assignedTasks;
    
    @OneToMany(mappedBy = "user", fetch = FetchType.LAZY)
    private List<Timesheet> timesheets;
    
    public enum UserRole {
        EMPLOYEE, PROJECT_MANAGER, ADMIN
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
    
    public User() {}
    
    public User(String username, String email, String firstName, String lastName, UserRole role) {
        this.username = username;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.role = role;
    }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public UserRole getRole() { return role; }
    public void setRole(UserRole role) { this.role = role; }
    
    public BigDecimal getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(BigDecimal hourlyRate) { this.hourlyRate = hourlyRate; }
    
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public List<Project> getManagedProjects() { return managedProjects; }
    public void setManagedProjects(List<Project> managedProjects) { this.managedProjects = managedProjects; }
    
    public List<Task> getAssignedTasks() { return assignedTasks; }
    public void setAssignedTasks(List<Task> assignedTasks) { this.assignedTasks = assignedTasks; }
    
    public List<Timesheet> getTimesheets() { return timesheets; }
    public void setTimesheets(List<Timesheet> timesheets) { this.timesheets = timesheets; }
    
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    public boolean isAdmin() {
        return role == UserRole.ADMIN;
    }
    
    public boolean isProjectManager() {
        return role == UserRole.PROJECT_MANAGER;
    }
    
    public boolean isEmployee() {
        return role == UserRole.EMPLOYEE;
    }

    public boolean canManageProjects() {
        return role == UserRole.PROJECT_MANAGER || role == UserRole.ADMIN;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", role=" + role +
                '}';
    }
}