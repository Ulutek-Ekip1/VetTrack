-- V16: EC-02 - the active-visit partial unique index guarantees a pet can't
-- have two concurrent "ongoing" visits at the DB level (VisitService's
-- app-level hasActiveVisit check can't catch a genuine race between two
-- concurrent requests). V1 created it as idx_visits_one_ongoing; rename it
-- to idx_visits_active_pet, and create it if for any reason it's missing.

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_visits_one_ongoing')
       AND NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_visits_active_pet') THEN
        ALTER INDEX idx_visits_one_ongoing RENAME TO idx_visits_active_pet;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_visits_active_pet
    ON visits(pet_id) WHERE status = 'ongoing';
