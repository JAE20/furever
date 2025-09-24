-- ===================================================================
-- Complete Database Relationship Fix and Constraint Validation
-- This script ensures proper foreign key relationships and data integrity
-- ===================================================================

-- PHASE 1: Analysis of Current State
-- ===================================================================

SELECT '=== CURRENT DATABASE ANALYSIS ===' as phase;

-- Show current users
SELECT 'Current Users:' as info;
SELECT id, username, email, role, created_at 
FROM users 
WHERE archived = 0 
ORDER BY id;

-- Show adopters and their user links
SELECT 'Current Adopters:' as info;
SELECT adopter_id, username, adopter_name, adopter_email, adopter_username
FROM tbl_adopter 
WHERE archived = 0 
ORDER BY adopter_id;

-- Show pet owners and their user links
SELECT 'Current Pet Owners:' as info;
SELECT pet_owner_id, username, pet_owner_name, pet_owner_email, pet_owner_username
FROM tbl_pet_owner 
WHERE archived = 0 
ORDER BY pet_owner_id;

-- PHASE 2: Fix Data Inconsistencies
-- ===================================================================

SELECT '=== PHASE 2: FIXING DATA INCONSISTENCIES ===' as phase;

-- First, handle duplicate emails by making them unique
UPDATE tbl_adopter 
SET adopter_email = CASE 
    WHEN adopter_id = 1 AND adopter_email = 'adopter1@example.com' THEN 'alice.johnson@example.com'
    WHEN adopter_id = 2 THEN 'mark.cruz@example.com'
    WHEN adopter_id = 3 AND adopter_email = 'adopter1@example.com' THEN 'john.adopter@example.com'
    WHEN adopter_id = 4 THEN 'theresa.gina@example.com'
    ELSE adopter_email
END
WHERE adopter_id IN (1, 2, 3, 4);

-- Create missing user accounts for existing adopters
INSERT IGNORE INTO users (username, email, password, role, created_at)
VALUES
('alicej', 'alice.johnson@example.com', 'password123', 'adopter', NOW()),
('markc', 'mark.cruz@example.com', 'password123', 'adopter', NOW()),
('adopter1', 'john.adopter@example.com', 'iwantmydaddy', 'adopter', NOW()),
('ginathis', 'theresa.gina@example.com', 'Sdfg123', 'adopter', NOW());

-- Link existing adopters to their user accounts
UPDATE tbl_adopter SET username = 'alicej' WHERE adopter_id = 1 AND username IS NULL;
UPDATE tbl_adopter SET username = 'markc' WHERE adopter_id = 2 AND username IS NULL;
UPDATE tbl_adopter SET username = 'adopter1' WHERE adopter_id = 3 AND username IS NULL;
UPDATE tbl_adopter SET username = 'ginathis' WHERE adopter_id = 4 AND username IS NULL;

-- Handle the case where "Lara Croft" user might exist but not have a profile
-- First check if user exists, if not create it
INSERT IGNORE INTO users (username, email, password, role, created_at)
VALUES ('Lara Croft', 'lara.croft@example.com', 'dsfgerty', 'adopter', NOW());

-- Create adopter profile for Lara Croft if it doesn't exist
INSERT IGNORE INTO tbl_adopter (username, adopter_name, adopter_contact, adopter_email, adopter_address, adopter_username, adopter_password)
VALUES (
    'Lara Croft',
    'Lara Croft', 
    '09000000000',
    'lara.croft@example.com',
    'Tomb Raider Mansion',
    'Lara Croft',
    'dsfgerty'
);

-- PHASE 3: Create Missing Profiles for Existing Users
-- ===================================================================

SELECT '=== PHASE 3: CREATING MISSING PROFILES ===' as phase;

-- Create adopter profiles for users who don't have them
INSERT IGNORE INTO tbl_adopter (username, adopter_name, adopter_contact, adopter_email, adopter_address, adopter_username, adopter_password)
SELECT 
    u.username,
    u.username,
    '09000000000',
    u.email,
    'Address not provided',
    u.username,
    u.password
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username
WHERE u.role = 'adopter' 
AND a.adopter_id IS NULL 
AND u.archived = 0;

-- Create pet owner profiles for users who don't have them
INSERT IGNORE INTO tbl_pet_owner (username, pet_owner_name, pet_owner_contact, pet_owner_email, pet_owner_address, pet_owner_username, pet_owner_password)
SELECT 
    u.username,
    u.username,
    '09000000000',
    u.email,
    'Address not provided',
    u.username,
    u.password
