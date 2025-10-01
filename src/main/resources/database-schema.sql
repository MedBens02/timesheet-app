-- =====================================================================
-- Timesheet Management System - Complete Database Schema
-- =====================================================================
-- This script creates a fresh database with all tables and sample data
-- Execute this to set up or reset the entire database
-- =====================================================================

CREATE DATABASE IF NOT EXISTS timesheet_db;
USE timesheet_db;

-- Drop tables in correct order (respecting foreign key constraints)
DROP TABLE IF EXISTS timesheet_entries;
DROP TABLE IF EXISTS timesheets;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS project_employees;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS users;

-- =====================================================================
-- USERS TABLE
-- =====================================================================
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- PROJECTS TABLE
-- =====================================================================
CREATE TABLE projects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    client_name VARCHAR(200),
    manager_id BIGINT NOT NULL,
    estimated_hours INT DEFAULT 0,
    estimated_cost DECIMAL(12,2) DEFAULT 0.00,
    actual_hours DECIMAL(8,2) DEFAULT 0.00,
    actual_cost DECIMAL(12,2) DEFAULT 0.00,
    status ENUM('EN_ATTENTE', 'VALIDE', 'ACTIF', 'TERMINE', 'ABANDONNE') DEFAULT 'EN_ATTENTE',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- PROJECT_EMPLOYEES JUNCTION TABLE (Many-to-Many)
