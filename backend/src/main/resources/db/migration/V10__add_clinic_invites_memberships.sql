-- V9 already owns the clinics table and visits.clinic_id. This migration adds
-- the invite-based many-to-many membership model without recreating V9 objects.
CREATE TABLE IF NOT EXISTS clinic_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL,
    is_clinic_admin BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT clinic_memberships_user_clinic_unique UNIQUE(user_id, clinic_id),
    CONSTRAINT clinic_memberships_role_check CHECK (role IN ('doctor', 'staff')),
    CONSTRAINT clinic_memberships_status_check CHECK (status IN ('invited', 'active', 'disabled'))
);
CREATE INDEX IF NOT EXISTS idx_clinic_memberships_clinic_user_status ON clinic_memberships(clinic_id, user_id, status);
CREATE INDEX IF NOT EXISTS idx_clinic_memberships_user_status ON clinic_memberships(user_id, status);

CREATE TABLE IF NOT EXISTS clinic_invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_id UUID NOT NULL REFERENCES clinics(id) ON DELETE CASCADE,
    email VARCHAR(255),
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    accepted_at TIMESTAMP WITH TIME ZONE,
    revoked_at TIMESTAMP WITH TIME ZONE,
    created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT clinic_invites_lifecycle_check CHECK (NOT (accepted_at IS NOT NULL AND revoked_at IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS idx_clinic_invites_clinic_active
    ON clinic_invites(clinic_id, expires_at) WHERE accepted_at IS NULL AND revoked_at IS NULL;
