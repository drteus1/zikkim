-- Missions schema additions

create table if not exists missions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  category text,
  sort_order integer default 0,
  reward text,
  active boolean default true,
  created_at timestamptz default now()
);

create table if not exists mission_progress (
  id uuid primary key default gen_random_uuid(),
  mission_id uuid not null references missions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  status text not null check (status in ('pending','completed')),
  note text,
  completed_at timestamptz,
  created_at timestamptz default now()
);

create index if not exists mission_progress_user_idx on mission_progress (user_id, mission_id);

alter table missions enable row level security;
alter table mission_progress enable row level security;

-- Policies
create policy "missions_read_all" on missions
  for select using (true);

create policy "mission_progress_select_own" on mission_progress
  for select using (auth.uid() = user_id);

create policy "mission_progress_insert_own" on mission_progress
  for insert with check (auth.uid() = user_id);

create policy "mission_progress_update_own" on mission_progress
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "mission_progress_delete_own" on mission_progress
  for delete using (auth.uid() = user_id);

