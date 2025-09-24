-- Fix date_registered column to have proper default value
USE furever;

-- Check current table structure
DESCRIBE tbl_pet;

-- Update the date_registered column to have a default value
ALTER TABLE tbl_pet 
MODIFY COLUMN `date_registered` date NOT NULL DEFAULT (CURRENT_DATE);

-- Verify the change
DESCRIBE tbl_pet;

-- Show the specific column info
SHOW COLUMNS FROM tbl_pet WHERE Field = 'date_registered';