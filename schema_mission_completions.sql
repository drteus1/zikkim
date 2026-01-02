-- Mission completions table for local missions
-- Run this in Supabase SQL editor

create table if not exists mission_completions (
  id uuid primary key default gen_random_uuid(),
  mission_id text not null,  -- references LocalMission.id (string like "first-coffee")
  user_id uuid not null references auth.users (id) on delete cascade,
  completed_at timestamptz default now(),
  created_at timestamptz default now(),
  
  -- Ensure each user can only complete a mission once
  unique (user_id, mission_id)
);

create index if not exists mission_completions_user_idx on mission_completions (user_id);

alter table mission_completions enable row level security;

-- Policies
create policy "mission_completions_select_own" on mission_completions
  for select using (auth.uid() = user_id);

create policy "mission_completions_insert_own" on mission_completions
  for insert with check (auth.uid() = user_id);

create policy "mission_completions_delete_own" on mission_completions
  for delete using (auth.uid() = user_id);

