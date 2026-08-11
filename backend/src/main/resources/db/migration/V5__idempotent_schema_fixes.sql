-- V5: Existing DB schema safety checks and idempotency fixes
-- Safely applies column & index additions without altering applied Flyway checksums V1-V4

ALTER TABLE IF EXISTS owners ADD COLUMN IF NOT EXISTS surname VARCHAR(100);
ALTER TABLE IF EXISTS owners ADD COLUMN IF NOT EXISTS address TEXT;

ALTER TABLE IF EXISTS treatment_entries ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'PLANNED';
ALTER TABLE IF EXISTS treatment_entries ADD COLUMN IF NOT EXISTS start_date TIMESTAMPTZ;
ALTER TABLE IF EXISTS treatment_entries ADD COLUMN IF NOT EXISTS end_date TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_treatment_entries_status ON treatment_entries(status);
CREATE INDEX IF NOT EXISTS idx_treatment_entries_start_date ON treatment_entries(start_date DESC);
