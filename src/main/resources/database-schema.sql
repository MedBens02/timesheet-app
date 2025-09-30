-- Timesheet Management System Database Schema
-- Execute this script to create the database structure

CREATE DATABASE IF NOT EXISTS timesheet_db;
USE timesheet_db;

-- Drop tables in correct order to handle foreign key constraints
DROP TABLE IF EXISTS timesheet_entries;
DROP TABLE IF EXISTS timesheets;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS users;

-- Users table (employees, project managers, admins)
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('EMPLOYEE', 'PROJECT_MANAGER', 'ADMIN') NOT NULL DEFAULT 'EMPLOYEE',
    hourly_rate DECIMAL(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- Projects table
CREATE TABLE projects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_id BIGINT NOT NULL,
    estimated_hours INT DEFAULT 0,
    estimated_cost DECIMAL(12,2) DEFAULT 0.00,
    actual_hours DECIMAL(8,2) DEFAULT 0.00,
    actual_cost DECIMAL(12,2) DEFAULT 0.00,
    status ENUM('PLANNING', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'CANCELLED') DEFAULT 'PLANNING',
    start_date DATE,
    end_date DATE,
    is_validated BOOLEAN DEFAULT FALSE,
    validated_by BIGINT NULL,
    validated_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_manager (manager_id),
    INDEX idx_status (status),
    INDEX idx_dates (start_date, end_date)
);

-- Tasks table
CREATE TABLE tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    project_id BIGINT NOT NULL,
    assigned_to BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    estimated_hours INT DEFAULT 0,
    actual_hours DECIMAL(8,2) DEFAULT 0.00,
    status ENUM('TODO', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'TODO',
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    due_date DATE,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_project (project_id),
    INDEX idx_assigned (assigned_to),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
);

-- Timesheets table (weekly timesheets)
CREATE TABLE timesheets (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    total_hours DECIMAL(8,2) DEFAULT 0.00,
    overtime_hours DECIMAL(8,2) DEFAULT 0.00,
    total_regular_pay DECIMAL(10,2) DEFAULT 0.00,
    total_overtime_pay DECIMAL(10,2) DEFAULT 0.00,
    total_pay DECIMAL(10,2) DEFAULT 0.00,
    status ENUM('DRAFT', 'SUBMITTED', 'VALIDATED', 'REJECTED') DEFAULT 'DRAFT',
    submitted_at TIMESTAMP NULL,
    validated_by BIGINT NULL,
    validated_at TIMESTAMP NULL,
    rejection_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_user_week (user_id, week_start_date),
    INDEX idx_user (user_id),
    INDEX idx_week (week_start_date),
    INDEX idx_status (status)
);

-- Timesheet entries table (daily task entries)
CREATE TABLE timesheet_entries (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    timesheet_id BIGINT NOT NULL,
    task_id BIGINT NOT NULL,
    work_date DATE NOT NULL,
    hours_worked DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    description TEXT,
    is_validated BOOLEAN DEFAULT FALSE,
    validated_by BIGINT NULL,
    validated_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (timesheet_id) REFERENCES timesheets(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE RESTRICT,
    FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY unique_entry (timesheet_id, task_id, work_date),
    INDEX idx_timesheet (timesheet_id),
    INDEX idx_task (task_id),
    INDEX idx_date (work_date),
    INDEX idx_validated (is_validated)
);

-- Insert default admin user (password: admin123)
INSERT INTO users (username, email, password_hash, first_name, last_name, role, hourly_rate, is_active) VALUES
('admin', 'admin@timesheet.com', '$2a$10$8K1p/a0dS.TXt0m.CQrh9eS3j4rI6X5nL2l3B4m8c9k4K1p/a0dSa', 'System', 'Administrator', 'ADMIN', 50.00, TRUE);

-- Insert sample project manager (password: manager123)
INSERT INTO users (username, email, password_hash, first_name, last_name, role, hourly_rate, is_active) VALUES
('jsmith', 'john.smith@company.com', '$2a$10$8K1p/a0dS.TXt0m.CQrh9eS3j4rI6X5nL2l3B4m8c9k4K1p/a0dSb', 'John', 'Smith', 'PROJECT_MANAGER', 45.00, TRUE);

-- Insert sample employee (password: employee123)
INSERT INTO users (username, email, password_hash, first_name, last_name, role, hourly_rate, is_active) VALUES
('mjohnson', 'mary.johnson@company.com', '$2a$10$8K1p/a0dS.TXt0m.CQrh9eS3j4rI6X5nL2l3B4m8c9k4K1p/a0dSc', 'Mary', 'Johnson', 'EMPLOYEE', 35.00, TRUE);

-- Insert sample project
INSERT INTO projects (name, description, manager_id, estimated_hours, estimated_cost, start_date, end_date) VALUES 
('Website Redesign', 'Complete redesign of company website with modern UI/UX', 2, 200, 9000.00, '2024-01-15', '2024-03-15');

-- Insert sample tasks
INSERT INTO tasks (project_id, assigned_to, name, description, estimated_hours, due_date) VALUES 
(1, 3, 'Frontend Development', 'Develop responsive frontend using modern frameworks', 80, '2024-02-15'),
(1, 3, 'Backend API', 'Create RESTful APIs for data management', 60, '2024-02-28'),
(1, 3, 'Testing & QA', 'Comprehensive testing and quality assurance', 40, '2024-03-10');

COMMIT;