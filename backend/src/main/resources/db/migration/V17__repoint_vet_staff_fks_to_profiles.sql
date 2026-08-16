-- V17: visits.vet_staff_id, treatment_entries.entered_by and audit_logs.changed_by
-- were originally defined (V1/V6) as FKs to the legacy vet_staff table. Since
-- kart #8 removed VetStaffService/JIT provisioning, nothing has ever written
-- real vet_staff rows referencing these columns — the app has always populated
-- them from the JWT subject (auth.uid()), which is profiles.id. Repoint all
-- three to profiles(id) to match what the app actually writes.

ALTER TABLE visits DROP CONSTRAINT IF EXISTS visits_vet_staff_id_fkey;
ALTER TABLE visits ADD CONSTRAINT visits_vet_staff_id_fkey
    FOREIGN KEY (vet_staff_id) REFERENCES profiles(id) ON DELETE RESTRICT;

ALTER TABLE treatment_entries DROP CONSTRAINT IF EXISTS treatment_entries_entered_by_fkey;
ALTER TABLE treatment_entries ADD CONSTRAINT treatment_entries_entered_by_fkey
    FOREIGN KEY (entered_by) REFERENCES profiles(id) ON DELETE RESTRICT;

ALTER TABLE audit_logs DROP CONSTRAINT IF EXISTS audit_logs_changed_by_fkey;
ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_changed_by_fkey
    FOREIGN KEY (changed_by) REFERENCES profiles(id) ON DELETE SET NULL;
