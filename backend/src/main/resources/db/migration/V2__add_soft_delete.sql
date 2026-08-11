-- EC-05: Soft delete desteği
-- pets tablosuna deleted_at kolonu ekleniyor
-- NULL = aktif, dolu = pasife alınmış

ALTER TABLE pets ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
