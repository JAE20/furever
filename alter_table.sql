-- Add pet_owner role
ALTER TABLE `users` 
MODIFY `role` enum('admin','adopter','pet_owner') DEFAULT 'adopter';

-- Link pet owners to main authentication
ALTER TABLE `tbl_pet_owner` 
ADD COLUMN `username` varchar(50) UNIQUE,
ADD CONSTRAINT `fk_pet_owner_user` 
FOREIGN KEY (`username`) REFERENCES `users`(`username`);