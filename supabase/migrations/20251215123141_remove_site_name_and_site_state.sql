-- Remove site_name and site_state columns from profiles and pending_users tables

ALTER TABLE IF EXISTS profiles
DROP COLUMN IF EXISTS site_name,
DROP COLUMN IF EXISTS site_state;

ALTER TABLE IF EXISTS pending_users
DROP COLUMN IF EXISTS site_name,
DROP COLUMN IF EXISTS site_state;
