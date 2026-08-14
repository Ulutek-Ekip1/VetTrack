-- V13__fix_vet_staff_role_check.sql
-- Change visit authorization trigger to rely on clinic_memberships instead of profiles.role

CREATE OR REPLACE FUNCTION public.check_visit_vet_staff_role()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.clinic_memberships
        WHERE user_id = NEW.vet_staff_id AND clinic_id = NEW.clinic_id AND status = 'active'
    ) THEN
        RAISE EXCEPTION 'Atanan vet_staff_id ilgili klinikte aktif bir personel olmalidir.';
    END IF;
    RETURN NEW;
END;
$$;
