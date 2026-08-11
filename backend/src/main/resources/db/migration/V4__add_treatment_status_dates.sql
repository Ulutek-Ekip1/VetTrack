-- TreatmentEntry tablosuna status enum, start_date ve end_date kolonlarını ekle
-- Ekip lideri talebi: TreatmentStatus (PLANNED, IN_PROGRESS, COMPLETED, CANCELLED)
-- + tarih bazlı sıralama ve durum filtresi desteği

ALTER TABLE IF EXISTS treatment_entries ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'PLANNED';
ALTER TABLE IF EXISTS treatment_entries ADD COLUMN IF NOT EXISTS start_date TIMESTAMPTZ;
ALTER TABLE IF EXISTS treatment_entries ADD COLUMN IF NOT EXISTS end_date TIMESTAMPTZ;

-- Performans: status filtresi ve start_date sıralaması için index
CREATE INDEX IF NOT EXISTS idx_treatment_entries_status ON treatment_entries(status);
CREATE INDEX IF NOT EXISTS idx_treatment_entries_start_date ON treatment_entries(start_date DESC);
