-- V9: Migration'ları gerçek Supabase şemasına uyarlar (Kart #1)
--
-- V1-V8, refactor öncesi eski isimlerle (owners/vet_staff, pets.age) yazılmıştı;
-- gerçek Supabase şeması ise profiles/clinic_staff üzerine kurulu ve Kübra/Sude
-- tarafından elle genişletildi (clinics, klinik üyelik alanları, trigger'lar).
-- Bu migration, canlı DB'de zaten var olan şeyleri etkilemeden (tamamen idempotent),
-- sıfır bir ortamda (yeni Supabase projesi, CI, felaket kurtarma) doğru şemayı kurar.
--
-- Kaynak: Sude'nin 13 Ağustos 2026'da information_schema/pg_catalog sorgularıyla
-- çıkardığı gerçek şema dökümü (kolonlar, constraint'ler, index'ler, trigger'lar).

-- ============================================================
-- 1. profiles
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
    id         UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name  VARCHAR(255) NOT NULL,
    email      VARCHAR(255) NOT NULL,
    phone      VARCHAR(20),
    role       TEXT NOT NULL,
    is_active  BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    surname    VARCHAR(100),
    address    TEXT
);

DO $$ BEGIN
    ALTER TABLE profiles ADD CONSTRAINT profiles_email_key UNIQUE (email);
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
        CHECK (role = ANY (ARRAY['owner'::text, 'vet_staff'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

-- ============================================================
-- 2. clinics (yeni — hiçbir migration'da yoktu)
-- ============================================================
CREATE TABLE IF NOT EXISTS clinics (
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                  TEXT NOT NULL,
    phone                 TEXT,
    email                 TEXT,
    address               TEXT,
    subscription_tier     TEXT NOT NULL DEFAULT 'free',
    subscription_status   TEXT NOT NULL DEFAULT 'trialing',
    trial_ends_at         TIMESTAMPTZ,
    is_active             BOOLEAN DEFAULT true,
    created_at            TIMESTAMPTZ DEFAULT now(),
    updated_at            TIMESTAMPTZ DEFAULT now()
);

DO $$ BEGIN
    ALTER TABLE clinics ADD CONSTRAINT clinics_subscription_tier_check
        CHECK (subscription_tier = ANY (ARRAY['free'::text, 'starter'::text, 'standard'::text, 'enterprise'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE clinics ADD CONSTRAINT clinics_subscription_status_check
        CHECK (subscription_status = ANY (ARRAY['active'::text, 'past_due'::text, 'canceled'::text, 'trialing'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

-- ============================================================
-- 3. clinic_staff (klinik üyelik alanları eklendi — Kart #8/#18)
-- ============================================================
CREATE TABLE IF NOT EXISTS clinic_staff (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID REFERENCES profiles(id) ON DELETE CASCADE,
    clinic_id       UUID REFERENCES clinics(id) ON DELETE CASCADE,
    staff_role      VARCHAR(255) NOT NULL,
    license_number  VARCHAR(255),
    is_active       BOOLEAN DEFAULT true,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE clinic_staff ADD COLUMN IF NOT EXISTS is_clinic_admin BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE clinic_staff ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';
ALTER TABLE clinic_staff ADD COLUMN IF NOT EXISTS joined_at TIMESTAMPTZ NOT NULL DEFAULT now();

DO $$ BEGIN
    ALTER TABLE clinic_staff ADD CONSTRAINT clinic_staff_staff_role_check
        CHECK ((staff_role)::text = ANY (ARRAY['doctor'::text, 'staff'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE clinic_staff ADD CONSTRAINT clinic_staff_status_check
        CHECK (status = ANY (ARRAY['invited'::text, 'active'::text, 'disabled'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE clinic_staff ADD CONSTRAINT unique_user_clinic UNIQUE (user_id, clinic_id);
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_clinic_staff_clinic_id ON clinic_staff(clinic_id);
CREATE INDEX IF NOT EXISTS idx_clinic_staff_user_id ON clinic_staff(user_id);

-- ============================================================
-- 4. pets
-- ============================================================
DO $$ BEGIN
    ALTER TABLE pets ADD CONSTRAINT pets_gender_check
        CHECK ((gender)::text = ANY (ARRAY['male'::text, 'female'::text, 'unknown'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE pets ADD CONSTRAINT pets_unique_code_check
        CHECK ((unique_code)::text ~ '^[A-HJ-KM-NP-Z2-9]{6}$'::text);
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE pets ADD CONSTRAINT check_estimated_birth_year
        CHECK ((estimated_birth_year IS NULL) OR
               ((estimated_birth_year >= 1990) AND (estimated_birth_year <= ((EXTRACT(year FROM now()))::smallint + 1))));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

CREATE UNIQUE INDEX IF NOT EXISTS idx_pets_unique_code_ci ON pets(upper((unique_code)::text));
CREATE INDEX IF NOT EXISTS idx_pets_owner_id ON pets(owner_id);

-- ============================================================
-- 5. visits (clinic_id + status check)
-- ============================================================
ALTER TABLE visits ADD COLUMN IF NOT EXISTS clinic_id UUID REFERENCES clinics(id) ON DELETE RESTRICT;

DO $$ BEGIN
    ALTER TABLE visits ADD CONSTRAINT visits_status_check
        CHECK (status = ANY (ARRAY['ongoing'::text, 'completed'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_visits_clinic_id ON visits(clinic_id);
CREATE INDEX IF NOT EXISTS idx_visits_pet_id ON visits(pet_id);
CREATE INDEX IF NOT EXISTS idx_visits_vet_staff_id ON visits(vet_staff_id);

-- ============================================================
-- 6. treatment_entries
-- ============================================================
DO $$ BEGIN
    ALTER TABLE treatment_entries ADD CONSTRAINT treatment_entries_entry_type_check
        CHECK (entry_type = ANY (ARRAY['medication'::text, 'xray'::text, 'lab_result'::text, 'note'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

-- ============================================================
-- 7. recommendations
-- ============================================================
DO $$ BEGIN
    ALTER TABLE recommendations ADD CONSTRAINT recommendations_type_check
        CHECK (type = ANY (ARRAY['food'::text, 'litter'::text, 'other'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_recommendations_visit_id ON recommendations(visit_id);

-- ============================================================
-- 8. notifications (recommendation_id eklendi)
-- ============================================================
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS recommendation_id UUID REFERENCES recommendations(id) ON DELETE CASCADE;

DO $$ BEGIN
    ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
        CHECK ((type)::text = ANY ((ARRAY['VACCINE'::character varying, 'VISIT'::character varying,
               'TREATMENT'::character varying, 'RECOMMENDATION'::character varying,
               'SYSTEM'::character varying])::text[]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

-- ============================================================
-- 9. device_tokens
-- ============================================================
DO $$ BEGIN
    ALTER TABLE device_tokens ADD CONSTRAINT device_tokens_platform_check
        CHECK ((platform)::text = ANY (ARRAY['ios'::text, 'android'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE device_tokens ADD CONSTRAINT unique_user_fcm_token UNIQUE (user_id, fcm_token);
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

-- ============================================================
-- 10. audit_logs — gerçek şemadaki genel-amaçlı kolonlar eklendi
--     (V6'daki entity_name/entity_id/details Java entity'sinde kalıyor,
--     bunlar Supabase'in kendi trigger tabanlı audit sisteminin kolonları)
-- ============================================================
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS table_name TEXT;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS record_id UUID;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS old_data JSONB;
ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS new_data JSONB;

DO $$ BEGIN
    ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_action_check
        CHECK ((action)::text = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text]));
EXCEPTION WHEN duplicate_object OR duplicate_table THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- ============================================================
-- 11. Trigger fonksiyonları (Supabase'te elle oluşturulmuştu, buraya
--     taşındı ki sıfır bir ortamda da aynı iş mantığı kurulsun)
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.process_audit_log()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    curr_user_id UUID;
BEGIN
    BEGIN
        curr_user_id := auth.uid();
    EXCEPTION WHEN OTHERS THEN
        curr_user_id := NULL;
    END;

    IF (TG_OP = 'DELETE') THEN
        INSERT INTO public.audit_logs (table_name, record_id, action, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', to_jsonb(OLD), NULL, curr_user_id);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO public.audit_logs (table_name, record_id, action, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), curr_user_id);
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO public.audit_logs (table_name, record_id, action, old_data, new_data, changed_by)
        VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', NULL, to_jsonb(NEW), curr_user_id);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$function$;

CREATE OR REPLACE FUNCTION public.check_visit_vet_staff_role()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = NEW.vet_staff_id AND role = 'vet_staff'
    ) THEN
        RAISE EXCEPTION 'Atanan vet_staff_id bir hekime ait olmalıdır.';
    END IF;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.check_treatment_entry_modification_limit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    curr_user_id UUID;
BEGIN
    BEGIN
        curr_user_id := auth.uid();
    EXCEPTION WHEN OTHERS THEN
        curr_user_id := NULL;
    END;

    IF curr_user_id IS NULL THEN
        RETURN NEW;
    END IF;

    IF (NOW() - OLD.created_at) > INTERVAL '15 minutes' THEN
        RAISE EXCEPTION 'Tedavi kaydı oluşturulduktan 15 dakika sonra kilitlenir ve değiştirilemez.'
            USING ERRCODE = 'check_violation',
                  DETAIL = 'EC-08 Kural İhlali: ' || OLD.created_at || ' tarihinde oluşturulan kayıt kilitlidir.';
    END IF;

    IF TG_OP = 'UPDATE' AND (NOW() - NEW.created_at) >= INTERVAL '15 minutes' THEN
        NEW.is_editable := false;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.set_unique_pet_code()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.unique_code IS NULL OR NEW.unique_code = '' THEN
        NEW.unique_code := public.generate_unique_pet_code();
    END IF;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.notify_owner_on_recommendation()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_owner_id UUID;
    v_pet_name TEXT;
    v_type_tr  TEXT;
BEGIN
    SELECT pt.owner_id, pt.name
    INTO v_owner_id, v_pet_name
    FROM public.visits v
    JOIN public.pets pt ON pt.id = v.pet_id
    WHERE v.id = NEW.visit_id;

    v_type_tr := CASE NEW.type
        WHEN 'food'   THEN 'Mama Önerisi'
        WHEN 'litter' THEN 'Kum Önerisi'
        ELSE 'Öneri'
    END;

    IF v_owner_id IS NOT NULL THEN
        INSERT INTO public.notifications
            (owner_id, recommendation_id, type, title, body)
        VALUES (
            v_owner_id,
            NEW.id,
            'RECOMMENDATION',
            v_pet_name || ' için ' || v_type_tr,
            NEW.description
        );
    END IF;

    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.notify_owner_on_treatment()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    v_owner_id     UUID;
    v_pet_name     TEXT;
    v_type_tr      TEXT;
BEGIN
    SELECT pt.owner_id, pt.name
    INTO v_owner_id, v_pet_name
    FROM public.visits v
    JOIN public.pets pt ON pt.id = v.pet_id
    WHERE v.id = NEW.visit_id;

    v_type_tr := CASE NEW.entry_type
        WHEN 'medication'  THEN 'İlaç'
        WHEN 'xray'        THEN 'Röntgen'
        WHEN 'lab_result'  THEN 'Tahlil Sonucu'
        WHEN 'note'        THEN 'Not'
        ELSE NEW.entry_type
    END;

    IF v_owner_id IS NOT NULL THEN
        INSERT INTO public.notifications
            (owner_id, treatment_entry_id, type, title, body)
        VALUES (
            v_owner_id,
            NEW.id,
            'TREATMENT',
            v_pet_name || ' için yeni kayıt',
            v_type_tr || ': ' || NEW.title
        );
    END IF;

    RETURN NEW;
END;
$function$;

-- ============================================================
-- 12. Trigger kayıtları (Postgres'te CREATE TRIGGER IF NOT EXISTS
--     desteklenmiyor, DROP + CREATE ile idempotent yapılıyor)
-- ============================================================

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS audit_profiles_changes ON profiles;
CREATE TRIGGER audit_profiles_changes AFTER INSERT OR UPDATE OR DELETE ON profiles
    FOR EACH ROW EXECUTE FUNCTION process_audit_log();

DROP TRIGGER IF EXISTS update_clinics_updated_at ON clinics;
CREATE TRIGGER update_clinics_updated_at BEFORE UPDATE ON clinics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_clinic_staff_updated_at ON clinic_staff;
CREATE TRIGGER update_clinic_staff_updated_at BEFORE UPDATE ON clinic_staff
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS audit_clinic_staff_changes ON clinic_staff;
CREATE TRIGGER audit_clinic_staff_changes AFTER INSERT OR UPDATE OR DELETE ON clinic_staff
    FOR EACH ROW EXECUTE FUNCTION process_audit_log();

DROP TRIGGER IF EXISTS trigger_set_unique_pet_code ON pets;
CREATE TRIGGER trigger_set_unique_pet_code BEFORE INSERT ON pets
    FOR EACH ROW EXECUTE FUNCTION set_unique_pet_code();

DROP TRIGGER IF EXISTS update_pets_updated_at ON pets;
CREATE TRIGGER update_pets_updated_at BEFORE UPDATE ON pets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS audit_pets_changes ON pets;
CREATE TRIGGER audit_pets_changes AFTER INSERT OR UPDATE OR DELETE ON pets
    FOR EACH ROW EXECUTE FUNCTION process_audit_log();

DROP TRIGGER IF EXISTS validate_visit_vet_staff ON visits;
CREATE TRIGGER validate_visit_vet_staff BEFORE INSERT OR UPDATE ON visits
    FOR EACH ROW EXECUTE FUNCTION check_visit_vet_staff_role();

DROP TRIGGER IF EXISTS update_visits_updated_at ON visits;
CREATE TRIGGER update_visits_updated_at BEFORE UPDATE ON visits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS audit_visits_changes ON visits;
CREATE TRIGGER audit_visits_changes AFTER INSERT OR UPDATE OR DELETE ON visits
    FOR EACH ROW EXECUTE FUNCTION process_audit_log();

DROP TRIGGER IF EXISTS enforce_treatment_modification_guard ON treatment_entries;
CREATE TRIGGER enforce_treatment_modification_guard BEFORE UPDATE OR DELETE ON treatment_entries
    FOR EACH ROW EXECUTE FUNCTION check_treatment_entry_modification_limit();

DROP TRIGGER IF EXISTS update_treatment_entries_updated_at ON treatment_entries;
CREATE TRIGGER update_treatment_entries_updated_at BEFORE UPDATE ON treatment_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS audit_treatment_entries_changes ON treatment_entries;
CREATE TRIGGER audit_treatment_entries_changes AFTER INSERT OR UPDATE OR DELETE ON treatment_entries
    FOR EACH ROW EXECUTE FUNCTION process_audit_log();

DROP TRIGGER IF EXISTS trigger_notify_on_treatment ON treatment_entries;
CREATE TRIGGER trigger_notify_on_treatment AFTER INSERT ON treatment_entries
    FOR EACH ROW EXECUTE FUNCTION notify_owner_on_treatment();

DROP TRIGGER IF EXISTS update_recommendations_updated_at ON recommendations;
CREATE TRIGGER update_recommendations_updated_at BEFORE UPDATE ON recommendations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS audit_recommendations_changes ON recommendations;
CREATE TRIGGER audit_recommendations_changes AFTER INSERT OR UPDATE OR DELETE ON recommendations
    FOR EACH ROW EXECUTE FUNCTION process_audit_log();

DROP TRIGGER IF EXISTS trigger_notify_on_recommendation ON recommendations;
CREATE TRIGGER trigger_notify_on_recommendation AFTER INSERT ON recommendations
    FOR EACH ROW EXECUTE FUNCTION notify_owner_on_recommendation();
