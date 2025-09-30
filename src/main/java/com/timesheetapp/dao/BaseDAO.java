package com.timesheetapp.dao;

import java.util.List;
import java.util.Optional;

public interface BaseDAO<T, ID> {
    
    T save(T entity);
    
    Optional<T> findById(ID id);
    
    List<T> findAll();
    
    T update(T entity);
    
    void delete(ID id);

    void deleteEntity(T entity);
    
    boolean exists(ID id);
    
    long count();
}