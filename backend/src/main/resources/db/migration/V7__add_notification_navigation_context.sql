ALTER TABLE notifications ADD COLUMN IF NOT EXISTS pet_id UUID;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS visit_id UUID;

CREATE INDEX IF NOT EXISTS idx_notifications_pet_id ON notifications(pet_id);
