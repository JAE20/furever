-- Database Schema Constraints Implementation Script for XAMPP MySQL
-- Execute these commands in order to implement proper constraints
-- Compatible with XAMPP MySQL/MariaDB

-- ============================================================
-- PHASE 1: SAFE SCHEMA UPDATES (Execute First)
-- ============================================================

-- 1. Extend user roles to support pet owners (check if already exists)
SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'furever' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'role';

-- If the above shows only 'admin','adopter', run this:
ALTER TABLE `users` 
MODIFY `role` enum('admin','adopter','pet_owner') DEFAULT 'adopter';

-- 2. Add username references to profile tables (check if columns exist first)
-- Check for existing username column in tbl_adopter
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adopter' 
    AND COLUMN_NAME = 'username'
);

-- Add username column to tbl_adopter only if it doesn't exist
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `tbl_adopter` ADD COLUMN `username` varchar(50) UNIQUE AFTER `adopter_id`;', 
    'SELECT "Column username already exists in tbl_adopter" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check for existing username column in tbl_pet_owner
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_pet_owner' 
    AND COLUMN_NAME = 'username'
);

-- Add username column to tbl_pet_owner only if it doesn't exist
SET @sql = IF(@col_exists = 0, 
    'ALTER TABLE `tbl_pet_owner` ADD COLUMN `username` varchar(50) UNIQUE AFTER `pet_owner_id`;', 
    'SELECT "Column username already exists in tbl_pet_owner" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. Add critical NOT NULL constraints (only if not already set)
-- Check current column definitions first
SELECT COLUMN_NAME, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'furever' 
AND TABLE_NAME = 'tbl_pet' 
AND COLUMN_NAME IN ('adoption_status', 'date_registered');

-- Update constraints only if needed
ALTER TABLE `tbl_pet` 
MODIFY `adoption_status` enum('Available','Pending','Adopted') NOT NULL DEFAULT 'Available';

-- For date_registered, use compatible default
ALTER TABLE `tbl_pet` 
MODIFY `date_registered` date NOT NULL DEFAULT (CURRENT_DATE);

-- ============================================================
-- PHASE 2: DATA MIGRATION (Execute After Phase 1)
-- ============================================================

-- Migrate existing pet owner to users table
INSERT IGNORE INTO `users` (`username`, `email`, `password`, `role`) 
SELECT `pet_owner_username`, `pet_owner_email`, `pet_owner_password`, 'pet_owner'
FROM `tbl_pet_owner` 
WHERE `pet_owner_username` IS NOT NULL;

-- Update pet owner table with username references
UPDATE `tbl_pet_owner` 
SET `username` = `pet_owner_username` 
WHERE `pet_owner_username` IS NOT NULL;

-- ============================================================
-- PHASE 3: FOREIGN KEY CONSTRAINTS (Execute After Migration)
-- ============================================================

-- Check if foreign key constraints already exist before adding
SELECT CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_SCHEMA = 'furever' 
AND CONSTRAINT_TYPE = 'FOREIGN KEY' 
AND TABLE_NAME IN ('tbl_adopter', 'tbl_pet_owner');

-- Link adopter profiles to users (check if constraint exists)
SET @fk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adopter' 
    AND CONSTRAINT_NAME = 'fk_adopter_user'
);

SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE `tbl_adopter` ADD CONSTRAINT `fk_adopter_user` FOREIGN KEY (`username`) REFERENCES `users`(`username`) ON UPDATE CASCADE ON DELETE SET NULL;', 
    'SELECT "Foreign key fk_adopter_user already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Link pet owner profiles to users (check if constraint exists)
SET @fk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_pet_owner' 
    AND CONSTRAINT_NAME = 'fk_pet_owner_user'
);

SET @sql = IF(@fk_exists = 0, 
    'ALTER TABLE `tbl_pet_owner` ADD CONSTRAINT `fk_pet_owner_user` FOREIGN KEY (`username`) REFERENCES `users`(`username`) ON UPDATE CASCADE ON DELETE SET NULL;', 
    'SELECT "Foreign key fk_pet_owner_user already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add user tracking to adoption requests (check if constraint exists)
SET @fk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption_request' 
    AND CONSTRAINT_NAME = 'fk_request_user'
);

