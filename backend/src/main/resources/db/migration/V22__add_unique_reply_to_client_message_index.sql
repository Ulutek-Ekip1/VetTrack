-- P1: Ensure uniqueness for reply_to_client_message_id per owner to guarantee idempotency at the DB level
CREATE UNIQUE INDEX IF NOT EXISTS uq_owner_reply_to_client_message 
ON chat_messages (owner_id, reply_to_client_message_id) 
WHERE reply_to_client_message_id IS NOT NULL;
