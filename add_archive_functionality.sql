-- Add archive functionality to Furever Pet Adoption System
-- This script adds 'archived' and 'archived_date' columns to main tables
-- Fixed to match actual database schema from furever.sql

USE furever;

-- Check current table structure before making changes
SELECT 'Current table structures:' as info;
SHOW TABLES;

-- Add archive functionality to users table (not tbl_user)
ALTER TABLE users 
ADD COLUMN archived BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN archived_date DATETIME NULL;

-- Add archive functionality to tbl_pet
ALTER TABLE tbl_pet 
ADD COLUMN archived BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN archived_date DATETIME NULL;

-- Add archive functionality to tbl_pet_owner
ALTER TABLE tbl_pet_owner 
ADD COLUMN archived BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN archived_date DATETIME NULL;

-- Add archive functionality to tbl_adopter
ALTER TABLE tbl_adopter 
ADD COLUMN archived BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN archived_date DATETIME NULL;

-- Add archive functionality to tbl_adoption_request
ALTER TABLE tbl_adoption_request 
ADD COLUMN archived BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN archived_date DATETIME NULL;

-- Add archive functionality to tbl_adoption (completed adoptions)
ALTER TABLE tbl_adoption 
ADD COLUMN archived BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN archived_date DATETIME NULL;

-- Add indexes for better performance on archive queries
CREATE INDEX idx_users_archived ON users(archived);
CREATE INDEX idx_pet_archived ON tbl_pet(archived);
CREATE INDEX idx_pet_owner_archived ON tbl_pet_owner(archived);
CREATE INDEX idx_adopter_archived ON tbl_adopter(archived);
CREATE INDEX idx_adoption_request_archived ON tbl_adoption_request(archived);
CREATE INDEX idx_adoption_archived ON tbl_adoption(archived);

-- Verify the changes
SELECT 'Verifying archive columns were added:' as info;
DESCRIBE users;
DESCRIBE tbl_pet;
DESCRIBE tbl_pet_owner;
DESCRIBE tbl_adopter;
DESCRIBE tbl_adoption_request;
DESCRIBE tbl_adoption;

SELECT 'Archive functionality added successfully!' as message;

-- Example usage queries for archive functionality:

-- Archive a user (soft delete)
-- UPDATE users SET archived = TRUE, archived_date = NOW() WHERE username = 'someuser';

-- Archive a pet
-- UPDATE tbl_pet SET archived = TRUE, archived_date = NOW() WHERE pet_id = 1;

-- Archive an adoption request
-- UPDATE tbl_adoption_request SET archived = TRUE, archived_date = NOW() WHERE adoption_request_id = 1;

-- Query to get only active (non-archived) records:
-- SELECT * FROM users WHERE archived = FALSE;
-- SELECT * FROM tbl_pet WHERE archived = FALSE;
-- SELECT * FROM tbl_adopter WHERE archived = FALSE;

-- Query to get archived records:
-- SELECT * FROM users WHERE archived = TRUE ORDER BY archived_date DESC;

-- Restore from archive:
-- UPDATE users SET archived = FALSE, archived_date = NULL WHERE username = 'someuser';