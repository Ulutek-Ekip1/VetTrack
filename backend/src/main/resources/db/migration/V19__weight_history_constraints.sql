-- V18: Weight validasyonu (0-2000 kg), timestamp hassasiyeti ve optimistic locking

-- 0. Hatalı eski (sıfır, negatif veya >2000 kg) kayıtların denetim/yedekleme amacıyla saklanması ve temizlenmesi
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'pet_weight_history'
    ) THEN
        CREATE TABLE IF NOT EXISTS legacy_invalid_weight_records (
            id UUID PRIMARY KEY,
            pet_id UUID NOT NULL,
            weight DOUBLE PRECISION NOT NULL,
            recorded_date DATE,
            recorded_at TIMESTAMP WITH TIME ZONE,
            backed_up_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            notes TEXT DEFAULT 'Invalid weight record before V18 migration'
        );

        -- Kaynak tabloda recorded_date kolonu varsa kaynak tarihi de koru
        IF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'pet_weight_history' AND column_name = 'recorded_date'
        ) THEN
            EXECUTE '
                INSERT INTO legacy_invalid_weight_records (id, pet_id, weight, recorded_date, recorded_at)
                SELECT id, pet_id, weight, recorded_date, recorded_date::timestamp AT TIME ZONE ''UTC''
                FROM pet_weight_history
                WHERE weight IS NOT NULL AND (weight <= 0 OR weight > 2000)
                ON CONFLICT (id) DO NOTHING
            ';
        ELSIF EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_schema = 'public' AND table_name = 'pet_weight_history' AND column_name = 'recorded_at'
        ) THEN
            EXECUTE '
                INSERT INTO legacy_invalid_weight_records (id, pet_id, weight, recorded_date, recorded_at)
                SELECT id, pet_id, weight, recorded_at::date, recorded_at
                FROM pet_weight_history
                WHERE weight IS NOT NULL AND (weight <= 0 OR weight > 2000)
                ON CONFLICT (id) DO NOTHING
            ';
        END IF;

        DELETE FROM pet_weight_history WHERE weight IS NOT NULL AND (weight <= 0 OR weight > 2000);
    END IF;
END $$;

UPDATE pets SET weight = NULL WHERE weight IS NOT NULL AND (weight <= 0 OR weight > 2000);

-- 1. Weight değeri pozitif ve en fazla 2000 kg olmalı (uygulama + DB çift katmanlı koruma)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'chk_weight_positive' 
          AND conrelid = 'pet_weight_history'::regclass
    ) THEN
        ALTER TABLE pet_weight_history
            ADD CONSTRAINT chk_weight_positive CHECK (weight > 0 AND weight <= 2000);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'chk_pets_weight_positive' 
          AND conrelid = 'pets'::regclass
    ) THEN
        ALTER TABLE pets
            ADD CONSTRAINT chk_pets_weight_positive CHECK (weight IS NULL OR (weight > 0 AND weight <= 2000));
    END IF;
END $$;

-- 2. recorded_date → recorded_at (TIMESTAMPTZ) dönüşümü
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public'
          AND table_name = 'pet_weight_history' 
          AND column_name = 'recorded_date'
    ) THEN
        ALTER TABLE pet_weight_history ADD COLUMN IF NOT EXISTS recorded_at TIMESTAMP WITH TIME ZONE;
        UPDATE pet_weight_history SET recorded_at = recorded_date::timestamp AT TIME ZONE 'UTC' WHERE recorded_at IS NULL;
        ALTER TABLE pet_weight_history ALTER COLUMN recorded_at SET NOT NULL;
        ALTER TABLE pet_weight_history DROP COLUMN recorded_date;
    END IF;
END $$;

DROP INDEX IF EXISTS idx_pet_weight_history_pet_date;
CREATE INDEX IF NOT EXISTS idx_pet_weight_history_pet_at
    ON pet_weight_history(pet_id, recorded_at ASC);

-- 3. Optimistic locking: version column
ALTER TABLE pets
    ADD COLUMN IF NOT EXISTS version BIGINT DEFAULT 0;