SET @sql = IF(@fk_exists = 0 AND (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'furever' AND TABLE_NAME = 'tbl_adoption_request' AND COLUMN_NAME = 'user_id') > 0, 
    'ALTER TABLE `tbl_adoption_request` ADD CONSTRAINT `fk_request_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;', 
    'SELECT "Foreign key fk_request_user not added - column user_id may not exist" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add user tracking to adoptions (check if constraint exists)
SET @fk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption' 
    AND CONSTRAINT_NAME = 'fk_adoption_user'
);

SET @sql = IF(@fk_exists = 0 AND (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'furever' AND TABLE_NAME = 'tbl_adoption' AND COLUMN_NAME = 'user_id') > 0, 
    'ALTER TABLE `tbl_adoption` ADD CONSTRAINT `fk_adoption_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;', 
    'SELECT "Foreign key fk_adoption_user not added - column user_id may not exist" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- PHASE 4: IMPROVED CASCADE RULES (Execute After Phase 3)
-- ============================================================

-- Update pet media constraints (check if constraint exists first)
SET @fk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_pet_media' 
    AND CONSTRAINT_NAME = 'fk_pet_media'
);

-- Drop existing constraint if it exists
SET @sql = IF(@fk_exists > 0, 
    'ALTER TABLE `tbl_pet_media` DROP FOREIGN KEY `fk_pet_media`;', 
    'SELECT "Constraint fk_pet_media does not exist" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add the constraint with proper cascade rules
ALTER TABLE `tbl_pet_media` 
ADD CONSTRAINT `fk_pet_media` 
FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Update adoption request constraints (check existing constraints first)
SET @fk_pet_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption_request' 
    AND CONSTRAINT_NAME = 'fk_request_pet'
);

SET @fk_adopter_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption_request' 
    AND CONSTRAINT_NAME = 'fk_request_adopter'
);

