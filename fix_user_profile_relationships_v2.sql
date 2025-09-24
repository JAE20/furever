-- ===================================================================
-- Fix User-Profile Relationship Issues in Furever Database (Version 2)
-- This script addresses the disconnected relationships between users 
-- table and tbl_adopter/tbl_pet_owner tables with proper duplicate handling
-- ===================================================================

-- First, let's see the current state of our data
SELECT 'CURRENT USERS TABLE' as section;
SELECT id, username, email, role, created_at FROM users WHERE archived = 0;

SELECT 'CURRENT ADOPTERS WITH USERNAME LINKS' as section;
SELECT adopter_id, username, adopter_name, adopter_email, adopter_username FROM tbl_adopter WHERE archived = 0;

SELECT 'CURRENT PET OWNERS WITH USERNAME LINKS' as section;  
SELECT pet_owner_id, username, pet_owner_name, pet_owner_email, pet_owner_username FROM tbl_pet_owner WHERE archived = 0;

SELECT 'ORPHANED ADOPTERS (no user link)' as section;
SELECT adopter_id, adopter_name, adopter_email, adopter_username 
FROM tbl_adopter 
WHERE username IS NULL AND archived = 0;

SELECT 'DUPLICATE EMAIL ISSUE ANALYSIS' as section;
SELECT adopter_email, COUNT(*) as count
FROM tbl_adopter 
WHERE username IS NULL AND archived = 0
GROUP BY adopter_email
HAVING COUNT(*) > 1;

SELECT 'ORPHANED USERS (adopters without profiles)' as section;
SELECT u.id, u.username, u.email, u.role
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username
WHERE u.role = 'adopter' AND a.adopter_id IS NULL AND u.archived = 0;

SELECT 'ORPHANED USERS (pet owners without profiles)' as section;
SELECT u.id, u.username, u.email, u.role
FROM users u  
LEFT JOIN tbl_pet_owner po ON u.username = po.username
WHERE u.role = 'pet_owner' AND po.pet_owner_id IS NULL AND u.archived = 0;

-- ===================================================================
-- STEP 1: Handle duplicate email addresses by making them unique
-- ===================================================================

-- First, let's create unique emails for duplicate entries
UPDATE tbl_adopter 
SET adopter_email = CONCAT(
    SUBSTRING_INDEX(adopter_email, '@', 1), 
    '_', 
    adopter_id,
    '@',
    SUBSTRING_INDEX(adopter_email, '@', -1)
)
WHERE adopter_id IN (
    SELECT * FROM (
        SELECT a1.adopter_id
        FROM tbl_adopter a1
        WHERE a1.username IS NULL 
        AND a1.archived = 0
        AND EXISTS (
            SELECT 1 FROM tbl_adopter a2 
            WHERE a2.adopter_email = a1.adopter_email 
            AND a2.adopter_id != a1.adopter_id
            AND a2.username IS NULL 
            AND a2.archived = 0
        )
        AND a1.adopter_id > (
            SELECT MIN(a3.adopter_id) 
            FROM tbl_adopter a3 
            WHERE a3.adopter_email = a1.adopter_email
            AND a3.username IS NULL 
            AND a3.archived = 0
        )
    ) AS temp_table
);

-- ===================================================================
-- STEP 2: Create missing user accounts for existing adopters/pet owners
-- ===================================================================

-- Create user accounts for orphaned adopters (now with unique emails)
INSERT INTO users (username, email, password, role, created_at)
SELECT 
    adopter_username,
    adopter_email,
    COALESCE(adopter_password, 'defaultpass123'), -- Use existing password or default
    'adopter',
    NOW()
FROM tbl_adopter 
WHERE username IS NULL 
AND adopter_username IS NOT NULL 
AND adopter_email IS NOT NULL
AND archived = 0
AND adopter_username NOT IN (SELECT username FROM users WHERE archived = 0)
AND adopter_email NOT IN (SELECT email FROM users WHERE archived = 0);

-- Link existing adopters to newly created user accounts
UPDATE tbl_adopter 
SET username = adopter_username 
WHERE username IS NULL 
AND adopter_username IS NOT NULL
AND adopter_username IN (SELECT username FROM users WHERE archived = 0);

