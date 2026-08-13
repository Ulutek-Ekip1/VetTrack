CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID,
    client_message_id VARCHAR(100),
    owner_id UUID NOT NULL,
    pet_id UUID,
    role VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    is_emergency BOOLEAN DEFAULT FALSE,
    model_name VARCHAR(50),
    prompt_version VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_owner_client_message UNIQUE (owner_id, client_message_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_owner_pet ON chat_messages(owner_id, pet_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_idempotency ON chat_messages(owner_id, client_message_id);

-- Update visits status CHECK constraint to allow 'cancelled'
ALTER TABLE visits DROP CONSTRAINT IF EXISTS visits_status_check;
ALTER TABLE visits ADD CONSTRAINT visits_status_check CHECK (status IN ('ongoing', 'completed', 'cancelled'));

-- Persistent notification sent flag for treatment entries
ALTER TABLE treatment_entries ADD COLUMN IF NOT EXISTS notification_sent BOOLEAN DEFAULT FALSE;
