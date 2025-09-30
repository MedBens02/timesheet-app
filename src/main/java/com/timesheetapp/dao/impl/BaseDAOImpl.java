package com.timesheetapp.dao.impl;

import com.timesheetapp.dao.BaseDAO;
import com.timesheetapp.util.EntityManagerUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.lang.reflect.ParameterizedType;
import java.util.List;
import java.util.Optional;

public abstract class BaseDAOImpl<T, ID> implements BaseDAO<T, ID> {
    
    protected final Class<T> entityClass;
    
    @SuppressWarnings("unchecked")
    public BaseDAOImpl() {
        this.entityClass = (Class<T>) ((ParameterizedType) getClass()
                .getGenericSuperclass()).getActualTypeArguments()[0];
    }
    
    @Override
    public T save(T entity) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            em.persist(entity);
            transaction.commit();
            return entity;
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }
            throw new RuntimeException("Error saving entity: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public Optional<T> findById(ID id) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            T entity = em.find(entityClass, id);
            return Optional.ofNullable(entity);
        } catch (Exception e) {
            throw new RuntimeException("Error finding entity by id: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public List<T> findAll() {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<T> query = em.createQuery(
                "SELECT e FROM " + entityClass.getSimpleName() + " e", entityClass);
            return query.getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error finding all entities: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public T update(T entity) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            T updatedEntity = em.merge(entity);
            transaction.commit();
            return updatedEntity;
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }
            throw new RuntimeException("Error updating entity: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public void delete(ID id) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            T entity = em.find(entityClass, id);
            if (entity != null) {
                em.remove(entity);
            }
            transaction.commit();
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }
            throw new RuntimeException("Error deleting entity: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public void deleteEntity(T entity) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        EntityTransaction transaction = em.getTransaction();
        try {
            transaction.begin();
            T managedEntity = em.merge(entity);
            em.remove(managedEntity);
            transaction.commit();
        } catch (Exception e) {
            if (transaction.isActive()) {
                transaction.rollback();
            }
            throw new RuntimeException("Error deleting entity: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    @Override
    public boolean exists(ID id) {
        return findById(id).isPresent();
    }
    
    @Override
    public long count() {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<Long> query = em.createQuery(
                "SELECT COUNT(e) FROM " + entityClass.getSimpleName() + " e", Long.class);
            return query.getSingleResult();
        } catch (Exception e) {
            throw new RuntimeException("Error counting entities: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    protected List<T> executeQuery(String jpql, Object... parameters) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<T> query = em.createQuery(jpql, entityClass);
            for (int i = 0; i < parameters.length; i++) {
                query.setParameter(i + 1, parameters[i]);
            }
            return query.getResultList();
        } catch (Exception e) {
            throw new RuntimeException("Error executing query: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
    
    protected Optional<T> executeSingleResultQuery(String jpql, Object... parameters) {
        EntityManager em = EntityManagerUtil.getEntityManager();
        try {
            TypedQuery<T> query = em.createQuery(jpql, entityClass);
            for (int i = 0; i < parameters.length; i++) {
                query.setParameter(i + 1, parameters[i]);
            }
            List<T> results = query.getResultList();
            return results.isEmpty() ? Optional.empty() : Optional.of(results.get(0));
        } catch (Exception e) {
            throw new RuntimeException("Error executing single result query: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }
}