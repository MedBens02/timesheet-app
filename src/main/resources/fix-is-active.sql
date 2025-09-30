-- Quick fix: Update is_active field for all users
-- Run this on the timesheet_db database to fix the NullPointerException during login

USE timesheet_db;

-- Set is_active to TRUE for all users where it's currently NULL
UPDATE users
SET is_active = TRUE
WHERE is_active IS NULL;

-- Verify the update
SELECT id, username, email, role, is_active
FROM users
ORDER BY id;

COMMIT;