-- Drop and recreate pet constraint for adoption requests
SET @sql = IF(@fk_pet_exists > 0, 
    'ALTER TABLE `tbl_adoption_request` DROP FOREIGN KEY `fk_request_pet`;', 
    'SELECT "Constraint fk_request_pet does not exist" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `tbl_adoption_request` 
ADD CONSTRAINT `fk_request_pet` 
FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Drop and recreate adopter constraint for adoption requests
SET @sql = IF(@fk_adopter_exists > 0, 
    'ALTER TABLE `tbl_adoption_request` DROP FOREIGN KEY `fk_request_adopter`;', 
    'SELECT "Constraint fk_request_adopter does not exist" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `tbl_adoption_request` 
ADD CONSTRAINT `fk_request_adopter` 
FOREIGN KEY (`adopter_id`) REFERENCES `tbl_adopter` (`adopter_id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Update adoption constraints (restrict to prevent data loss)
SET @fk_adoption_pet_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption' 
    AND CONSTRAINT_NAME = 'fk_adoption_pet'
);

SET @fk_adoption_adopter_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption' 
    AND CONSTRAINT_NAME = 'fk_adoption_adopter'
);

-- Drop and recreate adoption constraints
SET @sql = IF(@fk_adoption_pet_exists > 0, 
    'ALTER TABLE `tbl_adoption` DROP FOREIGN KEY `fk_adoption_pet`;', 
    'SELECT "Constraint fk_adoption_pet does not exist" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(@fk_adoption_adopter_exists > 0, 
    'ALTER TABLE `tbl_adoption` DROP FOREIGN KEY `fk_adoption_adopter`;', 
    'SELECT "Constraint fk_adoption_adopter does not exist" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `tbl_adoption` 
ADD CONSTRAINT `fk_adoption_pet` 
FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`) 
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `tbl_adoption` 
ADD CONSTRAINT `fk_adoption_adopter` 
FOREIGN KEY (`adopter_id`) REFERENCES `tbl_adopter` (`adopter_id`) 
ON DELETE RESTRICT ON UPDATE CASCADE;

-- ============================================================
-- PHASE 5: BUSINESS LOGIC CONSTRAINTS (Execute After Phase 4)
-- ============================================================

-- Check if constraints already exist before adding them
SELECT CONSTRAINT_NAME, CHECK_CLAUSE 
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA = 'furever';

-- Age validation for pets (check if constraint exists)
SET @chk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'furever' 
    AND CONSTRAINT_NAME = 'chk_pet_age'
);

SET @sql = IF(@chk_exists = 0, 
    'ALTER TABLE `tbl_pet` ADD CONSTRAINT `chk_pet_age` CHECK (`age` >= 0 AND `age` <= 30);', 
    'SELECT "Check constraint chk_pet_age already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Date validation constraints (Note: Functions not allowed in CHECK clauses in XAMPP/MariaDB)
-- We'll implement these validations in the application layer instead

-- Approval date validation (this one works as it compares columns, not functions)
SET @chk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'furever' 
    AND CONSTRAINT_NAME = 'chk_approval_date'
);

SET @sql = IF(@chk_exists = 0, 
    'ALTER TABLE `tbl_adoption_request` ADD CONSTRAINT `chk_approval_date` CHECK (`approval_date` >= `request_date` OR `approval_date` IS NULL);', 
    'SELECT "Check constraint chk_approval_date already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Note: Date validations against CURRENT_DATE will be handled in application logic
-- instead of database constraints due to XAMPP/MariaDB limitations

-- Business rule constraints (check for existing unique constraints)
SET @uk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption_request' 
    AND CONSTRAINT_NAME = 'uk_adopter_pet_request'
);

SET @sql = IF(@uk_exists = 0, 
    'ALTER TABLE `tbl_adoption_request` ADD CONSTRAINT `uk_adopter_pet_request` UNIQUE (`adopter_id`, `pet_id`, `status`);', 
    'SELECT "Unique constraint uk_adopter_pet_request already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @uk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption' 
    AND CONSTRAINT_NAME = 'uk_pet_adoption'
);

SET @sql = IF(@uk_exists = 0, 
    'ALTER TABLE `tbl_adoption` ADD CONSTRAINT `uk_pet_adoption` UNIQUE (`pet_id`);', 
    'SELECT "Unique constraint uk_pet_adoption already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- PHASE 6: EMAIL/CONTACT VALIDATION (Optional - Execute Last)
-- ============================================================

-- Note: MySQL/MariaDB in XAMPP may not support all REGEXP features
-- Test these constraints individually and skip if they cause errors

-- Email format validation (basic pattern for XAMPP compatibility)
SET @chk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'furever' 
    AND CONSTRAINT_NAME = 'chk_email_format'
);

-- Simple email validation that works with XAMPP
SET @sql = IF(@chk_exists = 0, 
    'ALTER TABLE `users` ADD CONSTRAINT `chk_email_format` CHECK (`email` LIKE "%@%.%");', 
    'SELECT "Check constraint chk_email_format already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Adopter email validation
SET @chk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'furever' 
    AND CONSTRAINT_NAME = 'chk_adopter_email_format'
);

SET @sql = IF(@chk_exists = 0, 
    'ALTER TABLE `tbl_adopter` ADD CONSTRAINT `chk_adopter_email_format` CHECK (`adopter_email` LIKE "%@%.%" OR `adopter_email` IS NULL);', 
    'SELECT "Check constraint chk_adopter_email_format already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Pet owner email validation
SET @chk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'furever' 
    AND CONSTRAINT_NAME = 'chk_owner_email_format'
);

SET @sql = IF(@chk_exists = 0, 
    'ALTER TABLE `tbl_pet_owner` ADD CONSTRAINT `chk_owner_email_format` CHECK (`pet_owner_email` LIKE "%@%.%" OR `pet_owner_email` IS NULL);', 
    'SELECT "Check constraint chk_owner_email_format already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Phone number validation (simplified for XAMPP - Philippine format)
-- Contact should start with 09 or +639 and be 11-13 digits total
SET @chk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'furever' 
    AND CONSTRAINT_NAME = 'chk_adopter_contact_format'
);

SET @sql = IF(@chk_exists = 0, 
    'ALTER TABLE `tbl_adopter` ADD CONSTRAINT `chk_adopter_contact_format` CHECK (`adopter_contact` LIKE "09________%" OR `adopter_contact` LIKE "+639%" OR `adopter_contact` IS NULL);', 
    'SELECT "Check constraint chk_adopter_contact_format already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @chk_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
    WHERE CONSTRAINT_SCHEMA = 'furever' 
    AND CONSTRAINT_NAME = 'chk_owner_contact_format'
);

SET @sql = IF(@chk_exists = 0, 
    'ALTER TABLE `tbl_pet_owner` ADD CONSTRAINT `chk_owner_contact_format` CHECK (`pet_owner_contact` LIKE "09________%" OR `pet_owner_contact` LIKE "+639%" OR `pet_owner_contact` IS NULL);', 
    'SELECT "Check constraint chk_owner_contact_format already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- PHASE 7: PERFORMANCE INDEXES (Execute Last)
-- ============================================================

-- Check if indexes already exist before creating them
SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME 
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'furever' 
AND INDEX_NAME NOT IN ('PRIMARY')
ORDER BY TABLE_NAME, INDEX_NAME;

-- Add performance indexes for common queries (check if they exist first)
SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_pet' 
    AND INDEX_NAME = 'idx_pet_adoption_status'
);

SET @sql = IF(@idx_exists = 0, 
    'CREATE INDEX `idx_pet_adoption_status` ON `tbl_pet` (`adoption_status`);', 
    'SELECT "Index idx_pet_adoption_status already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_pet' 
    AND INDEX_NAME = 'idx_pet_type'
);

SET @sql = IF(@idx_exists = 0, 
    'CREATE INDEX `idx_pet_type` ON `tbl_pet` (`pet_type_id`);', 
    'SELECT "Index idx_pet_type already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption_request' 
    AND INDEX_NAME = 'idx_request_status'
);

SET @sql = IF(@idx_exists = 0, 
    'CREATE INDEX `idx_request_status` ON `tbl_adoption_request` (`status`);', 
    'SELECT "Index idx_request_status already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption_request' 
    AND INDEX_NAME = 'idx_request_date'
);

SET @sql = IF(@idx_exists = 0, 
    'CREATE INDEX `idx_request_date` ON `tbl_adoption_request` (`request_date`);', 
    'SELECT "Index idx_request_date already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_adoption' 
    AND INDEX_NAME = 'idx_adoption_date'
);

SET @sql = IF(@idx_exists = 0, 
    'CREATE INDEX `idx_adoption_date` ON `tbl_adoption` (`adoption_date`);', 
    'SELECT "Index idx_adoption_date already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'users' 
    AND INDEX_NAME = 'idx_user_role'
);

SET @sql = IF(@idx_exists = 0, 
    'CREATE INDEX `idx_user_role` ON `users` (`role`);', 
    'SELECT "Index idx_user_role already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'furever' 
    AND TABLE_NAME = 'tbl_pet' 
    AND INDEX_NAME = 'idx_pet_owner'
);

SET @sql = IF(@idx_exists = 0, 
    'CREATE INDEX `idx_pet_owner` ON `tbl_pet` (`pet_owner_id`);', 
    'SELECT "Index idx_pet_owner already exists" as message;'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================================
-- VERIFICATION QUERIES (Run to verify constraints)
-- ============================================================

-- Check that all constraints were added
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_SCHEMA = 'furever'
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;

-- Check foreign key relationships
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'furever' 
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Check check constraints
SELECT 
    TABLE_NAME,
    CONSTRAINT_NAME,
    CHECK_CLAUSE
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS 
WHERE CONSTRAINT_SCHEMA = 'furever';

-- ============================================================
-- ROLLBACK SCRIPT (Use if needed to undo changes)
-- ============================================================

/*
-- Remove all added constraints (execute in reverse order)
ALTER TABLE `tbl_adopter` DROP FOREIGN KEY `fk_adopter_user`;
ALTER TABLE `tbl_pet_owner` DROP FOREIGN KEY `fk_pet_owner_user`;
ALTER TABLE `tbl_adoption_request` DROP FOREIGN KEY `fk_request_user`;
ALTER TABLE `tbl_adoption` DROP FOREIGN KEY `fk_adoption_user`;

-- Remove check constraints
ALTER TABLE `tbl_pet` DROP CHECK `chk_pet_age`;
ALTER TABLE `tbl_adoption_request` DROP CHECK `chk_approval_date`;
ALTER TABLE `users` DROP CHECK `chk_email_format`;
ALTER TABLE `tbl_adopter` DROP CHECK `chk_adopter_email_format`;
ALTER TABLE `tbl_pet_owner` DROP CHECK `chk_owner_email_format`;
ALTER TABLE `tbl_adopter` DROP CHECK `chk_adopter_contact_format`;
ALTER TABLE `tbl_pet_owner` DROP CHECK `chk_owner_contact_format`;

-- Remove unique constraints
ALTER TABLE `tbl_adoption_request` DROP INDEX `uk_adopter_pet_request`;
ALTER TABLE `tbl_adoption` DROP INDEX `uk_pet_adoption`;

-- Remove added columns
ALTER TABLE `tbl_adopter` DROP COLUMN `username`;
ALTER TABLE `tbl_pet_owner` DROP COLUMN `username`;

-- Revert role enum
ALTER TABLE `users` MODIFY `role` enum('admin','adopter') DEFAULT 'adopter';
*/