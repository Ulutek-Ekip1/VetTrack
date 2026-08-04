-- TreatmentEntry tablosuna status enum, start_date ve end_date kolonlarını ekle
-- Ekip lideri talebi: TreatmentStatus (PLANNED, IN_PROGRESS, COMPLETED, CANCELLED)
-- + tarih bazlı sıralama ve durum filtresi desteği

ALTER TABLE treatment_entries ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'PLANNED';
ALTER TABLE treatment_entries ADD COLUMN start_date TIMESTAMPTZ;
ALTER TABLE treatment_entries ADD COLUMN end_date TIMESTAMPTZ;

-- Performans: status filtresi ve start_date sıralaması için index
CREATE INDEX idx_treatment_entries_status ON treatment_entries(status);
CREATE INDEX idx_treatment_entries_start_date ON treatment_entries(start_date DESC);
