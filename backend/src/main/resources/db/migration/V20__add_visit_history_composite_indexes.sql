-- V20: RFC-2026-VET-001 Değişiklik 3 — Ziyaret geçmişi ekranları için performans indeksleri.
-- GET /visits/vet ve GET /visits/owner sorguları vet_staff_id / pet_id üzerinden filtreleyip
-- started_at DESC ile sıralıyor. Kayıt sayısı arttıkça Full Table Scan'i önlemek için
-- (filtre kolonu, started_at DESC) kompozit indeksleri gerekiyor.
--
-- Not 1: V9'daki tek-kolonlu idx_visits_pet_id / idx_visits_vet_staff_id indeksleri
--        ORDER BY started_at DESC'i kapsamıyor; bu kompozit indeksler onları tamamlar.
-- Not 2: pets(owner_id) indeksi zaten var (V1 idx_pets_owner + V9 idx_pets_owner_id),
--        Değişiklik 3'ün sahip-sorgusu kısmı için ek bir şey gerekmiyor.
-- Not 3: Tüm ifadeler idempotent (IF NOT EXISTS) — gerçek DB'ye elle de güvenle çalıştırılabilir.

CREATE INDEX IF NOT EXISTS idx_visits_vet_staff_started
    ON visits (vet_staff_id, started_at DESC);

CREATE INDEX IF NOT EXISTS idx_visits_pet_started
    ON visits (pet_id, started_at DESC);
