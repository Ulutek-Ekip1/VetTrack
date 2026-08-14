-- PRE-CONDITION (manuel adım — CI/sıfır ortamında kritik):
--   Bu migration çalışmadan önce Supabase Auth'ta admin@pilotvet.local
--   kullanıcısının oluşturulmuş VE profiles tablosuna senkronize edilmiş olması
--   gerekir. Bu koşul karşılanmazsa klinik satırı oluşturulur ancak üyelik
--   INSERT'i etkilenen-satır sıfır döner (sessiz başarısızlık — hata fırlatmaz).
--   Sonuç: pilot klinik sahipsiz (orphan) kalır, admin onu yönetemez.
--   CI pipeline çözümü: migration öncesi Supabase test kullanıcısı seed adımı
--   ekleyin veya bu migration'ı production-only olarak işaretleyin.
INSERT INTO clinics (id, name, address, phone)
VALUES ('11111111-1111-1111-1111-111111111111', 'Pilot Veteriner Kliniği', 'Merkez/İstanbul', '02120000000')
ON CONFLICT (id) DO NOTHING;

INSERT INTO clinic_memberships (user_id, clinic_id, role, is_clinic_admin, status, joined_at)
SELECT p.id, '11111111-1111-1111-1111-111111111111', 'doctor', TRUE, 'active', NOW()
FROM profiles p
WHERE lower(p.email) = 'admin@pilotvet.local'
ON CONFLICT (user_id, clinic_id) DO UPDATE
SET role = 'doctor', is_clinic_admin = TRUE, status = 'active', joined_at = EXCLUDED.joined_at;
