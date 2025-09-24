-- ===================================================================
-- Fix User-Profile Relationship Issues in Furever Database
-- This script addresses the disconnected relationships between users 
-- table and tbl_adopter/tbl_pet_owner tables
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
-- STEP 1: Create missing user accounts for existing adopters/pet owners
-- ===================================================================

-- Create user accounts for orphaned adopters
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
AND adopter_username NOT IN (SELECT username FROM users WHERE archived = 0);

-- Link existing adopters to newly created user accounts
UPDATE tbl_adopter 
SET username = adopter_username 
WHERE username IS NULL 
AND adopter_username IS NOT NULL
AND adopter_username IN (SELECT username FROM users WHERE archived = 0);

-- ===================================================================
-- STEP 2: Create missing profiles for existing users
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
-- STEP 3: Handle the specific case of "Lara Croft" user
-- ===================================================================

-- The user "Lara Croft" was just created as adopter role
-- Let's create an adopter profile for this user
INSERT INTO tbl_adopter (username, adopter_name, adopter_contact, adopter_email, adopter_address, adopter_username, adopter_password)
SELECT 
    'Lara Croft',
    'Lara Croft',
    '09000000000',
    'jebufebf@werk.com',
    'Address not provided',
    'Lara Croft',
    'dsfgerty'
WHERE NOT EXISTS (
    SELECT 1 FROM tbl_adopter WHERE username = 'Lara Croft'
);

-- ===================================================================
-- STEP 4: Verification queries
-- ===================================================================

SELECT 'VERIFICATION: Users and their profiles after fix' as section;

SELECT 
    u.id,
    u.username,
    u.email, 
    u.role,
    CASE 
        WHEN u.role = 'adopter' THEN COALESCE(a.adopter_id::text, 'NO PROFILE')
        WHEN u.role = 'pet_owner' THEN COALESCE(po.pet_owner_id::text, 'NO PROFILE') 
        ELSE 'N/A'
    END as profile_id,
    CASE
        WHEN u.role = 'adopter' THEN a.adopter_name
        WHEN u.role = 'pet_owner' THEN po.pet_owner_name
        ELSE 'N/A'
    END as profile_name
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND u.role = 'adopter'
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND u.role = 'pet_owner'  
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
LEFT JOIN tbl_adopter a ON u.username = a.username
LEFT JOIN tbl_pet_owner po ON u.username = po.username
WHERE u.archived = 0
AND (
    (u.role = 'adopter' AND a.adopter_id IS NULL) OR
    (u.role = 'pet_owner' AND po.pet_owner_id IS NULL)
);

-- ===================================================================
-- STEP 5: Recommendations for future prevention
-- ===================================================================

SELECT 'RECOMMENDATIONS' as section;
SELECT 'Database schema recommendations:
1. Consider adding triggers to automatically create profiles when users are created
2. Update the UserCRUD class to handle profile creation
3. Consider consolidating duplicate username fields (adopter_username vs username)
4. Add NOT NULL constraints after data is cleaned up
5. Regular data integrity checks' as recommendations;