# Pet Owner and Adopter Management - Schema Improvements

## Current Schema Issues

### Problems Identified:
1. **Disconnected Authentication**: Pet owners have separate authentication in `tbl_pet_owner` 
2. **Limited User Roles**: `users` table only supports 'admin' and 'adopter' roles
3. **Duplicate User Management**: Pet owners exist outside main authentication system
4. **Inconsistent Profile Management**: Different approaches for adopters vs pet owners

## Recommended Solutions

### Option 1: Unified User System (Recommended)

#### 1. Update Users Table
```sql
-- Add pet_owner role to existing users table
ALTER TABLE `users` 
MODIFY `role` enum('admin','adopter','pet_owner') DEFAULT 'adopter';
```

#### 2. Add Username Reference to Pet Owner Table
```sql
-- Add username reference to link with users table
ALTER TABLE `tbl_pet_owner` 
ADD COLUMN `username` varchar(50) UNIQUE,
ADD CONSTRAINT `fk_pet_owner_user` 
FOREIGN KEY (`username`) REFERENCES `users`(`username`);
```

#### 3. Remove Duplicate Authentication Fields
```sql
-- Remove duplicate authentication fields from tbl_pet_owner
ALTER TABLE `tbl_pet_owner` 
DROP COLUMN `pet_owner_username`,
DROP COLUMN `pet_owner_password`;
```

### Option 2: Keep Current System with Improvements

#### 1. Add Pet Owner Role to Users
```sql
ALTER TABLE `users` 
MODIFY `role` enum('admin','adopter','pet_owner') DEFAULT 'adopter';
```

#### 2. Create Pet Owner Registration Process
- Pet owners register through main system first
- Create corresponding profile in `tbl_pet_owner`
- Link via username field

## Implementation Plan

### Phase 1: Database Schema Updates
1. Add 'pet_owner' role to users table
2. Update existing pet owner data to use main authentication
3. Migrate existing pet owner credentials to users table

### Phase 2: Application Updates
1. Add pet owner login option to MainMenu
2. Create PetOwnerDashboard for pet management
3. Update authentication logic to handle pet_owner role
4. Create pet owner profile management

### Phase 3: Business Logic
1. Pet registration workflow
2. Pet owner profile creation
3. Pet ownership verification
4. Pet transfer/ownership change capabilities

## Code Changes Required

### 1. MainMenu.java Updates
```java
// Add pet owner login option
case 3:
    if (petOwnerLogin()) {
        showPetOwnerMenu();
    }
    break;

// Add pet owner authentication method
private boolean petOwnerLogin() {
    // Similar to adopter login but check for 'pet_owner' role
}

// Add pet owner menu
private void showPetOwnerMenu() {
    // Pet management, view adoption requests, profile management
}
```

### 2. Create PetOwnerCRUD
```java
public class PetOwnerCRUD {
    // Link pet owner profiles with users table
    public PetOwner getPetOwnerByUsername(String username)
    public boolean createPetOwner(PetOwner petOwner)
    public boolean updatePetOwner(PetOwner petOwner)
}
```

### 3. Update Pet Management
```java
// Ensure pets are linked to authenticated pet owners
// Add pet ownership verification
// Handle pet ownership transfers
```

## Benefits of Unified Approach

1. **Single Authentication System**: All users authenticate through one system
2. **Consistent Security**: Same password policies and security measures
3. **Simplified User Management**: Admins manage all users in one place
4. **Role-Based Access Control**: Clear separation of capabilities
5. **Data Integrity**: Foreign key constraints ensure data consistency

## Migration Strategy

### Step 1: Backup Current Data
```sql
-- Backup existing pet owner data
CREATE TABLE tbl_pet_owner_backup AS SELECT * FROM tbl_pet_owner;
```

### Step 2: Create Users for Existing Pet Owners
```sql
-- Insert existing pet owners into users table
INSERT INTO users (username, email, password, role) 
SELECT pet_owner_username, pet_owner_email, pet_owner_password, 'pet_owner'
FROM tbl_pet_owner 
WHERE pet_owner_username IS NOT NULL;
```

### Step 3: Update Schema
```sql
-- Apply schema changes
-- Update foreign key relationships
-- Remove deprecated fields
```

### Step 4: Test and Validate
- Verify all pet owners can authenticate
- Test pet management functionality
- Validate data integrity

## Implementation Priority

### High Priority:
1. Add 'pet_owner' role to users table
2. Create PetOwnerCRUD class
3. Add pet owner authentication to MainMenu

### Medium Priority:
1. Create PetOwnerDashboard
2. Implement pet registration workflow
3. Add pet ownership verification

### Low Priority:
1. Migrate existing pet owner data
2. Remove deprecated authentication fields
3. Add advanced pet owner features

## Next Steps

1. **Database Schema Update**: Add pet_owner role
2. **Create Pet Owner Authentication**: Update MainMenu.java
3. **Build Pet Owner Dashboard**: New dashboard for pet management
4. **Test Integration**: Ensure all user types work together
5. **Data Migration**: Move existing pet owners to new system