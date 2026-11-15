-- Clean schema-only export derived from strategic_management_db(2).sql
-- 40 table definitions and the two strategic_goals triggers are retained.
-- No operational INSERT data, employee accounts, passwords, or audit/login records are included.
-- DROP TABLE, DROP TRIGGER, CREATE DATABASE, and USE statements were removed.
-- Import this file only into a newly created EMPTY database with utf8mb4.
-- This is a one-time schema installer, not a migration and not an in-place upgrade.
-- Review the MyISAM engines and the limited FK constraints before production deployment.

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Nov 14, 2026 at 10:45 PM
-- Server version: 8.2.0
-- PHP Version: 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `strategic_management_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `ai_jobs`
--

CREATE TABLE IF NOT EXISTS `ai_jobs` (
  `job_id` int NOT NULL AUTO_INCREMENT,
  `job_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `input_data` json DEFAULT NULL,
  `result_json` json DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ai_jobs`
--


-- --------------------------------------------------------

--
-- Table structure for table `ai_models`
--

CREATE TABLE IF NOT EXISTS `ai_models` (
  `model_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف النموذج',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم النموذج',
  `version` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الإصدار',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف النموذج',
  `accuracy` decimal(5,2) DEFAULT NULL COMMENT 'الدقة',
  `f1_score` decimal(5,2) DEFAULT NULL COMMENT 'مقياس F1',
  `deployed_at` timestamp NULL DEFAULT NULL COMMENT 'تاريخ النشر',
  `is_active` tinyint(1) DEFAULT '0' COMMENT 'هل هو النشط؟',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  PRIMARY KEY (`model_id`),
  UNIQUE KEY `unique_model` (`name`,`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='نماذج الذكاء الاصطناعي';

--
-- Dumping data for table `ai_models`
--


-- --------------------------------------------------------

--
-- Table structure for table `ai_predictions`
--

CREATE TABLE IF NOT EXISTS `ai_predictions` (
  `prediction_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف التنبؤ',
  `task_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف المهمة (FK)',
  `prediction_type` enum('delay','budget','risk','performance') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'نوع التنبؤ',
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'نص التنبؤ',
  `probability` decimal(5,2) DEFAULT NULL COMMENT 'الاحتمال (%)',
  `confidence` decimal(5,2) DEFAULT NULL COMMENT 'الثقة (%)',
  `model_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف النموذج (FK)',
  `features_used` json DEFAULT NULL COMMENT 'الميزات المستخدمة',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'تاريخ انتهاء الصلاحية',
  PRIMARY KEY (`prediction_id`),
  KEY `model_id` (`model_id`),
  KEY `idx_prediction_task` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='تنبؤات الذكاء الاصطناعي';

--
-- Dumping data for table `ai_predictions`
--


-- --------------------------------------------------------

--
-- Table structure for table `ai_recommendations`
--

CREATE TABLE IF NOT EXISTS `ai_recommendations` (
  `recommendation_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف التوصية',
  `task_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف المهمة (FK)',
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'نص التوصية',
  `reasoning` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'سبب التوصية',
  `priority_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الأولوية (FK)',
  `status_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الحالة (FK)',
  `implemented_by` int UNSIGNED DEFAULT NULL COMMENT 'منفذ بواسطة (FK)',
  `implemented_at` timestamp NULL DEFAULT NULL COMMENT 'تاريخ التنفيذ',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`recommendation_id`),
  KEY `priority_id` (`priority_id`),
  KEY `implemented_by` (`implemented_by`),
  KEY `idx_recommendation_task` (`task_id`),
  KEY `idx_recommendation_status` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='توصيات الذكاء الاصطناعي';

--
-- Dumping data for table `ai_recommendations`
--


-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE IF NOT EXISTS `audit_logs` (
  `audit_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف التدقيق',
  `employee_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف الموظف (FK)',
  `action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الإجراء',
  `table_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم الجدول',
  `record_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف السجل',
  `old_data` json DEFAULT NULL COMMENT 'البيانات القديمة',
  `new_data` json DEFAULT NULL COMMENT 'البيانات الجديدة',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'عنوان IP',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'نوع المتصفح',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  PRIMARY KEY (`audit_id`),
  KEY `idx_audit_table` (`table_name`),
  KEY `idx_audit_time` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='سجل التدقيق';

--
-- Dumping data for table `audit_logs`
--


-- --------------------------------------------------------

--
-- Table structure for table `budget_lines`
--

CREATE TABLE IF NOT EXISTS `budget_lines` (
  `budget_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف البند',
  `budgetable_type` enum('program','initiative','major_task','operational_task') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'نوع الكيان',
  `budgetable_id` int UNSIGNED NOT NULL COMMENT 'معرف الكيان',
  `department_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف الإدارة (FK)',
  `allocated_amount` decimal(15,2) DEFAULT '0.00' COMMENT 'المبلغ المخصص',
  `spent_amount` decimal(15,2) DEFAULT '0.00' COMMENT 'المبلغ المصروف',
  `remaining_amount` decimal(15,2) GENERATED ALWAYS AS ((`allocated_amount` - `spent_amount`)) STORED COMMENT 'المتبقي (محسوب)',
  `fiscal_year` smallint UNSIGNED NOT NULL COMMENT 'السنة المالية',
  `parent_budget_id` int UNSIGNED DEFAULT NULL COMMENT 'البند الأب',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`budget_id`),
  KEY `department_id` (`department_id`),
  KEY `parent_budget_id` (`parent_budget_id`),
  KEY `idx_budget_budgetable` (`budgetable_type`,`budgetable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='بنود الميزانية';

--
-- Dumping data for table `budget_lines`
--


-- --------------------------------------------------------

--
-- Table structure for table `budget_transactions`
--

CREATE TABLE IF NOT EXISTS `budget_transactions` (
  `transaction_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف المعاملة',
  `budget_id` int UNSIGNED NOT NULL COMMENT 'معرف بند الميزانية (FK)',
  `amount` decimal(15,2) NOT NULL COMMENT 'المبلغ',
  `transaction_type_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف نوع المعاملة (FK)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف المعاملة',
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ المعاملة',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK)',
  `approved_by` int UNSIGNED DEFAULT NULL COMMENT 'وافق بواسطة (FK)',
  `approved_at` timestamp NULL DEFAULT NULL COMMENT 'تاريخ الموافقة',
  PRIMARY KEY (`transaction_id`),
  KEY `transaction_type_id` (`transaction_type_id`),
  KEY `created_by` (`created_by`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_transaction_budget` (`budget_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='المعاملات المالية';

--
-- Dumping data for table `budget_transactions`
--


-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE IF NOT EXISTS `departments` (
  `department_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الإدارة',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم الإدارة',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'رمز الإدارة',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف الإدارة',
  `parent_department_id` int UNSIGNED DEFAULT NULL COMMENT 'الإدارة الأم (FK)',
  `manager_employee_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف مدير الإدارة (FK)',
  `level` tinyint DEFAULT '1' COMMENT 'المستوى',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_dept_parent` (`parent_department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الإدارات';

--
-- Dumping data for table `departments`
--


-- --------------------------------------------------------

--
-- Table structure for table `dict_priorities`
--

CREATE TABLE IF NOT EXISTS `dict_priorities` (
  `priority_id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الأولوية',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'رمز الأولوية',
  `name_ar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالعربية',
  `name_en` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالإنجليزية',
  `level` tinyint NOT NULL COMMENT 'المستوى (1=أعلى)',
  `color_hex` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '#6c757d' COMMENT 'لون سداسي',
  PRIMARY KEY (`priority_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `dict_priorities`
--


-- --------------------------------------------------------

--
-- Table structure for table `dict_risk_levels`
--

CREATE TABLE IF NOT EXISTS `dict_risk_levels` (
  `risk_level_id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف مستوى الخطر',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'رمز المستوى',
  `name_ar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالعربية',
  `name_en` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالإنجليزية',
  `min_score` tinyint DEFAULT '0' COMMENT 'الحد الأدنى للدرجة',
  `max_score` tinyint DEFAULT '100' COMMENT 'الحد الأعلى للدرجة',
  `color_hex` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '#6c757d' COMMENT 'لون سداسي',
  PRIMARY KEY (`risk_level_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='مستويات المخاطر';

--
-- Dumping data for table `dict_risk_levels`
--


-- --------------------------------------------------------

--
-- Table structure for table `dict_role_types`
--

CREATE TABLE IF NOT EXISTS `dict_role_types` (
  `role_type_id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف نوع الدور',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'رمز الدور',
  `name_ar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالعربية',
  `name_en` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالإنجليزية',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف الدور',
  PRIMARY KEY (`role_type_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='أنواع الأدوار في المهام (RACI)';

--
-- Dumping data for table `dict_role_types`
--


-- --------------------------------------------------------

--
-- Table structure for table `dict_statuses`
--

CREATE TABLE IF NOT EXISTS `dict_statuses` (
  `status_id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الحالة',
  `code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'رمز الحالة',
  `name_ar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالعربية',
  `name_en` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالإنجليزية',
  `category` enum('initiative','task','risk','employee','program','recommendation') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الفئة',
  `color_hex` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '#6c757d' COMMENT 'لون سداسي',
  `is_default` tinyint(1) DEFAULT '0' COMMENT 'هل هي افتراضية؟',
  `is_system` tinyint(1) DEFAULT '1' COMMENT 'نظامية لا يمكن حذفها',
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='حالات النظام الموحدة';

--
-- Dumping data for table `dict_statuses`
--


-- --------------------------------------------------------

--
-- Table structure for table `dict_transaction_types`
--

CREATE TABLE IF NOT EXISTS `dict_transaction_types` (
  `trans_type_id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف نوع المعاملة',
  `code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'رمز النوع',
  `name_ar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالعربية',
  `name_en` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم بالإنجليزية',
  `sign` tinyint NOT NULL COMMENT 'الإشارة: 1=إضافة, -1=خصم',
  PRIMARY KEY (`trans_type_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='أنواع المعاملات المالية';

--
-- Dumping data for table `dict_transaction_types`
--


-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE IF NOT EXISTS `employees` (
  `employee_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الموظف',
  `department_id` int UNSIGNED NOT NULL COMMENT 'معرف الإدارة (FK)',
  `employee_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'الرقم الوظيفي',
  `full_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الاسم الكامل',
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'البريد الإلكتروني',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'كلمة المرور (مشفر)',
  `phone_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'رقم الهاتف',
  `job_title` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'المسمى الوظيفي',
  `employment_status_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف حالة التوظيف (FK dict_statuses)',
  `hire_date` date DEFAULT NULL COMMENT 'تاريخ التعيين',
  `gps_enabled` tinyint(1) DEFAULT '1' COMMENT 'تفعيل تتبع الموقع',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  `last_login` timestamp NULL DEFAULT NULL COMMENT 'آخر تسجيل دخول',
  `profile_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'صورة الملف الشخصي',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`employee_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `employee_number` (`employee_number`),
  KEY `employment_status_id` (`employment_status_id`),
  KEY `idx_employee_email` (`email`),
  KEY `idx_employee_department` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الموظفون';

--
-- Dumping data for table `employees`
--


-- --------------------------------------------------------

--
-- Table structure for table `employee_roles`
--

CREATE TABLE IF NOT EXISTS `employee_roles` (
  `employee_id` int UNSIGNED NOT NULL COMMENT 'معرف الموظف (FK)',
  `role_id` int UNSIGNED NOT NULL COMMENT 'معرف الدور (FK)',
  `assigned_by` int UNSIGNED DEFAULT NULL COMMENT 'معرف المعين (FK)',
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ التعيين',
  PRIMARY KEY (`employee_id`,`role_id`),
  KEY `role_id` (`role_id`),
  KEY `assigned_by` (`assigned_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='أدوار الموظفين';

--
-- Dumping data for table `employee_roles`
--


-- --------------------------------------------------------

--
-- Table structure for table `goal_kpis`
--

CREATE TABLE IF NOT EXISTS `goal_kpis` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'المعرف',
  `goal_id` int UNSIGNED NOT NULL COMMENT 'معرف الهدف (FK)',
  `kpi_id` int UNSIGNED NOT NULL COMMENT 'معرف المؤشر (FK)',
  `target_value` decimal(15,2) DEFAULT NULL COMMENT 'القيمة المستهدفة',
  `weight` decimal(5,2) DEFAULT '1.00' COMMENT 'الوزن',
  `baseline_value` decimal(15,2) DEFAULT NULL COMMENT 'القيمة الأساسية',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_goal_kpi` (`goal_id`,`kpi_id`),
  KEY `kpi_id` (`kpi_id`),
  KEY `idx_goal_kpi_goal` (`goal_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `goal_kpis`
--


-- --------------------------------------------------------

--
-- Table structure for table `initiatives`
--

CREATE TABLE IF NOT EXISTS `initiatives` (
  `initiative_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف المبادرة',
  `program_id` int UNSIGNED NOT NULL COMMENT 'معرف البرنامج (FK)',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم المبادرة',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف المبادرة',
  `status_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الحالة (FK dict_statuses)',
  `priority_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الأولوية (FK dict_priorities)',
  `start_date` date DEFAULT NULL COMMENT 'تاريخ البدء',
  `end_date` date DEFAULT NULL COMMENT 'تاريخ الانتهاء',
  `budget_estimate` decimal(15,2) DEFAULT NULL COMMENT 'تقدير الميزانية',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK employees)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  PRIMARY KEY (`initiative_id`),
  KEY `status_id` (`status_id`),
  KEY `priority_id` (`priority_id`),
  KEY `idx_initiative_program` (`program_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='المبادرات الاستراتيجية';

--
-- Dumping data for table `initiatives`
--


-- --------------------------------------------------------

--
-- Table structure for table `kpis`
--

CREATE TABLE IF NOT EXISTS `kpis` (
  `kpi_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف المؤشر',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم المؤشر',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف المؤشر',
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'التصنيف',
  `unit` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'وحدة القياس',
  `target_min` decimal(15,2) DEFAULT NULL COMMENT 'الهدف الأدنى',
  `target_max` decimal(15,2) DEFAULT NULL COMMENT 'الهدف الأعلى',
  `calculation_method` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'طريقة الحساب',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`kpi_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='مؤشرات الأداء الرئيسية';

--
-- Dumping data for table `kpis`
--


-- --------------------------------------------------------

--
-- Table structure for table `kpi_measurements`
--

CREATE TABLE IF NOT EXISTS `kpi_measurements` (
  `measurement_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف القياس',
  `kpi_id` int UNSIGNED NOT NULL COMMENT 'معرف المؤشر (FK)',
  `value` decimal(15,2) NOT NULL COMMENT 'القيمة المقاسة',
  `source_type` enum('manual','system','api','ai') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'manual' COMMENT 'مصدر القياس',
  `source_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'معرف المصدر',
  `measured_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ القياس',
  `recorded_by` int UNSIGNED DEFAULT NULL COMMENT 'سجل بواسطة (FK)',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'ملاحظات',
  PRIMARY KEY (`measurement_id`),
  KEY `recorded_by` (`recorded_by`),
  KEY `idx_kpi_measurements_kpi` (`kpi_id`),
  KEY `idx_measurement_time` (`measured_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='قياسات مؤشرات الأداء';

--
-- Dumping data for table `kpi_measurements`
--


-- --------------------------------------------------------

--
-- Table structure for table `location_logs`
--

CREATE TABLE IF NOT EXISTS `location_logs` (
  `location_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الموقع',
  `employee_id` int UNSIGNED NOT NULL COMMENT 'معرف الموظف (FK)',
  `task_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف المهمة (FK)',
  `latitude` decimal(10,8) DEFAULT NULL COMMENT 'خط العرض',
  `longitude` decimal(11,8) DEFAULT NULL COMMENT 'خط الطول',
  `accuracy` decimal(10,2) DEFAULT NULL COMMENT 'الدقة (متر)',
  `recorded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'وقت التسجيل',
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'مصدر الموقع',
  PRIMARY KEY (`location_id`),
  KEY `idx_location_employee` (`employee_id`),
  KEY `idx_location_task` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='سجل المواقع (GPS)';

--
-- Dumping data for table `location_logs`
--


-- --------------------------------------------------------

--
-- Table structure for table `major_tasks`
--

CREATE TABLE IF NOT EXISTS `major_tasks` (
  `major_task_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف المهمة الكبرى',
  `initiative_id` int UNSIGNED NOT NULL COMMENT 'معرف المبادرة (FK)',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم المهمة',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف المهمة',
  `priority_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الأولوية (FK dict_priorities)',
  `estimated_duration_days` smallint UNSIGNED DEFAULT NULL COMMENT 'المدة المتوقعة بالأيام',
  `is_cross_department` tinyint(1) DEFAULT '0' COMMENT 'مشتركة بين الإدارات؟',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK employees)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  PRIMARY KEY (`major_task_id`),
  KEY `priority_id` (`priority_id`),
  KEY `idx_major_initiative` (`initiative_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='المهام الكبرى (تدعم المشاركة بين الإدارات)';

--
-- Dumping data for table `major_tasks`
--


-- --------------------------------------------------------

--
-- Table structure for table `major_task_departments`
--

CREATE TABLE IF NOT EXISTS `major_task_departments` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'المعرف',
  `major_task_id` int UNSIGNED NOT NULL COMMENT 'معرف المهمة الكبرى (FK)',
  `department_id` int UNSIGNED NOT NULL COMMENT 'معرف الإدارة (FK)',
  `responsibility_type` enum('LEAD','SUPPORT') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'SUPPORT' COMMENT 'نوع المسؤولية',
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ التعيين',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'ملاحظات',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_major_dept` (`major_task_id`,`department_id`),
  KEY `department_id` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ربط المهام الكبرى بالإدارات';

--
-- Dumping data for table `major_task_departments`
--


-- --------------------------------------------------------

--
-- Table structure for table `operational_tasks`
--

CREATE TABLE IF NOT EXISTS `operational_tasks` (
  `task_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف المهمة',
  `major_task_id` int UNSIGNED NOT NULL COMMENT 'معرف المهمة الكبرى (FK)',
  `department_id` int UNSIGNED NOT NULL COMMENT 'معرف الإدارة المسؤولة (FK)',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'عنوان المهمة',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف المهمة',
  `status_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الحالة (FK dict_statuses)',
  `priority_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الأولوية (FK dict_priorities)',
  `start_date` date DEFAULT NULL COMMENT 'تاريخ البدء',
  `end_date` date DEFAULT NULL COMMENT 'تاريخ الانتهاء',
  `estimated_hours` decimal(8,2) DEFAULT NULL COMMENT 'الساعات المتوقعة',
  `actual_hours` decimal(8,2) DEFAULT NULL COMMENT 'الساعات الفعلية',
  `is_cross_functional` tinyint(1) DEFAULT '0' COMMENT 'متعددة الوظائف',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK employees)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  PRIMARY KEY (`task_id`),
  KEY `priority_id` (`priority_id`),
  KEY `idx_task_major` (`major_task_id`),
  KEY `idx_task_status` (`status_id`),
  KEY `idx_task_department` (`department_id`),
  KEY `idx_task_end_date` (`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='المهام التشغيلية';

--
-- Dumping data for table `operational_tasks`
--


-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE IF NOT EXISTS `permissions` (
  `permission_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الصلاحية',
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم الصلاحية',
  `resource` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'المورد',
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'الفعل',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف الصلاحية',
  PRIMARY KEY (`permission_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الصلاحيات';

--
-- Dumping data for table `permissions`
--


-- --------------------------------------------------------

--
-- Table structure for table `pestel_analysis`
--

CREATE TABLE IF NOT EXISTS `pestel_analysis` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'المعرف',
  `department_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف الإدارة (FK)',
  `political` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'سياسي',
  `economic` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'اقتصادي',
  `social` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'اجتماعي',
  `technological` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'تقني',
  `environmental` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'بيئي',
  `legal` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'قانوني',
  `analysis_date` date NOT NULL COMMENT 'تاريخ التحليل',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`id`),
  KEY `department_id` (`department_id`),
  KEY `created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='تحليل PESTEL';

--
-- Dumping data for table `pestel_analysis`
--


-- --------------------------------------------------------

--
-- Table structure for table `programs`
--

CREATE TABLE IF NOT EXISTS `programs` (
  `program_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف البرنامج',
  `goal_id` int UNSIGNED NOT NULL COMMENT 'معرف الهدف (FK)',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم البرنامج',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف البرنامج',
  `budget_estimate` decimal(15,2) DEFAULT NULL COMMENT 'تقدير الميزانية',
  `start_date` date DEFAULT NULL COMMENT 'تاريخ البدء',
  `end_date` date DEFAULT NULL COMMENT 'تاريخ الانتهاء',
  `status_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الحالة (FK dict_statuses)',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK employees)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  PRIMARY KEY (`program_id`),
  KEY `status_id` (`status_id`),
  KEY `idx_program_goal` (`goal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='البرامج الاستراتيجية';

--
-- Dumping data for table `programs`
--


-- --------------------------------------------------------

--
-- Table structure for table `risks`
--

CREATE TABLE IF NOT EXISTS `risks` (
  `risk_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الخطر',
  `task_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف المهمة (FK)',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم الخطر',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف الخطر',
  `risk_level_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف مستوى الخطر (FK)',
  `probability` tinyint DEFAULT NULL COMMENT 'الاحتمال (1-10)',
  `impact` tinyint DEFAULT NULL COMMENT 'الأثر (1-10)',
  `risk_score` tinyint GENERATED ALWAYS AS (((`probability` * `impact`) / 10)) STORED COMMENT 'درجة الخطر (محسوبة)',
  `identified_by` int UNSIGNED DEFAULT NULL COMMENT 'معرف المكتشف (FK)',
  `identified_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الاكتشاف',
  `target_date` date DEFAULT NULL COMMENT 'التاريخ المستهدف للحل',
  `status_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الحالة (FK)',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`risk_id`),
  KEY `risk_level_id` (`risk_level_id`),
  KEY `identified_by` (`identified_by`),
  KEY `status_id` (`status_id`),
  KEY `idx_risk_task` (`task_id`),
  KEY `idx_risk_score` (`risk_score`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `risks`
--


-- --------------------------------------------------------

--
-- Table structure for table `risk_mitigations`
--

CREATE TABLE IF NOT EXISTS `risk_mitigations` (
  `mitigation_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الإجراء',
  `risk_id` int UNSIGNED NOT NULL COMMENT 'معرف الخطر (FK)',
  `task_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف المهمة (FK)',
  `action` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'الإجراء',
  `status_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف الحالة (FK)',
  `assigned_to` int UNSIGNED DEFAULT NULL COMMENT 'مسند إلى (FK)',
  `due_date` date DEFAULT NULL COMMENT 'تاريخ الاستحقاق',
  `completed_at` timestamp NULL DEFAULT NULL COMMENT 'تاريخ الإنجاز',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'ملاحظات',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`mitigation_id`),
  KEY `task_id` (`task_id`),
  KEY `status_id` (`status_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `idx_mitigation_risk` (`risk_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='إجراءات تخفيف المخاطر';

--
-- Dumping data for table `risk_mitigations`
--


-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE IF NOT EXISTS `roles` (
  `role_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الدور',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم الدور',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف الدور',
  `is_system` tinyint(1) DEFAULT '0' COMMENT 'نظامي',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الأدوار الوظيفية';

--
-- Dumping data for table `roles`
--


-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` int UNSIGNED NOT NULL COMMENT 'معرف الدور (FK)',
  `permission_id` int UNSIGNED NOT NULL COMMENT 'معرف الصلاحية (FK)',
  `granted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ المنح',
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='صلاحيات الأدوار';

--
-- Dumping data for table `role_permissions`
--


-- --------------------------------------------------------

--
-- Table structure for table `strategic_goals`
--

CREATE TABLE IF NOT EXISTS `strategic_goals` (
  `goal_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الهدف',
  `pillar_id` int UNSIGNED NOT NULL COMMENT 'معرف الركيزة (FK)',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'عنوان الهدف',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف الهدف',
  `target_date` date DEFAULT NULL COMMENT 'التاريخ المستهدف',
  `weight` tinyint DEFAULT '1' COMMENT 'وزن الهدف (أهميته)',
  `valid_from` date DEFAULT NULL COMMENT 'بداية الصلاحية',
  `valid_until` date DEFAULT NULL COMMENT 'نهاية الصلاحية',
  `is_current` tinyint(1) DEFAULT '1' COMMENT 'هل هو ساري؟ (يتم تحديثه عبر Trigger)',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK employees)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  PRIMARY KEY (`goal_id`),
  KEY `idx_goal_pillar` (`pillar_id`),
  KEY `idx_goal_validity` (`valid_from`,`valid_until`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `strategic_goals`
--


--
-- Triggers `strategic_goals`
--
DELIMITER $$
CREATE TRIGGER `before_insert_strategic_goals` BEFORE INSERT ON `strategic_goals` FOR EACH ROW BEGIN
    IF NEW.valid_from IS NOT NULL AND NEW.valid_until IS NOT NULL THEN
        SET NEW.is_current = (CURDATE() BETWEEN NEW.valid_from AND NEW.valid_until);
    ELSE
        SET NEW.is_current = TRUE;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_strategic_goals` BEFORE UPDATE ON `strategic_goals` FOR EACH ROW BEGIN
    IF NEW.valid_from IS NOT NULL AND NEW.valid_until IS NOT NULL THEN
        SET NEW.is_current = (CURDATE() BETWEEN NEW.valid_from AND NEW.valid_until);
    ELSE
        SET NEW.is_current = TRUE;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `strategic_pillars`
--

CREATE TABLE IF NOT EXISTS `strategic_pillars` (
  `pillar_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الركيزة',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'اسم الركيزة',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف الركيزة',
  `order_index` tinyint UNSIGNED DEFAULT '0' COMMENT 'ترتيب العرض',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK employees)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  PRIMARY KEY (`pillar_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الركائز الاستراتيجية';

--
-- Dumping data for table `strategic_pillars`
--


-- --------------------------------------------------------

--
-- Table structure for table `strategic_visions`
--

CREATE TABLE IF NOT EXISTS `strategic_visions` (
  `vision_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الرؤية',
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'نص الرؤية',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'وصف إضافي',
  `version` smallint UNSIGNED DEFAULT '1' COMMENT 'رقم الإصدار',
  `effective_date` date NOT NULL COMMENT 'تاريخ السريان',
  `is_current` tinyint(1) DEFAULT '0' COMMENT 'هل هو الإصدار الحالي؟',
  `approved_by` int UNSIGNED DEFAULT NULL COMMENT 'معتمد بواسطة (FK employees)',
  `approved_at` timestamp NULL DEFAULT NULL COMMENT 'تاريخ الاعتماد',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK employees)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  PRIMARY KEY (`vision_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='الرؤى الاستراتيجية مع الإصدارات';

--
-- Dumping data for table `strategic_visions`
--


-- --------------------------------------------------------

--
-- Table structure for table `swot_analysis`
--

CREATE TABLE IF NOT EXISTS `swot_analysis` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'المعرف',
  `department_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف الإدارة (FK)',
  `strengths` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'نقاط القوة',
  `weaknesses` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'نقاط الضعف',
  `opportunities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'الفرص',
  `threats` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'التهديدات',
  `analysis_date` date NOT NULL COMMENT 'تاريخ التحليل',
  `created_by` int UNSIGNED DEFAULT NULL COMMENT 'أنشئ بواسطة (FK)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`id`),
  KEY `department_id` (`department_id`),
  KEY `created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='تحليل SWOT';

--
-- Dumping data for table `swot_analysis`
--


-- --------------------------------------------------------

--
-- Table structure for table `system_config`
--

CREATE TABLE IF NOT EXISTS `system_config` (
  `config_id` tinyint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'المعرف',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'مفتاح الإعداد',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'قيمة الإعداد',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'وصف الإعداد',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='إعدادات النظام العامة';

--
-- Dumping data for table `system_config`
--


-- --------------------------------------------------------

--
-- Table structure for table `task_assignments`
--

CREATE TABLE IF NOT EXISTS `task_assignments` (
  `assignment_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف التوزيع',
  `task_id` int UNSIGNED NOT NULL COMMENT 'معرف المهمة (FK)',
  `employee_id` int UNSIGNED NOT NULL COMMENT 'معرف الموظف (FK)',
  `role_type_id` tinyint UNSIGNED DEFAULT NULL COMMENT 'معرف نوع الدور (FK)',
  `acceptance_status` enum('pending','accepted','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending' COMMENT 'حالة القبول',
  `rejection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'سبب الرفض',
  `accepted_at` timestamp NULL DEFAULT NULL COMMENT 'تاريخ القبول',
  `estimated_hours` decimal(8,2) DEFAULT NULL COMMENT 'الساعات المقدرة',
  `assigned_by` int UNSIGNED DEFAULT NULL COMMENT 'معرف الموزع (FK)',
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ التوزيع',
  `is_active` tinyint(1) DEFAULT '1' COMMENT 'نشط؟',
  PRIMARY KEY (`assignment_id`),
  UNIQUE KEY `unique_task_employee` (`task_id`,`employee_id`),
  KEY `role_type_id` (`role_type_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `idx_assignment_task` (`task_id`),
  KEY `idx_assignment_employee` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='توزيع المهام';

--
-- Dumping data for table `task_assignments`
--


-- --------------------------------------------------------

--
-- Table structure for table `task_attachments`
--

CREATE TABLE IF NOT EXISTS `task_attachments` (
  `attachment_id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `employee_id` int NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_extension` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` int NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `storage_disk` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'local',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`attachment_id`),
  KEY `idx_task_attachments_task_id` (`task_id`),
  KEY `idx_task_attachments_employee_id` (`employee_id`),
  KEY `idx_task_attachments_is_active` (`is_active`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_attachments`
--


-- --------------------------------------------------------

--
-- Table structure for table `task_comments`
--

CREATE TABLE IF NOT EXISTS `task_comments` (
  `comment_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف التعليق',
  `task_id` int UNSIGNED NOT NULL COMMENT 'معرف المهمة (FK)',
  `employee_id` int UNSIGNED NOT NULL COMMENT 'معرف الموظف (FK)',
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'نص التعليق',
  `parent_comment_id` int UNSIGNED DEFAULT NULL COMMENT 'معرف التعليق الأب (FK)',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'تاريخ التحديث',
  PRIMARY KEY (`comment_id`),
  KEY `task_id` (`task_id`),
  KEY `employee_id` (`employee_id`),
  KEY `parent_comment_id` (`parent_comment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='تعليقات المهام';

--
-- Dumping data for table `task_comments`
--


-- --------------------------------------------------------

--
-- Table structure for table `task_dependencies`
--

CREATE TABLE IF NOT EXISTS `task_dependencies` (
  `dependency_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف الاعتمادية',
  `task_id` int UNSIGNED NOT NULL COMMENT 'المهمة التي تعتمد (FK)',
  `depends_on_task_id` int UNSIGNED NOT NULL COMMENT 'المهمة التي يُعتمد عليها (FK)',
  `dependency_type` enum('FS','SS','FF','SF') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FS' COMMENT 'نوع الاعتمادية',
  `lag_days` smallint DEFAULT '0' COMMENT 'فترة تأخير',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'تاريخ الإنشاء',
  PRIMARY KEY (`dependency_id`),
  KEY `idx_dependency_task` (`task_id`),
  KEY `idx_dependency_depends` (`depends_on_task_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_dependencies`
--


-- --------------------------------------------------------

--
-- Table structure for table `task_progress_logs`
--

CREATE TABLE IF NOT EXISTS `task_progress_logs` (
  `log_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'معرف السجل',
  `task_id` int UNSIGNED NOT NULL COMMENT 'معرف المهمة (FK)',
  `employee_id` int UNSIGNED NOT NULL COMMENT 'معرف الموظف (FK)',
  `progress_percent` tinyint DEFAULT NULL COMMENT 'نسبة الإنجاز',
  `status_old` tinyint UNSIGNED DEFAULT NULL COMMENT 'الحالة القديمة',
  `status_new` tinyint UNSIGNED DEFAULT NULL COMMENT 'الحالة الجديدة',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'ملاحظات',
  `log_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'وقت التسجيل',
  PRIMARY KEY (`log_id`),
  KEY `employee_id` (`employee_id`),
  KEY `status_old` (`status_old`),
  KEY `status_new` (`status_new`),
  KEY `idx_progress_task` (`task_id`),
  KEY `idx_progress_time` (`log_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_progress_logs`
--


--
-- Constraints for dumped tables
--

--
-- Constraints for table `ai_predictions`
--
ALTER TABLE `ai_predictions`
  ADD CONSTRAINT `ai_predictions_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `operational_tasks` (`task_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `ai_predictions_ibfk_2` FOREIGN KEY (`model_id`) REFERENCES `ai_models` (`model_id`);

--
-- Constraints for table `budget_lines`
--
ALTER TABLE `budget_lines`
  ADD CONSTRAINT `budget_lines_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`),
  ADD CONSTRAINT `budget_lines_ibfk_2` FOREIGN KEY (`parent_budget_id`) REFERENCES `budget_lines` (`budget_id`);
