-- Test queries to debug adopter login issue

-- Check all users with adopter role
SELECT id, username, email, role FROM users WHERE role = 'adopter';

-- Check if authentication query works for adopter users
SELECT * FROM users WHERE username = 'Adopter20' AND password = 'adoptme';

-- Check for any duplicate usernames that might cause constraint issues
SELECT username, COUNT(*) as count FROM users GROUP BY username HAVING COUNT(*) > 1;

-- Check tbl_adopter for related records
SELECT adopter_id, username, adopter_name, adopter_username FROM tbl_adopter;