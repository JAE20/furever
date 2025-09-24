-- Foreign Key Constraint Diagnostic Script for Furever Pet Adoption System
-- This script helps identify and resolve foreign key constraint violations

USE furever;

-- =============================================================================
-- SECTION 1: Check for orphaned records (violating foreign key constraints)
-- =============================================================================

SELECT 'CHECKING FOR FOREIGN KEY CONSTRAINT VIOLATIONS...' as status;

-- Check for adopters without corresponding users
SELECT 'Adopters without corresponding users:' as check_type;
SELECT a.adopter_id, a.adopter_name, a.username as adopter_username
FROM tbl_adopter a
LEFT JOIN users u ON a.username = u.username
WHERE a.username IS NOT NULL AND u.username IS NULL;

-- Check for pet owners without corresponding users  
SELECT 'Pet owners without corresponding users:' as check_type;
SELECT po.pet_owner_id, po.pet_owner_name, po.username as pet_owner_username
FROM tbl_pet_owner po
LEFT JOIN users u ON po.username = u.username  
WHERE po.username IS NOT NULL AND u.username IS NULL;

-- Check for pets without corresponding pet owners
SELECT 'Pets without corresponding pet owners:' as check_type;
SELECT p.pet_id, p.pet_name, p.pet_owner_id
FROM tbl_pet p
LEFT JOIN tbl_pet_owner po ON p.pet_owner_id = po.pet_owner_id
WHERE po.pet_owner_id IS NULL;

-- Check for adoption requests without corresponding pets or adopters
SELECT 'Adoption requests with invalid pet references:' as check_type;
SELECT ar.adoption_request_id, ar.pet_id, ar.adopter_id
FROM tbl_adoption_request ar
LEFT JOIN tbl_pet p ON ar.pet_id = p.pet_id
WHERE p.pet_id IS NULL;

SELECT 'Adoption requests with invalid adopter references:' as check_type;
SELECT ar.adoption_request_id, ar.pet_id, ar.adopter_id
FROM tbl_adoption_request ar
LEFT JOIN tbl_adopter a ON ar.adopter_id = a.adopter_id
WHERE a.adopter_id IS NULL;

-- =============================================================================
-- SECTION 2: Show current constraint structure
-- =============================================================================

SELECT 'CURRENT FOREIGN KEY CONSTRAINTS:' as status;

SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'furever' 
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- =============================================================================
-- SECTION 3: Data integrity recommendations
-- =============================================================================

SELECT 'DATA INTEGRITY RECOMMENDATIONS:' as status;

-- Count unlinked adopters
SELECT COUNT(*) as unlinked_adopters_count,
       'Adopters not linked to users table' as description
FROM tbl_adopter 
WHERE username IS NULL;

-- Count unlinked pet owners  
SELECT COUNT(*) as unlinked_pet_owners_count,
       'Pet owners not linked to users table' as description
FROM tbl_pet_owner 
WHERE username IS NULL;

-- Show users without corresponding profiles
SELECT 'Users without adopter profiles:' as check_type;
SELECT u.id, u.username, u.email, u.role
FROM users u
LEFT JOIN tbl_adopter a ON u.username = a.username
WHERE u.role = 'adopter' AND a.username IS NULL;

SELECT 'Users without pet owner profiles:' as check_type;
SELECT u.id, u.username, u.email, u.role  
FROM users u
LEFT JOIN tbl_pet_owner po ON u.username = po.username
WHERE u.role = 'pet_owner' AND po.username IS NULL;

-- =============================================================================
-- SECTION 4: Suggested fixes for common issues
-- =============================================================================

SELECT 'SUGGESTED FIXES:' as status;

-- Fix for creating missing user accounts for existing adopters
SELECT 'To fix adopters without user accounts, run:' as fix_type;
SELECT CONCAT(
    'INSERT INTO users (username, email, password, role) VALUES (',
    QUOTE(COALESCE(adopter_username, CONCAT('adopter_', adopter_id))), ', ',
    QUOTE(COALESCE(adopter_email, CONCAT('adopter', adopter_id, '@example.com'))), ', ',
    QUOTE('temp_password'), ', ',
    QUOTE('adopter'), ');'
) as sql_command
FROM tbl_adopter 
WHERE username IS NULL OR (username NOT IN (SELECT username FROM users));

-- Fix for creating missing user accounts for existing pet owners
SELECT 'To fix pet owners without user accounts, run:' as fix_type;
SELECT CONCAT(
    'INSERT INTO users (username, email, password, role) VALUES (',
    QUOTE(COALESCE(pet_owner_username, CONCAT('petowner_', pet_owner_id))), ', ',
    QUOTE(COALESCE(pet_owner_email, CONCAT('petowner', pet_owner_id, '@example.com'))), ', ',
    QUOTE('temp_password'), ', ',
    QUOTE('pet_owner'), ');'
) as sql_command
FROM tbl_pet_owner
WHERE username IS NULL OR (username NOT IN (SELECT username FROM users));

SELECT 'DIAGNOSTIC COMPLETE - Review results above for any constraint violations.' as status;