-- Handle pet owners (they shouldn't have duplicate emails, but let's be safe)
UPDATE tbl_pet_owner 
SET pet_owner_email = CONCAT(
    SUBSTRING_INDEX(pet_owner_email, '@', 1), 
    '_', 
    pet_owner_id,
    '@',
    SUBSTRING_INDEX(pet_owner_email, '@', -1)
)
WHERE pet_owner_id IN (
    SELECT * FROM (
        SELECT po1.pet_owner_id
        FROM tbl_pet_owner po1
        WHERE po1.username IS NULL 
        AND po1.archived = 0
        AND EXISTS (
            SELECT 1 FROM tbl_pet_owner po2 
            WHERE po2.pet_owner_email = po1.pet_owner_email 
            AND po2.pet_owner_id != po1.pet_owner_id
            AND po2.username IS NULL 
            AND po2.archived = 0
        )
        AND po1.pet_owner_id > (
            SELECT MIN(po3.pet_owner_id) 
            FROM tbl_pet_owner po3 
            WHERE po3.pet_owner_email = po1.pet_owner_email
            AND po3.username IS NULL 
            AND po3.archived = 0
        )
    ) AS temp_table
);

-- Create user accounts for orphaned pet owners
INSERT INTO users (username, email, password, role, created_at)
SELECT 
    pet_owner_username,
    pet_owner_email,
    COALESCE(pet_owner_password, 'defaultpass123'), -- Use existing password or default
    'pet_owner',
    NOW()
FROM tbl_pet_owner 
WHERE username IS NULL 
AND pet_owner_username IS NOT NULL 
AND pet_owner_email IS NOT NULL
AND archived = 0
AND pet_owner_username NOT IN (SELECT username FROM users WHERE archived = 0)
AND pet_owner_email NOT IN (SELECT email FROM users WHERE archived = 0);

-- Link existing pet owners to newly created user accounts
UPDATE tbl_pet_owner 
SET username = pet_owner_username 
WHERE username IS NULL 
AND pet_owner_username IS NOT NULL
AND pet_owner_username IN (SELECT username FROM users WHERE archived = 0);

-- ===================================================================
-- STEP 3: Create missing profiles for existing users
-- ===================================================================

-- Create adopter profiles for users with adopter role but no profile
INSERT INTO tbl_adopter (username, adopter_name, adopter_contact, adopter_email, adopter_address, adopter_username, adopter_password)
SELECT 
    u.username,
    u.username, -- Use username as display name initially
    '09000000000', -- Default contact
    u.email,
    'Address not provided',
    u.username,
    u.password
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username
WHERE u.role = 'adopter' 
AND a.adopter_id IS NULL 
AND u.archived = 0;

-- Create pet owner profiles for users with pet_owner role but no profile  
INSERT INTO tbl_pet_owner (username, pet_owner_name, pet_owner_contact, pet_owner_email, pet_owner_address, pet_owner_username, pet_owner_password)
SELECT 
    u.username,
    u.username, -- Use username as display name initially
    '09000000000', -- Default contact
    u.email,
    'Address not provided',
    u.username,
    u.password
FROM users u
LEFT JOIN tbl_pet_owner po ON u.username = po.username
WHERE u.role = 'pet_owner' 
AND po.pet_owner_id IS NULL 
AND u.archived = 0;

-- ===================================================================
-- STEP 4: Handle users that exist but don't have corresponding profiles
-- ===================================================================

-- Check if "Lara Croft" user exists and create profile if missing
INSERT INTO tbl_adopter (username, adopter_name, adopter_contact, adopter_email, adopter_address, adopter_username, adopter_password)
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
WHERE u.username = 'Lara Croft'
AND u.role = 'adopter'
AND a.adopter_id IS NULL
AND u.archived = 0;

-- ===================================================================
-- STEP 5: Clean up and verify relationships
-- ===================================================================

-- Update any NULL username fields in adopter table where we can match by email
UPDATE tbl_adopter a
INNER JOIN users u ON a.adopter_email = u.email AND u.role = 'adopter'
SET a.username = u.username
WHERE a.username IS NULL 
AND a.archived = 0 
AND u.archived = 0;

-- Update any NULL username fields in pet_owner table where we can match by email
UPDATE tbl_pet_owner po
INNER JOIN users u ON po.pet_owner_email = u.email AND u.role = 'pet_owner'
SET po.username = u.username
WHERE po.username IS NULL 
AND po.archived = 0 
AND u.archived = 0;

