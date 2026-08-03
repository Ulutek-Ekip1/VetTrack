-- Owners tablosuna surname ve address kolonlarını ekle
-- Ekip lideri talebi: PUT /owners/me ile ad, soyad, telefon, adres güncellenmeli

ALTER TABLE owners ADD COLUMN surname VARCHAR(100);
ALTER TABLE owners ADD COLUMN address TEXT;