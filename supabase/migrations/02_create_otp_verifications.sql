-- ==============================================================================
-- Pet Care Medical App - Migration 02: Private OTP Verifications Schema
-- ==============================================================================

-- 1. Create private otp_verifications table
create table if not exists public.otp_verifications (
    id uuid primary key default gen_random_uuid(),
    phone text not null,
    otp_hash text not null,
    salt text not null,
    attempts integer not null default 0,
    max_attempts integer not null default 5,
    is_verified boolean not null default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    expires_at timestamp with time zone not null,
    verified_at timestamp with time zone
);

-- 2. Enable Row Level Security (RLS)
alter table public.otp_verifications enable row level security;

-- 3. Strict RLS Policies: ZERO PUBLIC ACCESS
-- Revoke all permissions from anon and authenticated roles.
-- Only the Edge Functions (using service_role key) can read and write this table.
revoke all on public.otp_verifications from anon, authenticated;

-- Ensure no policies exist for public access
drop policy if exists "No public access" on public.otp_verifications;

-- 4. Indices for high performance and rate limiting
create index if not exists idx_otp_phone_lookup 
    on public.otp_verifications (phone, is_verified, expires_at);

create index if not exists idx_otp_rate_limit 
    on public.otp_verifications (phone, created_at desc);

-- 5. Stored Procedure for Automatic Expired OTP Cleanup
create or replace function public.cleanup_expired_otps()
returns void
language plpgsql
security definer
as $$
begin
    -- Clean up OTP records older than 24 hours
    delete from public.otp_verifications
    where created_at < (now() - interval '24 hours');
end;
$$;
