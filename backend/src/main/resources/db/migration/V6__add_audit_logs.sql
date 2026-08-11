-- V6: Add audit_logs table for tracking entity changes (EC-08)

CREATE TABLE audit_logs (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_name VARCHAR(100) NOT NULL,
    entity_id   UUID NOT NULL,
    action      VARCHAR(50) NOT NULL,
    changed_by  UUID REFERENCES vet_staff(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    details     TEXT
);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_name, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);