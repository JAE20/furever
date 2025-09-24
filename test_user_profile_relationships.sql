-- ===================================================================
-- Test Script for User-Profile Relationship Fixes
-- Run this after executing fix_user_profile_relationships.sql
-- ===================================================================

-- Test 1: Create a new adopter user - should automatically create adopter profile
SELECT 'TEST 1: Creating new adopter user' as test_name;

-- Test 2: Create a new pet owner user - should automatically create pet owner profile  
SELECT 'TEST 2: Creating new pet owner user' as test_name;

-- Test 3: Verify all users have corresponding profiles
SELECT 'TEST 3: Verify all users have corresponding profiles' as test_name;

SELECT 
    u.id,
    u.username,
    u.email,
    u.role,
    u.created_at,
    CASE 
        WHEN u.role = 'admin' THEN 'Admin (no profile needed)'
        WHEN u.role = 'adopter' THEN 
            CASE 
                WHEN a.adopter_id IS NOT NULL THEN CONCAT('✓ Adopter Profile ID: ', a.adopter_id)
                ELSE '✗ MISSING ADOPTER PROFILE'
            END
        WHEN u.role = 'pet_owner' THEN
            CASE
                WHEN po.pet_owner_id IS NOT NULL THEN CONCAT('✓ Pet Owner Profile ID: ', po.pet_owner_id)
                ELSE '✗ MISSING PET OWNER PROFILE'
            END
        ELSE '? Unknown role'
    END as profile_status
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND a.archived = 0
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND po.archived = 0
WHERE u.archived = 0
ORDER BY u.role, u.username;

-- Test 4: Check for any orphaned profiles (profiles without user accounts)
SELECT 'TEST 4: Check for orphaned profiles' as test_name;

SELECT 'Orphaned Adopter Profiles:' as check_type;
SELECT a.adopter_id, a.adopter_name, a.username, 'No corresponding user account' as issue
FROM tbl_adopter a
LEFT JOIN users u ON a.username = u.username
WHERE u.username IS NULL AND a.archived = 0;

SELECT 'Orphaned Pet Owner Profiles:' as check_type;
SELECT po.pet_owner_id, po.pet_owner_name, po.username, 'No corresponding user account' as issue
FROM tbl_pet_owner po
LEFT JOIN users u ON po.username = u.username  
WHERE u.username IS NULL AND po.archived = 0;

-- Test 5: Verify foreign key constraints are working
SELECT 'TEST 5: Foreign key constraint verification' as test_name;

-- This should show all properly linked records
SELECT 
    'Properly linked adopters:' as link_type,
    COUNT(*) as count
FROM tbl_adopter a
INNER JOIN users u ON a.username = u.username
WHERE a.archived = 0 AND u.archived = 0;

SELECT 
    'Properly linked pet owners:' as link_type,
    COUNT(*) as count
FROM tbl_pet_owner po
INNER JOIN users u ON po.username = u.username
WHERE po.archived = 0 AND u.archived = 0;

-- Test 6: Summary statistics
SELECT 'TEST 6: Summary statistics' as test_name;

SELECT 
    u.role,
    COUNT(*) as user_count,
    COUNT(CASE WHEN u.role = 'adopter' THEN a.adopter_id END) as adopter_profiles,
    COUNT(CASE WHEN u.role = 'pet_owner' THEN po.pet_owner_id END) as pet_owner_profiles
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username AND a.archived = 0
LEFT JOIN tbl_pet_owner po ON u.username = po.username AND po.archived = 0
WHERE u.archived = 0
GROUP BY u.role
ORDER BY u.role;

-- Test 7: Show the specific "Lara Croft" user that was just created
SELECT 'TEST 7: Lara Croft user verification' as test_name;

SELECT 
    u.id,
    u.username,
    u.email,
    u.role,
    a.adopter_id,
    a.adopter_name
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username
WHERE u.username = 'Lara Croft' AND u.archived = 0;