-- V23: Allow deleting treatment entries by setting treatment_entry_id to NULL in notifications
ALTER TABLE notifications
    DROP CONSTRAINT IF EXISTS notifications_treatment_entry_id_fkey;

ALTER TABLE notifications
    ADD CONSTRAINT notifications_treatment_entry_id_fkey
    FOREIGN KEY (treatment_entry_id)
    REFERENCES treatment_entries(id)
    ON DELETE SET NULL;
    