# Database Schema Constraints - Comprehensive Recommendations

## Current Constraint Analysis

### Existing Constraints ✅
1. **Primary Keys**: All tables have proper primary keys
2. **Basic Foreign Keys**: Core relationships are established
3. **Unique Constraints**: Username/email uniqueness enforced

### Missing Critical Constraints ⚠️

## Recommended Constraint Improvements

### 1. User Authentication Integration

#### Add Pet Owner Role Support
```sql
-- Extend user roles to include pet_owner
ALTER TABLE `users` 
MODIFY `role` enum('admin','adopter','pet_owner') DEFAULT 'adopter';
```

#### Link Profile Tables to Users Table
```sql
-- Add username reference to tbl_adopter (if not exists)
ALTER TABLE `tbl_adopter` 
ADD COLUMN `username` varchar(50) UNIQUE AFTER `adopter_id`,
ADD CONSTRAINT `fk_adopter_user` 
FOREIGN KEY (`username`) REFERENCES `users`(`username`) 
ON UPDATE CASCADE ON DELETE SET NULL;

-- Add username reference to tbl_pet_owner
ALTER TABLE `tbl_pet_owner` 
ADD COLUMN `username` varchar(50) UNIQUE AFTER `pet_owner_id`,
ADD CONSTRAINT `fk_pet_owner_user` 
FOREIGN KEY (`username`) REFERENCES `users`(`username`) 
ON UPDATE CASCADE ON DELETE SET NULL;
```

### 2. Data Integrity Constraints

#### Add NOT NULL Constraints for Critical Fields
```sql
-- Users table - ensure critical fields are not null
ALTER TABLE `users` 
MODIFY `username` varchar(50) NOT NULL,
MODIFY `email` varchar(100) NOT NULL,
MODIFY `password` varchar(255) NOT NULL,
MODIFY `role` enum('admin','adopter','pet_owner') NOT NULL DEFAULT 'adopter';

-- Pet table - ensure critical pet information
ALTER TABLE `tbl_pet` 
MODIFY `pet_name` varchar(100) NOT NULL,
MODIFY `pet_owner_id` int(11) NOT NULL,
MODIFY `pet_type_id` int(11) NOT NULL,
MODIFY `adoption_status` enum('Available','Pending','Adopted') NOT NULL DEFAULT 'Available',
MODIFY `date_registered` date NOT NULL DEFAULT (CURDATE());

-- Adopter table - ensure critical adopter information
ALTER TABLE `tbl_adopter` 
MODIFY `adopter_name` varchar(100) NOT NULL,
MODIFY `adopter_email` varchar(100) NOT NULL;

-- Pet Owner table - ensure critical owner information
ALTER TABLE `tbl_pet_owner` 
MODIFY `pet_owner_name` varchar(100) NOT NULL,
MODIFY `pet_owner_email` varchar(100) NOT NULL;
```

#### Add Check Constraints for Data Validation
```sql
-- Age validation for pets
ALTER TABLE `tbl_pet` 
ADD CONSTRAINT `chk_pet_age` CHECK (`age` >= 0 AND `age` <= 30);

-- Date validation for adoption requests
ALTER TABLE `tbl_adoption_request` 
ADD CONSTRAINT `chk_request_date` CHECK (`request_date` <= CURDATE()),
ADD CONSTRAINT `chk_approval_date` CHECK (`approval_date` >= `request_date` OR `approval_date` IS NULL);

-- Date validation for adoptions
ALTER TABLE `tbl_adoption` 
ADD CONSTRAINT `chk_adoption_date` CHECK (`adoption_date` <= CURDATE());

-- Pet registration date validation
ALTER TABLE `tbl_pet` 
ADD CONSTRAINT `chk_registration_date` CHECK (`date_registered` <= CURDATE());
```

### 3. Referential Integrity Improvements

