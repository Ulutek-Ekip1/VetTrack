CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE owners (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    phone      VARCHAR(20),
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TABLE pets (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id    UUID NOT NULL REFERENCES owners(id),
    name        VARCHAR(100) NOT NULL,
    photo_url   TEXT,
    age         INTEGER,
    gender      VARCHAR(10) CHECK (gender IN ('male','female','unknown')),
    breed       VARCHAR(100),
    unique_code VARCHAR(6) NOT NULL UNIQUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_pets_owner ON pets(owner_id);
CREATE INDEX idx_pets_code ON pets(UPPER(unique_code));

CREATE TABLE vet_staff (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    clinic_id  UUID,
    role       VARCHAR(20) CHECK (role IN ('doctor','staff')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE visits (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pet_id       UUID NOT NULL REFERENCES pets(id),
    vet_staff_id UUID NOT NULL REFERENCES vet_staff(id),
    status       VARCHAR(20) NOT NULL DEFAULT 'ongoing'
                 CHECK (status IN ('ongoing','completed')),
    started_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at     TIMESTAMPTZ
);
CREATE UNIQUE INDEX idx_visits_one_ongoing
    ON visits(pet_id) WHERE status = 'ongoing';

CREATE TABLE treatment_entries (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id       UUID NOT NULL REFERENCES visits(id),
    type           VARCHAR(20) NOT NULL
                   CHECK (type IN ('medication','xray','lab_result','note')),
    title          VARCHAR(200) NOT NULL,
    description    TEXT,
    attachment_url TEXT,
    entered_by     UUID NOT NULL REFERENCES vet_staff(id),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE recommendations (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id    UUID NOT NULL REFERENCES visits(id),
    type        VARCHAR(20) CHECK (type IN ('food','litter','other')),
    description TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE notifications (
    id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id           UUID NOT NULL REFERENCES owners(id),
    treatment_entry_id UUID REFERENCES treatment_entries(id),
    title              VARCHAR(200) NOT NULL,
    body               TEXT,
    is_read            BOOLEAN NOT NULL DEFAULT false,
    sent_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_notif_owner ON notifications(owner_id, sent_at DESC);

CREATE TABLE device_tokens (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id   UUID NOT NULL REFERENCES owners(id),
    fcm_token  TEXT NOT NULL,
    platform   VARCHAR(10) CHECK (platform IN ('ios','android')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(owner_id, fcm_token)
);
