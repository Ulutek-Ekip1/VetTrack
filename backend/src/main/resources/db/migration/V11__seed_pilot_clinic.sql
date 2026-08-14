-- Provision admin@pilotvet.local in Supabase Auth before running this migration.
INSERT INTO clinics (id, name, address, phone)
VALUES ('11111111-1111-1111-1111-111111111111', 'Pilot Veteriner Kliniği', 'Merkez/İstanbul', '02120000000')
ON CONFLICT (id) DO NOTHING;

INSERT INTO clinic_memberships (user_id, clinic_id, role, is_clinic_admin, status, joined_at)
SELECT p.id, '11111111-1111-1111-1111-111111111111', 'doctor', TRUE, 'active', NOW()
FROM profiles p
WHERE lower(p.email) = 'admin@pilotvet.local'
ON CONFLICT (user_id, clinic_id) DO UPDATE
SET role = 'doctor', is_clinic_admin = TRUE, status = 'active', joined_at = EXCLUDED.joined_at;