#### Add Cascading Rules for Better Data Management
```sql
-- Update existing foreign key constraints with proper cascade rules

-- Pet Media - if pet is deleted, remove media
ALTER TABLE `tbl_pet_media` 
DROP FOREIGN KEY `fk_pet_media`,
ADD CONSTRAINT `fk_pet_media` 
FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Adoption Requests - if pet or adopter is deleted, handle appropriately
ALTER TABLE `tbl_adoption_request` 
DROP FOREIGN KEY `fk_request_pet`,
DROP FOREIGN KEY `fk_request_adopter`,
ADD CONSTRAINT `fk_request_pet` 
FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`) 
ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `fk_request_adopter` 
FOREIGN KEY (`adopter_id`) REFERENCES `tbl_adopter` (`adopter_id`) 
ON DELETE CASCADE ON UPDATE CASCADE;

-- Adoptions - maintain referential integrity
ALTER TABLE `tbl_adoption` 
DROP FOREIGN KEY `fk_adoption_pet`,
DROP FOREIGN KEY `fk_adoption_adopter`,
ADD CONSTRAINT `fk_adoption_pet` 
FOREIGN KEY (`pet_id`) REFERENCES `tbl_pet` (`pet_id`) 
ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT `fk_adoption_adopter` 
FOREIGN KEY (`adopter_id`) REFERENCES `tbl_adopter` (`adopter_id`) 
ON DELETE RESTRICT ON UPDATE CASCADE;
```

### 4. Missing Constraints for Business Logic

#### Add User ID References to Track Activities
```sql
-- Add user_id foreign key to adoption_request table
ALTER TABLE `tbl_adoption_request` 
ADD CONSTRAINT `fk_request_user` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;

-- Add user_id foreign key to adoption table
ALTER TABLE `tbl_adoption` 
ADD CONSTRAINT `fk_adoption_user` 
FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) 
ON DELETE SET NULL ON UPDATE CASCADE;
```

#### Add Unique Constraints for Business Rules
```sql
-- Prevent duplicate adoption requests for same pet by same adopter
ALTER TABLE `tbl_adoption_request` 
ADD CONSTRAINT `uk_adopter_pet_request` 
UNIQUE (`adopter_id`, `pet_id`, `status`);