-- =====================================================================
CREATE TABLE project_employees (
    project_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (project_id, employee_id),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_project (project_id),
    INDEX idx_employee (employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TASKS TABLE
-- =====================================================================
CREATE TABLE tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    project_id BIGINT NOT NULL,
    assigned_to BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    estimated_hours INT DEFAULT 0,
    actual_hours DECIMAL(8,2) DEFAULT 0.00,
    status ENUM('EN_COURS', 'VALIDEE', 'REJETEE', 'ANNULEE') DEFAULT 'EN_COURS',
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    due_date DATE,
    completed_at TIMESTAMP NULL,
    is_validated BOOLEAN DEFAULT FALSE,
    validated_by BIGINT NULL,
    validated_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (validated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_project (project_id),
    INDEX idx_assigned (assigned_to),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TIMESHEETS TABLE
-- =====================================================================
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- TIMESHEET_ENTRIES TABLE
-- =====================================================================
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- SAMPLE DATA
-- =====================================================================

-- Insert default users (passwords: admin123, manager123, employee123)
INSERT INTO users (username, email, password_hash, first_name, last_name, role, hourly_rate, is_active) VALUES
('admin', 'admin@timesheet.com', '$2a$12$Cd.tIp5hnraQP5d3Wy3JvOi.dnuObcIiumvtMDipzzqpwzzlCxSs2', 'System', 'Administrator', 'ADMIN', 50.00, TRUE),
('jsmith', 'john.smith@company.com', '$2a$12$2M8.Skb0AXxH53A6slAn3.0KesWHyFfG9CYYRwzGe1qwyZey/kxfy', 'John', 'Smith', 'PROJECT_MANAGER', 45.00, TRUE),
('mjohnson', 'mary.johnson@company.com', '$2a$12$PKkLJhbBfh21xMjSxROmOeNnkGQ.NI.Bl0SPbhYG04k/HNkoOgxPG', 'Mary', 'Johnson', 'EMPLOYEE', 35.00, TRUE),
('bwilliams', 'bob.williams@company.com', '$2a$12$PKkLJhbBfh21xMjSxROmOeNnkGQ.NI.Bl0SPbhYG04k/HNkoOgxPG', 'Bob', 'Williams', 'EMPLOYEE', 32.00, TRUE),
('sjones', 'sarah.jones@company.com', '$2a$12$PKkLJhbBfh21xMjSxROmOeNnkGQ.NI.Bl0SPbhYG04k/HNkoOgxPG', 'Sarah', 'Jones', 'EMPLOYEE', 38.00, TRUE);

-- Insert sample projects with new enum values
INSERT INTO projects (name, description, client_name, manager_id, estimated_hours, estimated_cost, status, start_date, end_date) VALUES
('Website Redesign', 'Complete redesign of company website with modern UI/UX', 'Acme Corporation', 2, 200, 9000.00, 'ACTIF', '2024-01-15', '2024-03-15'),
('Mobile App Development', 'Native mobile application for iOS and Android', 'Tech Startup Inc', 2, 300, 13500.00, 'EN_ATTENTE', '2024-02-01', '2024-05-01'),
('Database Migration', 'Migrate legacy database to cloud infrastructure', 'Global Finance Ltd', 2, 150, 6750.00, 'ACTIF', '2024-01-20', '2024-02-28');

-- Assign employees to projects
INSERT INTO project_employees (project_id, employee_id) VALUES
(1, 3),  -- Mary Johnson on Website Redesign
(1, 4),  -- Bob Williams on Website Redesign
(2, 3),  -- Mary Johnson on Mobile App
(2, 5),  -- Sarah Jones on Mobile App
(3, 4),  -- Bob Williams on Database Migration
(3, 5);  -- Sarah Jones on Database Migration

-- Insert sample tasks with new enum values
INSERT INTO tasks (project_id, assigned_to, name, description, estimated_hours, status, priority, due_date) VALUES
-- Website Redesign tasks
(1, 3, 'Frontend Development', 'Develop responsive frontend using modern frameworks', 80, 'EN_COURS', 'HIGH', '2024-02-15'),
(1, 4, 'Backend API', 'Create RESTful APIs for data management', 60, 'EN_COURS', 'HIGH', '2024-02-28'),
(1, 3, 'Testing & QA', 'Comprehensive testing and quality assurance', 40, 'EN_COURS', 'MEDIUM', '2024-03-10'),
-- Mobile App tasks
(2, 3, 'UI Design', 'Design mobile app user interface', 50, 'EN_COURS', 'HIGH', '2024-02-20'),
(2, 5, 'API Integration', 'Integrate with backend APIs', 60, 'EN_COURS', 'MEDIUM', '2024-03-15'),
-- Database Migration tasks
(3, 4, 'Schema Design', 'Design new database schema', 30, 'VALIDEE', 'URGENT', '2024-01-25'),
(3, 5, 'Data Transfer', 'Transfer data to new database', 80, 'EN_COURS', 'HIGH', '2024-02-20');

-- Insert sample timesheets
INSERT INTO timesheets (user_id, week_start_date, week_end_date, total_hours, overtime_hours, total_regular_pay, total_overtime_pay, total_pay, status) VALUES
(3, '2024-01-15', '2024-01-21', 42.00, 2.00, 1400.00, 87.50, 1487.50, 'VALIDATED'),
(4, '2024-01-15', '2024-01-21', 40.00, 0.00, 1280.00, 0.00, 1280.00, 'VALIDATED'),
(5, '2024-01-15', '2024-01-21', 38.00, 0.00, 1444.00, 0.00, 1444.00, 'SUBMITTED');

-- Insert sample timesheet entries
INSERT INTO timesheet_entries (timesheet_id, task_id, work_date, hours_worked, description) VALUES
(1, 1, '2024-01-15', 8.0, 'Frontend component development'),
(1, 1, '2024-01-16', 8.0, 'Frontend styling and responsiveness'),
(1, 1, '2024-01-17', 8.5, 'Frontend testing and bug fixes'),
(1, 3, '2024-01-18', 8.0, 'Initial QA setup'),
(1, 3, '2024-01-19', 9.5, 'Test case creation and execution'),
(2, 2, '2024-01-15', 8.0, 'Backend API endpoint development'),
(2, 2, '2024-01-16', 8.0, 'Database integration'),
(2, 2, '2024-01-17', 8.0, 'API testing'),
(2, 2, '2024-01-18', 8.0, 'Documentation'),
(2, 2, '2024-01-19', 8.0, 'Code review and optimization');

COMMIT;

-- =====================================================================
-- Verify installation
-- =====================================================================
SELECT 'Database created successfully!' as Status;
SELECT COUNT(*) as user_count FROM users;
SELECT COUNT(*) as project_count FROM projects;
SELECT COUNT(*) as task_count FROM tasks;
SELECT COUNT(*) as timesheet_count FROM timesheets;
