-- ===================================================================
-- Quick Fix for Immediate User-Profile Relationship Issues
-- This handles the specific "Lara Croft" case and existing orphaned records
-- ===================================================================

-- Step 1: Add the missing "Lara Croft" user that was mentioned in the dashboard
INSERT IGNORE INTO users (username, email, password, role, created_at)
VALUES ('Lara Croft', 'laracroft_unique@example.com', 'dsfgerty', 'adopter', NOW());

-- Step 2: Fix duplicate email issue by making adopter emails unique
UPDATE tbl_adopter 
SET adopter_email = CASE 
    WHEN adopter_id = 1 THEN 'alice_1@example.com'
    WHEN adopter_id = 2 THEN 'mark_2@example.com' 
    WHEN adopter_id = 3 THEN 'john_3@example.com'
    WHEN adopter_id = 4 THEN 'theresa_4@example.com'
    ELSE adopter_email
END
WHERE adopter_id IN (1, 2, 3, 4) AND username IS NULL;

-- Step 3: Create user accounts for existing adopters with unique emails
INSERT IGNORE INTO users (username, email, password, role, created_at)
SELECT 
    adopter_username,
    adopter_email,
    COALESCE(adopter_password, 'defaultpass123'),
    'adopter',
    NOW()
FROM tbl_adopter 
WHERE username IS NULL 
AND adopter_username IS NOT NULL 
AND adopter_email IS NOT NULL
AND archived = 0;

-- Step 4: Link adopters to their user accounts
UPDATE tbl_adopter 
SET username = adopter_username 
WHERE username IS NULL 
AND adopter_username IS NOT NULL
AND adopter_username IN (SELECT username FROM users WHERE archived = 0);

-- Step 5: Create adopter profile for "Lara Croft" user
INSERT IGNORE INTO tbl_adopter (username, adopter_name, adopter_contact, adopter_email, adopter_address, adopter_username, adopter_password)
VALUES (
    'Lara Croft',
    'Lara Croft',
    '09000000000',
    'laracroft_unique@example.com',
    'Address not provided',
    'Lara Croft',
    'dsfgerty'
);

-- Step 6: Create profiles for any users missing them
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

-- Step 7: Create profiles for pet owners missing them
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

-- Step 8: Verification - show the final state
SELECT 'FINAL VERIFICATION: All users and their profiles' as result;

SELECT 
    u.id as user_id,
    u.username,
    u.email,
    u.role,
    CASE 
        WHEN u.role = 'admin' THEN 'No profile needed'
        WHEN u.role = 'adopter' THEN 
            CASE 
                WHEN a.adopter_id IS NOT NULL THEN CONCAT('✓ Profile ID: ', a.adopter_id)
                ELSE '✗ No profile found'
            END
        WHEN u.role = 'pet_owner' THEN
            CASE
                WHEN po.pet_owner_id IS NOT NULL THEN CONCAT('✓ Profile ID: ', po.pet_owner_id)
                ELSE '✗ No profile found'
            END
    END as profile_status
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND a.archived = 0
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND po.archived = 0
WHERE u.archived = 0
ORDER BY u.id;

-- Step 9: Show any remaining issues
SELECT 'REMAINING ISSUES TO RESOLVE' as result;

SELECT 'Orphaned adopters (no user account):' as issue_type, COUNT(*) as count
FROM tbl_adopter 
WHERE username IS NULL AND archived = 0

UNION ALL

SELECT 'Orphaned pet owners (no user account):' as issue_type, COUNT(*) as count
FROM tbl_pet_owner
WHERE username IS NULL AND archived = 0

UNION ALL

SELECT 'Users without adopter profiles:' as issue_type, COUNT(*) as count
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username
WHERE u.role = 'adopter' AND a.adopter_id IS NULL AND u.archived = 0

UNION ALL

SELECT 'Users without pet owner profiles:' as issue_type, COUNT(*) as count
FROM users u
LEFT JOIN tbl_pet_owner po ON u.username = po.username
WHERE u.role = 'pet_owner' AND po.pet_owner_id IS NULL AND u.archived = 0;