-- Ensure pet can only have one active adoption
ALTER TABLE `tbl_adoption` 
ADD CONSTRAINT `uk_pet_adoption` 
UNIQUE (`pet_id`);
```

### 5. Email and Contact Validation Constraints

#### Add Format Validation
```sql
-- Email format validation
ALTER TABLE `users` 
ADD CONSTRAINT `chk_email_format` 
CHECK (`email` REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

ALTER TABLE `tbl_adopter` 
ADD CONSTRAINT `chk_adopter_email_format` 
CHECK (`adopter_email` REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

ALTER TABLE `tbl_pet_owner` 
ADD CONSTRAINT `chk_owner_email_format` 
CHECK (`pet_owner_email` REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

-- Phone number format validation (Philippine format)
ALTER TABLE `tbl_adopter` 
ADD CONSTRAINT `chk_adopter_contact_format` 
CHECK (`adopter_contact` REGEXP '^(09|\\+639)[0-9]{9}$' OR `adopter_contact` IS NULL);

ALTER TABLE `tbl_pet_owner` 
ADD CONSTRAINT `chk_owner_contact_format` 
CHECK (`pet_owner_contact` REGEXP '^(09|\\+639)[0-9]{9}$' OR `pet_owner_contact` IS NULL);
```

### 6. Index Optimizations

#### Add Performance Indexes
```sql
-- Improve query performance for common searches
CREATE INDEX `idx_pet_adoption_status` ON `tbl_pet` (`adoption_status`);
CREATE INDEX `idx_pet_type` ON `tbl_pet` (`pet_type_id`);
CREATE INDEX `idx_request_status` ON `tbl_adoption_request` (`status`);
CREATE INDEX `idx_request_date` ON `tbl_adoption_request` (`request_date`);
CREATE INDEX `idx_adoption_date` ON `tbl_adoption` (`adoption_date`);
CREATE INDEX `idx_user_role` ON `users` (`role`);
CREATE INDEX `idx_pet_owner` ON `tbl_pet` (`pet_owner_id`);
```

## Complete Migration Script

### Phase 1: Schema Updates (Safe Operations)
```sql
-- Add new columns and extend enums
ALTER TABLE `users` MODIFY `role` enum('admin','adopter','pet_owner') DEFAULT 'adopter';
ALTER TABLE `tbl_adopter` ADD COLUMN `username` varchar(50) UNIQUE AFTER `adopter_id`;
ALTER TABLE `tbl_pet_owner` ADD COLUMN `username` varchar(50) UNIQUE AFTER `pet_owner_id`;

-- Add NOT NULL constraints where safe
ALTER TABLE `tbl_pet` MODIFY `adoption_status` enum('Available','Pending','Adopted') NOT NULL DEFAULT 'Available';
ALTER TABLE `tbl_pet` MODIFY `date_registered` date NOT NULL DEFAULT (CURDATE());
```

### Phase 2: Data Migration
```sql
-- Migrate existing pet owner to users table
INSERT IGNORE INTO `users` (`username`, `email`, `password`, `role`) 
SELECT `pet_owner_username`, `pet_owner_email`, `pet_owner_password`, 'pet_owner'
FROM `tbl_pet_owner` 
WHERE `pet_owner_username` IS NOT NULL;

-- Update pet owner table with username references
UPDATE `tbl_pet_owner` 
SET `username` = `pet_owner_username` 
WHERE `pet_owner_username` IS NOT NULL;
```

### Phase 3: Add Foreign Key Constraints
```sql
-- Add foreign key constraints
ALTER TABLE `tbl_adopter` 
ADD CONSTRAINT `fk_adopter_user` 
FOREIGN KEY (`username`) REFERENCES `users`(`username`) 
ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE `tbl_pet_owner` 
ADD CONSTRAINT `fk_pet_owner_user` 
FOREIGN KEY (`username`) REFERENCES `users`(`username`) 
ON UPDATE CASCADE ON DELETE SET NULL;
```

### Phase 4: Add Business Logic Constraints
```sql
-- Add check constraints and unique constraints
ALTER TABLE `tbl_pet` ADD CONSTRAINT `chk_pet_age` CHECK (`age` >= 0 AND `age` <= 30);
ALTER TABLE `tbl_adoption_request` ADD CONSTRAINT `chk_request_date` CHECK (`request_date` <= CURDATE());
ALTER TABLE `users` ADD CONSTRAINT `chk_email_format` CHECK (`email` REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
```

## Benefits of These Constraints

### 1. Data Integrity
- Prevents invalid data entry
- Ensures referential consistency
- Validates business rules at database level

### 2. Performance
- Optimized indexes for common queries
- Faster joins and lookups
- Better query execution plans

### 3. Security
- Prevents orphaned records
- Ensures proper user authentication
- Validates email formats

### 4. Maintainability
- Clear relationships between tables
- Easier debugging of data issues
- Self-documenting schema

### 5. Business Logic Enforcement
- Prevents duplicate adoption requests
- Ensures proper date relationships
- Validates contact information

## Implementation Priority

### High Priority (Immediate)
1. Add 'pet_owner' role to users table
2. Link profile tables to users table
3. Add NOT NULL constraints for critical fields

### Medium Priority (Within Sprint)
1. Add check constraints for data validation
2. Update foreign key cascade rules
3. Add business logic constraints

### Low Priority (Future Enhancement)
1. Email/phone format validation
2. Performance indexes
3. Advanced business rules

This comprehensive constraint system will ensure your Furever Pet Adoption System maintains high data quality and performance while enforcing proper business rules at the database level.