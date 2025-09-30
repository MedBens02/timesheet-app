package com.timesheetapp.dao;

import com.timesheetapp.entity.User;
import java.util.List;
import java.util.Optional;

public interface UserDAO extends BaseDAO<User, Long> {
    
    Optional<User> findByUsername(String username);
    
    Optional<User> findByEmail(String email);
    
    List<User> findByRole(User.UserRole role);
    
    List<User> findActiveUsers();
    
    List<User> findInactiveUsers();
    
    boolean existsByUsername(String username);
    
    boolean existsByEmail(String email);
    
    List<User> findProjectManagers();
    
    List<User> findEmployees();
    
    List<User> searchByName(String searchTerm);
}