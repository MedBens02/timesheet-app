package com.timesheetapp.dao.impl;

import com.timesheetapp.dao.UserDAO;
import com.timesheetapp.entity.User;
import com.timesheetapp.util.EntityManagerUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.TypedQuery;
import java.util.List;
import java.util.Optional;

public class UserDAOImpl extends BaseDAOImpl<User, Long> implements UserDAO {
    
    @Override
    public Optional<User> findByUsername(String username) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.username = :username", User.class);
            query.setParameter("username", username);
            return Optional.of(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        } catch (Exception e) {
            throw new RuntimeException("Error finding user by username: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public Optional<User> findByEmail(String email) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                "SELECT u FROM User u WHERE u.email = :email", User.class);
            query.setParameter("email", email);
            return Optional.of(query.getSingleResult());
        } catch (NoResultException e) {
            return Optional.empty();
        } catch (Exception e) {
            throw new RuntimeException("Error finding user by email: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public List<User> findByRole(User.UserRole role) {
        return executeQuery("SELECT u FROM User u WHERE u.role = ?1", role);
    }
    
    @Override
    public List<User> findActiveUsers() {
        return executeQuery("SELECT u FROM User u WHERE u.isActive = true");
    }
    
    @Override
    public List<User> findInactiveUsers() {
        return executeQuery("SELECT u FROM User u WHERE u.isActive = false");
    }
    
    @Override
    public boolean existsByUsername(String username) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(u) FROM User u WHERE u.username = :username", Long.class);
            query.setParameter("username", username);
            return query.getSingleResult() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error checking username existence: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public boolean existsByEmail(String email) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(u) FROM User u WHERE u.email = :email", Long.class);
            query.setParameter("email", email);
            return query.getSingleResult() > 0;
        } catch (Exception e) {
            throw new RuntimeException("Error checking email existence: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public List<User> findProjectManagers() {
        return findByRole(User.UserRole.PROJECT_MANAGER);
    }
    
    @Override
    public List<User> findEmployees() {
        return findByRole(User.UserRole.EMPLOYEE);
    }
    
    @Override
    public List<User> searchByName(String searchTerm) {
        String pattern = "%" + searchTerm.toLowerCase() + "%";
        return executeQuery(
            "SELECT u FROM User u WHERE LOWER(u.firstName) LIKE ?1 OR LOWER(u.lastName) LIKE ?1 " +
            "OR LOWER(CONCAT(u.firstName, ' ', u.lastName)) LIKE ?1", 
            pattern);
    }
}