-- ===================================================================
-- STEP 6: Verification queries
-- ===================================================================

SELECT 'VERIFICATION: Users and their profiles after fix' as section;

SELECT 
    u.id,
    u.username,
    u.email, 
    u.role,
    CASE 
        WHEN u.role = 'adopter' THEN COALESCE(CAST(a.adopter_id AS CHAR), 'NO PROFILE')
        WHEN u.role = 'pet_owner' THEN COALESCE(CAST(po.pet_owner_id AS CHAR), 'NO PROFILE') 
        ELSE 'N/A'
    END as profile_id,
    CASE
        WHEN u.role = 'adopter' THEN a.adopter_name
        WHEN u.role = 'pet_owner' THEN po.pet_owner_name
        ELSE 'N/A'
    END as profile_name
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND u.role = 'adopter' AND a.archived = 0
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND u.role = 'pet_owner' AND po.archived = 0
WHERE u.archived = 0
ORDER BY u.role, u.username;

SELECT 'VERIFICATION: Remaining orphaned records' as section;

SELECT 'Adopters without user accounts:' as issue;
SELECT adopter_id, adopter_name, adopter_username, username
FROM tbl_adopter 
WHERE username IS NULL AND archived = 0;

SELECT 'Pet owners without user accounts:' as issue;  
SELECT pet_owner_id, pet_owner_name, pet_owner_username, username
FROM tbl_pet_owner
WHERE username IS NULL AND archived = 0;

SELECT 'Users without profiles:' as issue;
SELECT u.username, u.role, 'Missing profile' as issue_detail
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND a.archived = 0
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND po.archived = 0
WHERE u.archived = 0
AND (
    (u.role = 'adopter' AND a.adopter_id IS NULL) OR
    (u.role = 'pet_owner' AND po.pet_owner_id IS NULL)
);

-- ===================================================================
-- STEP 7: Foreign Key Constraint Validation
-- ===================================================================

SELECT 'FOREIGN KEY CONSTRAINT VALIDATION' as section;

-- Check if all foreign key relationships are valid
SELECT 'Valid adopter-user relationships:' as check_type;
SELECT COUNT(*) as valid_count
FROM tbl_adopter a
INNER JOIN users u ON a.username = u.username
WHERE a.archived = 0 AND u.archived = 0;

SELECT 'Valid pet_owner-user relationships:' as check_type;
SELECT COUNT(*) as valid_count
FROM tbl_pet_owner po
INNER JOIN users u ON po.username = u.username
WHERE po.archived = 0 AND u.archived = 0;

-- Check for any constraint violations
SELECT 'Constraint violations (should be 0):' as check_type;
SELECT 
    'tbl_adopter' as table_name,
    COUNT(*) as violation_count
FROM tbl_adopter a
LEFT JOIN users u ON a.username = u.username
WHERE a.username IS NOT NULL 
AND u.username IS NULL 
AND a.archived = 0

UNION ALL

SELECT 
    'tbl_pet_owner' as table_name,
    COUNT(*) as violation_count
FROM tbl_pet_owner po
LEFT JOIN users u ON po.username = u.username
WHERE po.username IS NOT NULL 
AND u.username IS NULL 
AND po.archived = 0;

-- ===================================================================
-- STEP 8: Summary statistics
-- ===================================================================

SELECT 'FINAL SUMMARY STATISTICS' as section;

SELECT 
    u.role,
    COUNT(*) as total_users,
    COUNT(CASE WHEN u.role = 'adopter' THEN a.adopter_id END) as linked_adopters,
    COUNT(CASE WHEN u.role = 'pet_owner' THEN po.pet_owner_id END) as linked_pet_owners,
    CASE 
        WHEN u.role = 'adopter' THEN 
            ROUND((COUNT(CASE WHEN u.role = 'adopter' THEN a.adopter_id END) / COUNT(*)) * 100, 2)
        WHEN u.role = 'pet_owner' THEN
            ROUND((COUNT(CASE WHEN u.role = 'pet_owner' THEN po.pet_owner_id END) / COUNT(*)) * 100, 2)
        ELSE 100.00
    END as link_percentage
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND a.archived = 0
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND po.archived = 0
WHERE u.archived = 0
GROUP BY u.role
ORDER BY u.role;