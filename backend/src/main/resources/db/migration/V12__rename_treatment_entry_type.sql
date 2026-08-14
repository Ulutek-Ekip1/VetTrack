-- V12__rename_treatment_entry_type.sql

-- 1. Rename column entry_type to type
ALTER TABLE treatment_entries RENAME COLUMN entry_type TO type;

-- 2. Drop old check constraint (created in V9)
ALTER TABLE treatment_entries DROP CONSTRAINT IF EXISTS treatment_entries_entry_type_check;

-- 3. Add new check constraint with expanded types
ALTER TABLE treatment_entries ADD CONSTRAINT treatment_entries_type_check 
    CHECK (type IN ('medication', 'vaccine', 'surgery', 'xray', 'lab_result', 'note'));

-- 4. Re-create the notification trigger function to use NEW.type instead of NEW.entry_type
CREATE OR REPLACE FUNCTION trg_create_treatment_notification()
RETURNS TRIGGER AS $$
DECLARE
    v_owner_id UUID;
    v_type_tr TEXT;
BEGIN
    -- Eğer tedavi iptal/tamamlandı durumuna geçerse veya geçmişe dönük girildiyse tetiklenmez
    IF NEW.status = 'CANCELLED' OR NEW.status = 'COMPLETED' THEN
        RETURN NEW;
    END IF;

    -- Pet owner_id bul
    SELECT p.owner_id INTO v_owner_id
    FROM visits v
    JOIN pets p ON v.pet_id = p.id
    WHERE v.id = NEW.visit_id;

    IF v_owner_id IS NOT NULL THEN
        -- Tür ismini Türkçe mantıklı bir şeye çevirelim
        v_type_tr := CASE NEW.type
            WHEN 'medication' THEN 'İlaç'
            WHEN 'vaccine' THEN 'Aşı'
            WHEN 'surgery' THEN 'Ameliyat'
            WHEN 'xray' THEN 'Röntgen'
            WHEN 'lab_result' THEN 'Laboratuvar Sonucu'
            WHEN 'note' THEN 'Not'
            ELSE NEW.type
        END;

        INSERT INTO notifications (
            id, owner_id, treatment_entry_id, title, body, type, is_read, sent_at
        ) VALUES (
            gen_random_uuid(),
            v_owner_id,
            NEW.id,
            'Yeni Tedavi Planı: ' || v_type_tr,
            NEW.title || ' başlıklı yeni bir tedavi/işlem planlandı.',
            'TREATMENT',
            false,
            now()
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
