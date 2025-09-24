-- Quick fix for the current "Moore12" pet owner creation issue
-- This script creates the missing user account that caused the foreign key constraint failure

USE furever;

-- Check if user already exists
SELECT 'Checking if user Moore12 exists:' as status;
SELECT COUNT(*) as user_exists FROM users WHERE username = 'Moore12';

-- Create the missing user account for Moore12
INSERT IGNORE INTO users (username, email, password, role, created_at) 
VALUES ('Moore12', 'hdhdid@gmail.com', '123', 'pet_owner', NOW());

-- Verify the user was created
SELECT 'User Moore12 created successfully:' as status;
SELECT * FROM users WHERE username = 'Moore12';

-- Now the pet owner can be created manually through the application
SELECT 'You can now retry creating the pet owner "Rebecca" with username "Moore12" through the application.' as message;