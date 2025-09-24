-- Cleanup script for adoption request conflicts
-- This script resolves the current database state where adopter 3 has both pending and approved requests for pet 2

USE furever;

-- Show current problematic state
SELECT 'Current conflicting requests:' as info;
SELECT adoption_request_id, pet_id, adopter_id, status, request_date, approval_date 
FROM tbl_adoption_request 
WHERE adopter_id = 3 AND pet_id = 2 
ORDER BY adoption_request_id;

-- Show pet and adopter details for context
SELECT 'Pet details:' as info;
SELECT pet_id, pet_name, adoption_status FROM tbl_pet WHERE pet_id = 2;

SELECT 'Adopter details:' as info;
SELECT adopter_id, adopter_name, adopter_email FROM tbl_adopter WHERE adopter_id = 3;

-- Solution: Reject the duplicate pending request (ID 4) since there's already an approved one (ID 3)
UPDATE tbl_adoption_request 
SET status = 'Rejected', 
    remarks = 'Rejected - Adopter already has an approved request for this pet' 
WHERE adoption_request_id = 4 
  AND adopter_id = 3 
  AND pet_id = 2 
  AND status = 'Pending';

-- Verify the fix
SELECT 'After cleanup - all requests for adopter 3 and pet 2:' as info;
SELECT adoption_request_id, pet_id, adopter_id, status, request_date, approval_date, remarks
FROM tbl_adoption_request 
WHERE adopter_id = 3 AND pet_id = 2 
ORDER BY adoption_request_id;

SELECT 'Cleanup completed successfully!' as message;