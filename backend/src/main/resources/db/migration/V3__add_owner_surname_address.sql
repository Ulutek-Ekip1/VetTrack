-- Profiles / Owners tablosuna surname ve address kolonlarını ekle
-- Ekip lideri talebi: PUT /owners/me ile ad, soyad, telefon, adres güncellenmeli

ALTER TABLE IF EXISTS profiles ADD COLUMN IF NOT EXISTS surname VARCHAR(100);
ALTER TABLE IF EXISTS profiles ADD COLUMN IF NOT EXISTS address TEXT;