FROM users u
LEFT JOIN tbl_pet_owner po ON u.username = po.username
WHERE u.role = 'pet_owner' 
AND po.pet_owner_id IS NULL 
AND u.archived = 0;

-- PHASE 4: Validate Foreign Key Constraints
-- ===================================================================

SELECT '=== PHASE 4: FOREIGN KEY CONSTRAINT VALIDATION ===' as phase;

-- Check if all adopter username references are valid
SELECT 'Invalid adopter-user references:' as check_result;
SELECT a.adopter_id, a.username as adopter_username, 'User not found' as issue
FROM tbl_adopter a
LEFT JOIN users u ON a.username = u.username
WHERE a.username IS NOT NULL 
AND u.username IS NULL 
AND a.archived = 0;

-- Check if all pet owner username references are valid
SELECT 'Invalid pet_owner-user references:' as check_result;
SELECT po.pet_owner_id, po.username as pet_owner_username, 'User not found' as issue
FROM tbl_pet_owner po
LEFT JOIN users u ON po.username = u.username
WHERE po.username IS NOT NULL 
AND u.username IS NULL 
AND po.archived = 0;

-- PHASE 5: Final Verification and Summary
-- ===================================================================

SELECT '=== FINAL VERIFICATION RESULTS ===' as phase;

-- Complete user-profile mapping
SELECT 'Complete User-Profile Mapping:' as summary;
SELECT 
    u.id,
    u.username,
    u.email,
    u.role,
    u.created_at,
    CASE 
        WHEN u.role = 'admin' THEN 'Admin - No profile needed'
        WHEN u.role = 'adopter' THEN 
            CASE 
                WHEN a.adopter_id IS NOT NULL THEN CONCAT('✓ Adopter Profile ID: ', a.adopter_id, ' (', a.adopter_name, ')')
                ELSE '❌ MISSING ADOPTER PROFILE'
            END
        WHEN u.role = 'pet_owner' THEN
            CASE
                WHEN po.pet_owner_id IS NOT NULL THEN CONCAT('✓ Pet Owner Profile ID: ', po.pet_owner_id, ' (', po.pet_owner_name, ')')
                ELSE '❌ MISSING PET OWNER PROFILE'
            END
        ELSE '? Unknown role'
    END as profile_status
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND a.archived = 0
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND po.archived = 0
WHERE u.archived = 0
ORDER BY u.id;

-- Summary statistics
SELECT 'Summary Statistics:' as summary;
SELECT 
    'Total Users' as metric,
    COUNT(*) as count
FROM users 
WHERE archived = 0

UNION ALL

SELECT 
    'Admin Users' as metric,
    COUNT(*) as count
FROM users 
WHERE role = 'admin' AND archived = 0

UNION ALL

SELECT 
    'Adopter Users' as metric,
    COUNT(*) as count
FROM users 
WHERE role = 'adopter' AND archived = 0

UNION ALL

SELECT 
    'Pet Owner Users' as metric,
    COUNT(*) as count
FROM users 
WHERE role = 'pet_owner' AND archived = 0

UNION ALL

SELECT 
    'Adopter Profiles' as metric,
    COUNT(*) as count
FROM tbl_adopter 
WHERE archived = 0 AND username IS NOT NULL

UNION ALL

SELECT 
    'Pet Owner Profiles' as metric,
    COUNT(*) as count
FROM tbl_pet_owner 
WHERE archived = 0 AND username IS NOT NULL

UNION ALL

SELECT 
    'Orphaned Adopter Records' as metric,
    COUNT(*) as count
FROM tbl_adopter 
WHERE archived = 0 AND username IS NULL

UNION ALL

SELECT 
    'Orphaned Pet Owner Records' as metric,
    COUNT(*) as count
FROM tbl_pet_owner 
WHERE archived = 0 AND username IS NULL;

-- Final constraint validation
SELECT 'Constraint Validation Results:' as summary;
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM tbl_adopter a LEFT JOIN users u ON a.username = u.username WHERE a.username IS NOT NULL AND u.username IS NULL AND a.archived = 0) = 0
        THEN '✓ All adopter foreign key constraints are valid'
        ELSE '❌ Some adopter foreign key constraints are invalid'
    END as adopter_constraints,
    CASE 
        WHEN (SELECT COUNT(*) FROM tbl_pet_owner po LEFT JOIN users u ON po.username = u.username WHERE po.username IS NOT NULL AND u.username IS NULL AND po.archived = 0) = 0
        THEN '✓ All pet owner foreign key constraints are valid'
        ELSE '❌ Some pet owner foreign key constraints are invalid'
    END as pet_owner_constraints;

SELECT '=== RELATIONSHIP FIX COMPLETED ===' as phase;