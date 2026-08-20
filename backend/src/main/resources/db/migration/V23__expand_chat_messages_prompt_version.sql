-- Expand prompt_version column length to accommodate detailed version names (e.g. v1.3-security-guardrail)
ALTER TABLE chat_messages
ALTER COLUMN prompt_version TYPE VARCHAR(50);
