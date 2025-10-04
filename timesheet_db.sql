-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Oct 04, 2025 at 02:55 PM
-- Server version: 8.0.40
-- PHP Version: 8.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `timesheet_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
CREATE TABLE IF NOT EXISTS `projects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `client_name` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manager_id` bigint NOT NULL,
  `estimated_hours` int DEFAULT '0',
  `estimated_cost` decimal(12,2) DEFAULT '0.00',
  `actual_hours` decimal(8,2) DEFAULT '0.00',
  `actual_cost` decimal(12,2) DEFAULT '0.00',
  `status` enum('EN_ATTENTE','VALIDE','ACTIF','TERMINE','ABANDONNE') COLLATE utf8mb4_unicode_ci DEFAULT 'EN_ATTENTE',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `is_validated` tinyint(1) DEFAULT '0',
  `validated_by` bigint DEFAULT NULL,
  `validated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `validated_by` (`validated_by`),
  KEY `idx_manager` (`manager_id`),
  KEY `idx_status` (`status`),
  KEY `idx_dates` (`start_date`,`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `name`, `description`, `client_name`, `manager_id`, `estimated_hours`, `estimated_cost`, `actual_hours`, `actual_cost`, `status`, `start_date`, `end_date`, `is_validated`, `validated_by`, `validated_at`, `created_at`, `updated_at`) VALUES
(1, 'Website Redesign', 'Complete redesign of company website with modern UI/UX', 'Acme Corporation', 2, 200, 9000.00, 0.00, 0.00, 'ACTIF', '2024-01-15', '2024-03-15', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(2, 'Mobile App Development', 'Native mobile application for iOS and Android', 'Tech Startup Inc', 2, 300, 13500.00, 0.00, 0.00, 'ABANDONNE', '2024-02-01', '2024-05-01', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-02 15:11:25'),
(3, 'Database Migration', 'Migrate legacy database to cloud infrastructure', 'Global Finance Ltd', 2, 150, 6750.00, 0.00, 0.00, 'ACTIF', '2024-01-20', '2024-02-28', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22');

-- --------------------------------------------------------

--
-- Table structure for table `project_employees`
--

DROP TABLE IF EXISTS `project_employees`;
CREATE TABLE IF NOT EXISTS `project_employees` (
  `project_id` bigint NOT NULL,
  `employee_id` bigint NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`project_id`,`employee_id`),
  KEY `idx_project` (`project_id`),
  KEY `idx_employee` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `project_employees`
--

INSERT INTO `project_employees` (`project_id`, `employee_id`, `assigned_at`) VALUES
(1, 3, '2025-10-01 18:57:22'),
(1, 4, '2025-10-01 18:57:22'),
(2, 3, '2025-10-01 18:57:22'),
(2, 5, '2025-10-01 18:57:22'),
(3, 4, '2025-10-02 16:10:29'),
(3, 5, '2025-10-02 16:10:29');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
CREATE TABLE IF NOT EXISTS `tasks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `project_id` bigint NOT NULL,
  `assigned_to` bigint NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `estimated_hours` int DEFAULT '0',
  `actual_hours` decimal(8,2) DEFAULT '0.00',
  `status` enum('EN_COURS','VALIDEE','REJETEE','ANNULEE') COLLATE utf8mb4_unicode_ci DEFAULT 'EN_COURS',
  `priority` enum('LOW','MEDIUM','HIGH','URGENT') COLLATE utf8mb4_unicode_ci DEFAULT 'MEDIUM',
  `due_date` date DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `is_validated` tinyint(1) DEFAULT '0',
  `validated_by` bigint DEFAULT NULL,
  `validated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `validated_by` (`validated_by`),
  KEY `idx_project` (`project_id`),
  KEY `idx_assigned` (`assigned_to`),
  KEY `idx_status` (`status`),
  KEY `idx_due_date` (`due_date`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `project_id`, `assigned_to`, `name`, `description`, `estimated_hours`, `actual_hours`, `status`, `priority`, `due_date`, `completed_at`, `is_validated`, `validated_by`, `validated_at`, `created_at`, `updated_at`) VALUES
(1, 1, 3, 'Frontend Development', 'Develop responsive frontend using modern frameworks', 80, 0.00, 'EN_COURS', 'HIGH', '2024-02-15', NULL, 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(2, 1, 4, 'Backend API', 'Create RESTful APIs for data management', 60, 0.00, 'EN_COURS', 'HIGH', '2024-02-28', NULL, 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(3, 1, 3, 'Testing & QA', 'Comprehensive testing and quality assurance', 40, 0.00, 'EN_COURS', 'MEDIUM', '2024-03-10', NULL, 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(4, 2, 3, 'UI Design', 'Design mobile app user interface', 50, 0.00, 'EN_COURS', 'HIGH', '2024-02-20', NULL, 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(5, 2, 5, 'API Integration', 'Integrate with backend APIs', 60, 0.00, 'EN_COURS', 'MEDIUM', '2024-03-15', NULL, 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(6, 3, 4, 'Schema Design', 'Design new database schema', 30, 0.00, 'VALIDEE', 'URGENT', '2024-01-25', NULL, 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(7, 3, 5, 'Data Transfer', 'Transfer data to new database', 80, 0.00, 'EN_COURS', 'HIGH', '2024-02-20', NULL, 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22');

-- --------------------------------------------------------

--
-- Table structure for table `timesheets`
--

DROP TABLE IF EXISTS `timesheets`;
CREATE TABLE IF NOT EXISTS `timesheets` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `week_start_date` date NOT NULL,
  `week_end_date` date NOT NULL,
  `total_hours` decimal(8,2) DEFAULT '0.00',
  `overtime_hours` decimal(8,2) DEFAULT '0.00',
  `total_regular_pay` decimal(10,2) DEFAULT '0.00',
  `total_overtime_pay` decimal(10,2) DEFAULT '0.00',
  `total_pay` decimal(10,2) DEFAULT '0.00',
  `status` enum('DRAFT','SUBMITTED','VALIDATED','REJECTED') COLLATE utf8mb4_unicode_ci DEFAULT 'DRAFT',
  `submitted_at` timestamp NULL DEFAULT NULL,
  `validated_by` bigint DEFAULT NULL,
  `validated_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_week` (`user_id`,`week_start_date`),
  KEY `validated_by` (`validated_by`),
  KEY `idx_user` (`user_id`),
  KEY `idx_week` (`week_start_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `timesheets`
--

INSERT INTO `timesheets` (`id`, `user_id`, `week_start_date`, `week_end_date`, `total_hours`, `overtime_hours`, `total_regular_pay`, `total_overtime_pay`, `total_pay`, `status`, `submitted_at`, `validated_by`, `validated_at`, `rejection_reason`, `created_at`, `updated_at`) VALUES
(1, 3, '2024-01-15', '2024-01-21', 42.00, 2.00, 1400.00, 87.50, 1487.50, 'VALIDATED', NULL, NULL, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(2, 4, '2024-01-15', '2024-01-21', 40.00, 0.00, 1280.00, 0.00, 1280.00, 'VALIDATED', NULL, NULL, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(3, 5, '2024-01-15', '2024-01-21', 38.00, 0.00, 1444.00, 0.00, 1444.00, 'SUBMITTED', NULL, NULL, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(4, 3, '2025-09-29', '2025-10-05', 0.00, 0.00, 0.00, 0.00, 0.00, 'DRAFT', NULL, NULL, NULL, NULL, '2025-10-01 18:02:59', '2025-10-01 18:02:59');

-- --------------------------------------------------------

--
-- Table structure for table `timesheet_entries`
--

DROP TABLE IF EXISTS `timesheet_entries`;
CREATE TABLE IF NOT EXISTS `timesheet_entries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `timesheet_id` bigint NOT NULL,
  `task_id` bigint NOT NULL,
  `work_date` date NOT NULL,
  `hours_worked` decimal(5,2) NOT NULL DEFAULT '0.00',
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_validated` tinyint(1) DEFAULT '0',
  `validated_by` bigint DEFAULT NULL,
  `validated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_entry` (`timesheet_id`,`task_id`,`work_date`),
  KEY `validated_by` (`validated_by`),
  KEY `idx_timesheet` (`timesheet_id`),
  KEY `idx_task` (`task_id`),
  KEY `idx_date` (`work_date`),
  KEY `idx_validated` (`is_validated`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `timesheet_entries`
--

INSERT INTO `timesheet_entries` (`id`, `timesheet_id`, `task_id`, `work_date`, `hours_worked`, `description`, `is_validated`, `validated_by`, `validated_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, '2024-01-15', 8.00, 'Frontend component development', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(2, 1, 1, '2024-01-16', 8.00, 'Frontend styling and responsiveness', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(3, 1, 1, '2024-01-17', 8.50, 'Frontend testing and bug fixes', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(4, 1, 3, '2024-01-18', 8.00, 'Initial QA setup', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(5, 1, 3, '2024-01-19', 9.50, 'Test case creation and execution', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(6, 2, 2, '2024-01-15', 8.00, 'Backend API endpoint development', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(7, 2, 2, '2024-01-16', 8.00, 'Database integration', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(8, 2, 2, '2024-01-17', 8.00, 'API testing', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(9, 2, 2, '2024-01-18', 8.00, 'Documentation', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(10, 2, 2, '2024-01-19', 8.00, 'Code review and optimization', 0, NULL, NULL, '2025-10-01 18:57:22', '2025-10-01 18:57:22');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('EMPLOYEE','PROJECT_MANAGER','ADMIN') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'EMPLOYEE',
  `hourly_rate` decimal(10,2) DEFAULT '0.00',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `hourly_rate`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'admin@timesheet.com', '$2a$12$Cd.tIp5hnraQP5d3Wy3JvOi.dnuObcIiumvtMDipzzqpwzzlCxSs2', 'System', 'Administrator', 'ADMIN', 50.00, 1, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(2, 'jsmith', 'john.smith@company.com', '$2a$12$2M8.Skb0AXxH53A6slAn3.0KesWHyFfG9CYYRwzGe1qwyZey/kxfy', 'John', 'Smith', 'PROJECT_MANAGER', 45.00, 1, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(3, 'mjohnson', 'mary.johnson@company.com', '$2a$12$PKkLJhbBfh21xMjSxROmOeNnkGQ.NI.Bl0SPbhYG04k/HNkoOgxPG', 'Mary', 'Johnson', 'EMPLOYEE', 35.00, 1, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(4, 'bwilliams', 'bob.williams@company.com', '$2a$12$PKkLJhbBfh21xMjSxROmOeNnkGQ.NI.Bl0SPbhYG04k/HNkoOgxPG', 'Bob', 'Williams', 'EMPLOYEE', 32.00, 1, '2025-10-01 18:57:22', '2025-10-01 18:57:22'),
(5, 'sjones', 'sarah.jones@company.com', '$2a$12$PKkLJhbBfh21xMjSxROmOeNnkGQ.NI.Bl0SPbhYG04k/HNkoOgxPG', 'Sarah', 'Jones', 'EMPLOYEE', 38.00, 1, '2025-10-01 18:57:22', '2025-10-01 18:57:22');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `projects_ibfk_2` FOREIGN KEY (`validated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `project_employees`
--
ALTER TABLE `project_employees`
  ADD CONSTRAINT `project_employees_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `project_employees_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `tasks_ibfk_3` FOREIGN KEY (`validated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `timesheets`
--
ALTER TABLE `timesheets`
  ADD CONSTRAINT `timesheets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `timesheets_ibfk_2` FOREIGN KEY (`validated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `timesheet_entries`
--
ALTER TABLE `timesheet_entries`
  ADD CONSTRAINT `timesheet_entries_ibfk_1` FOREIGN KEY (`timesheet_id`) REFERENCES `timesheets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `timesheet_entries_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `timesheet_entries_ibfk_3` FOREIGN KEY (`validated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
