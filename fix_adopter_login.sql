-- Fix for Adopter Login Issue
-- This script resolves the disconnect between users and tbl_adopter tables

-- Problem: User 'Adopter20' exists in users table but has no corresponding record in tbl_adopter
-- with matching username field (required by foreign key constraint)

-- Check current state first
SELECT 'Current users table data:' as info;
SELECT * FROM users WHERE username = 'Adopter20';

SELECT 'Current adopter table data:' as info;
SELECT * FROM tbl_adopter WHERE username = 'Adopter20' OR adopter_email = 'adopter1@example.com';

-- Solution 1: Create a proper adopter record for the existing user
-- Note: Using unique email to avoid conflicts with existing data
INSERT INTO `tbl_adopter` (
    `username`, 
    `adopter_name`, 
    `adopter_contact`, 
    `adopter_email`, 
    `adopter_address`, 
    `adopter_profile`
) VALUES (
    'Adopter20',                    -- Links to users.username (foreign key)
    'Adopter Twenty',               -- Display name
    '09123456789',                  -- Contact number  
    'adopter20@example.com',        -- Unique email (different from existing records)
    '123 Test Address, City',       -- Address
    'Auto-created profile for user login'  -- Profile note
);

-- Solution 2: Alternative - Update existing adopter record to link to users table
-- (Only use this if you want to link an existing adopter instead of creating new one)
-- UPDATE `tbl_adopter` 
-- SET `username` = 'Adopter20' 
-- WHERE `adopter_id` = 3 AND `adopter_email` = 'adopter1@example.com';

-- Verification query
SELECT 'Verification - Check if adopter is now linked:' as info;
SELECT a.*, u.email as user_email, u.role 
FROM tbl_adopter a 
JOIN users u ON a.username = u.username 
WHERE u.username = 'Adopter20';

-- Verification queries:
-- Check the link between users and adopters
-- SELECT u.id, u.username, u.role, a.adopter_id, a.adopter_name 
-- FROM users u 
-- LEFT JOIN tbl_adopter a ON u.username = a.username 
-- WHERE u.role = 'adopter';

-- Test authentication
-- SELECT * FROM users WHERE username = 'Adopter20' AND password = 'adoptme';