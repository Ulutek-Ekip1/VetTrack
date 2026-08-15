-- V14__fix_token_hash_type_and_drop_legacy_notify_fn.sql

-- 1. clinic_invites.token_hash: bpchar(64) -> varchar(64)
--    V10 CHAR(64) (bpchar) olarak olusturdu; JPA Entity @Column(length=64)
--    varchar urettiginden ddl-auto: validate gercek Postgres'te tip uyumsuzlugu
--    firliyor ve uygulama acilmiyor. Veriler korunur (bpchar->varchar guvenli donusum).
ALTER TABLE clinic_invites
    ALTER COLUMN token_hash TYPE VARCHAR(64);

-- 2. V9'dan kalan eski notify_owner_on_treatment() fonksiyonunu kaldir.
--    V12, trigger_notify_on_treatment'i trg_create_treatment_notification()'a
--    yeniden bagladi. Eski fonksiyon artik cagrilmiyor ancak DB'de tutunuyor;
--    CASCADE ile birlikte bu fonksiyon ve ona bagli herhangi bir trigger (varsa)
--    temizlenir. Karisikligi onler, NEW.entry_type referansi ortadan kalkar.
DROP FUNCTION IF EXISTS public.notify_owner_on_treatment() CASCADE;
