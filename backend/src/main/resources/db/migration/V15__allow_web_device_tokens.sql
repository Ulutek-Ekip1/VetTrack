-- V15: Allow 'web' platform in device_tokens platform check constraint
ALTER TABLE public.device_tokens
    DROP CONSTRAINT IF EXISTS device_tokens_platform_check;

ALTER TABLE public.device_tokens
    ADD CONSTRAINT device_tokens_platform_check
    CHECK (platform IN ('ios', 'android', 'web'));
