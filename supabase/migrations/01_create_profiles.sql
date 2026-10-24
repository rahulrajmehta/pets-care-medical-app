-- ==============================================================================
-- Pet Care Medical App - Migration 01: User Profiles Schema & Security Policies
-- ==============================================================================

-- 1. Create profiles table linked to Supabase auth.users
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    full_name text not null default '',
    phone text,
    email text,
    avatar_url text,
    is_profile_completed boolean not null default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Enable Row Level Security (RLS)
alter table public.profiles enable row level security;

-- 3. Row Level Security Policies
-- Allow authenticated users to view only their own profile
drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile"
    on public.profiles
    for select
    to authenticated
    using (auth.uid() = id);

-- Allow authenticated users to insert their own profile
drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
    on public.profiles
    for insert
    to authenticated
    with check (auth.uid() = id);

-- Allow authenticated users to update only their own profile
drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
    on public.profiles
    for update
    to authenticated
    using (auth.uid() = id)
    with check (auth.uid() = id);

-- 4. Trigger to automatically provision a profile row when an auth.user is created
create or replace function public.handle_new_user()
returns trigger
security definer
set search_path = public
language plpgsql
as $$
begin
    insert into public.profiles (id, phone, full_name, is_profile_completed)
    values (new.id, coalesce(new.phone, ''), '', false)
    on conflict (id) do nothing;
    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row
    execute procedure public.handle_new_user();

-- 5. Trigger for updated_at timestamp maintenance
create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = timezone('utc'::text, now());
    return new;
end;
$$;

drop trigger if exists on_profiles_updated on public.profiles;
create trigger on_profiles_updated
    before update on public.profiles
    for each row
    execute procedure public.handle_updated_at();

-- Add indices for optimized query performance
create index if not exists idx_profiles_phone on public.profiles (phone);
create index if not exists idx_profiles_completed on public.profiles (is_profile_completed);
