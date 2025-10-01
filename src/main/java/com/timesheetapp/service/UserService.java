package com.timesheetapp.service;

import com.timesheetapp.dao.UserDAO;
import com.timesheetapp.dao.impl.UserDAOImpl;
import com.timesheetapp.entity.User;
import com.timesheetapp.util.PasswordUtil;
import com.timesheetapp.util.ValidationUtil;
import jakarta.ejb.Stateless;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Stateless
public class UserService {

    private final UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAOImpl();
    }

    // Authentication methods

    public Optional<User> authenticate(String username, String password) {
        if (!ValidationUtil.isNotEmpty(username) || !ValidationUtil.isNotEmpty(password)) {
            throw new IllegalArgumentException("Username and password are required");
        }

        Optional<User> userOpt = userDAO.findByUsername(username);
        if (userOpt.isEmpty()) {
            return Optional.empty();
        }

        User user = userOpt.get();
        if (user.getIsActive() == null || !user.getIsActive()) {
            throw new IllegalStateException("User account is inactive or not properly configured");
        }

        if (PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            return Optional.of(user);
        }

        return Optional.empty();
    }

    public boolean validateCredentials(String username, String password) {
        return authenticate(username, password).isPresent();
    }

    // User CRUD operations

    public User createUser(String username, String email, String password,
                          String firstName, String lastName, User.UserRole role, BigDecimal hourlyRate) {

        // Validate inputs
        if (!ValidationUtil.isNotEmpty(username) || !ValidationUtil.isValidUsername(username)) {
            throw new IllegalArgumentException("Invalid username");
        }

        if (!ValidationUtil.isValidEmail(email)) {
            throw new IllegalArgumentException("Invalid email address");
        }

        if (!PasswordUtil.isValidPassword(password)) {
            throw new IllegalArgumentException("Password does not meet strength requirements");
        }

        if (!ValidationUtil.isNotEmpty(firstName) || !ValidationUtil.isNotEmpty(lastName)) {
            throw new IllegalArgumentException("First name and last name are required");
        }

        if (role == null) {
            throw new IllegalArgumentException("User role is required");
        }

        // Check if username or email already exists
        if (userDAO.findByUsername(username).isPresent()) {
            throw new IllegalStateException("Username already exists");
        }

        if (userDAO.findByEmail(email).isPresent()) {
            throw new IllegalStateException("Email already exists");
        }

        // Create new user
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPasswordHash(PasswordUtil.hashPassword(password));
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setRole(role);
        user.setHourlyRate(hourlyRate != null ? hourlyRate : BigDecimal.ZERO);
        user.setIsActive(true);

        return userDAO.save(user);
    }

    public User getUserById(Long id) {
        return userDAO.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + id));
    }

    public Optional<User> findUserById(Long id) {
        return userDAO.findById(id);
    }

    // Alias methods for servlet convenience
    public Optional<User> findById(Long id) {
        return userDAO.findById(id);
    }

    public Optional<User> findUserByUsername(String username) {
        return userDAO.findByUsername(username);
    }

    public Optional<User> findUserByEmail(String email) {
        return userDAO.findByEmail(email);
    }

    public List<User> getAllUsers() {
        return userDAO.findAll();
    }

    public List<User> getActiveUsers() {
        return userDAO.findActiveUsers();
    }

    public List<User> getUsersByRole(User.UserRole role) {
        return userDAO.findByRole(role);
    }

    public List<User> findByRole(User.UserRole role) {
        return userDAO.findByRole(role);
    }

    public List<User> getEmployees() {
        return userDAO.findByRole(User.UserRole.EMPLOYEE);
    }

    public List<User> getProjectManagers() {
        return userDAO.findByRole(User.UserRole.PROJECT_MANAGER);
    }

    public List<User> getAdministrators() {
        return userDAO.findByRole(User.UserRole.ADMIN);
    }

    // User update operations

    public User updateUser(User user) {
        if (user.getId() == null || !userDAO.exists(user.getId())) {
            throw new IllegalArgumentException("User does not exist");
        }

        // Validate email if changed
        if (ValidationUtil.isNotEmpty(user.getEmail()) && !ValidationUtil.isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Invalid email address");
        }

        return userDAO.update(user);
    }

    public User updateUserProfile(Long userId, String firstName, String lastName, String email) {
        User user = getUserById(userId);

        if (ValidationUtil.isNotEmpty(firstName)) {
            user.setFirstName(firstName);
        }

        if (ValidationUtil.isNotEmpty(lastName)) {
            user.setLastName(lastName);
        }

        if (ValidationUtil.isNotEmpty(email)) {
            if (!ValidationUtil.isValidEmail(email)) {
                throw new IllegalArgumentException("Invalid email address");
            }

            // Check if email is already used by another user
            Optional<User> existingUser = userDAO.findByEmail(email);
            if (existingUser.isPresent() && !existingUser.get().getId().equals(userId)) {
                throw new IllegalStateException("Email already in use by another user");
            }

            user.setEmail(email);
        }

        return userDAO.update(user);
    }

    public User updateHourlyRate(Long userId, BigDecimal hourlyRate) {
        User user = getUserById(userId);

        if (hourlyRate == null || hourlyRate.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Hourly rate must be positive");
        }

        user.setHourlyRate(hourlyRate);
        return userDAO.update(user);
    }

    public User changePassword(Long userId, String currentPassword, String newPassword) {
        User user = getUserById(userId);

        // Verify current password
        if (!PasswordUtil.verifyPassword(currentPassword, user.getPasswordHash())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }

        // Validate new password
        if (!PasswordUtil.isValidPassword(newPassword)) {
            throw new IllegalArgumentException("New password does not meet strength requirements");
        }

        user.setPasswordHash(PasswordUtil.hashPassword(newPassword));
        return userDAO.update(user);
    }

    public User resetPassword(Long userId) {
        User user = getUserById(userId);
        String tempPassword = PasswordUtil.generateTemporaryPassword();
        user.setPasswordHash(PasswordUtil.hashPassword(tempPassword));
        userDAO.update(user);

        // In a real application, you would send this password via email
        // For now, we'll just return it in the user object (not recommended for production)
        System.out.println("Temporary password for user " + user.getUsername() + ": " + tempPassword);

        return user;
    }

    public User changeUserRole(Long userId, User.UserRole newRole) {
        User user = getUserById(userId);

        if (newRole == null) {
            throw new IllegalArgumentException("Role cannot be null");
        }

        user.setRole(newRole);
        return userDAO.update(user);
    }

    // User activation/deactivation

    public User activateUser(Long userId) {
        User user = getUserById(userId);
        user.setIsActive(true);
        return userDAO.update(user);
    }

    public User deactivateUser(Long userId) {
        User user = getUserById(userId);
        user.setIsActive(false);
        return userDAO.update(user);
    }

    // Delete operations

    public void deleteUser(Long userId) {
        if (!userDAO.exists(userId)) {
            throw new IllegalArgumentException("User not found with id: " + userId);
        }
        userDAO.delete(userId);
    }

    // Utility methods

    public boolean isUsernameAvailable(String username) {
        return userDAO.findByUsername(username).isEmpty();
    }

    public boolean isEmailAvailable(String email) {
        return userDAO.findByEmail(email).isEmpty();
    }

    public long getTotalUserCount() {
        return userDAO.count();
    }

    public boolean isAdmin(User user) {
        return user != null && user.getRole() == User.UserRole.ADMIN;
    }

    public boolean isProjectManager(User user) {
        return user != null && user.getRole() == User.UserRole.PROJECT_MANAGER;
    }

    public boolean isEmployee(User user) {
        return user != null && user.getRole() == User.UserRole.EMPLOYEE;
    }

    public boolean canManageUsers(User user) {
        return isAdmin(user);
    }

    public boolean canManageProjects(User user) {
        return isAdmin(user) || isProjectManager(user);
    }
}