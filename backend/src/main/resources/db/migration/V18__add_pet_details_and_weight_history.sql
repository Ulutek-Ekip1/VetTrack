-- V17: Add pet detail fields and pet weight history table

-- 1. Add new columns to pets table
ALTER TABLE pets
    ADD COLUMN IF NOT EXISTS weight DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS microchip_no VARCHAR(50),
    ADD COLUMN IF NOT EXISTS is_spayed_or_neutered BOOLEAN,
    ADD COLUMN IF NOT EXISTS blood_type VARCHAR(20),
    ADD COLUMN IF NOT EXISTS color VARCHAR(50),
    ADD COLUMN IF NOT EXISTS allergies TEXT,
    ADD COLUMN IF NOT EXISTS chronic_illnesses TEXT;

-- 2. Create pet_weight_history table
CREATE TABLE IF NOT EXISTS pet_weight_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pet_id UUID NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
    weight DOUBLE PRECISION NOT NULL,
    recorded_date DATE NOT NULL,
    recorded_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pet_weight_history_pet_date
    ON pet_weight_history(pet_id, recorded_date ASC);
