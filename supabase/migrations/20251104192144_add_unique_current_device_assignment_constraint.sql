
-- Create a unique partial index to ensure only one current assignment per device
CREATE UNIQUE INDEX IF NOT EXISTS unique_current_device_assignment 
ON device_assignments (device_id) 
WHERE is_current = true;
;
