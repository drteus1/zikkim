-- Supabase schema for Zikkim (run in SQL editor)
-- Enables anonymous/standard auth users to manage their own data.

create extension if not exists "pgcrypto";

-- Profiles: one row per user with quit details.
create table if not exists profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  quit_at timestamptz not null,
  cigarettes_per_day integer not null check (cigarettes_per_day > 0),
  price_per_pack numeric(10,2) not null check (price_per_pack > 0),
  currency text default 'USD',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create unique index if not exists profiles_user_unique on profiles (user_id);

-- Cravings log: each craving event belongs to a user.
create table if not exists cravings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  logged_at timestamptz not null default now(),
  intensity smallint check (intensity between 1 and 5),
  trigger_text text,
  note text,
  created_at timestamptz default now()
);

create index if not exists cravings_user_time_idx on cravings (user_id, logged_at desc);

alter table profiles enable row level security;
alter table cravings enable row level security;

-- Allow users to manage only their own profile.
create policy "profiles_select_own" on profiles
  for select using (auth.uid() = user_id);

create policy "profiles_upsert_own" on profiles
  for insert with check (auth.uid() = user_id);

create policy "profiles_update_own" on profiles
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Allow users to manage only their own cravings.
create policy "cravings_select_own" on cravings
  for select using (auth.uid() = user_id);

create policy "cravings_insert_own" on cravings
  for insert with check (auth.uid() = user_id);

create policy "cravings_update_own" on cravings
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Optional: enable delete for owner
create policy "cravings_delete_own" on cravings
  for delete using (auth.uid() = user_id);

