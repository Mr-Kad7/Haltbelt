-- Recovery Path final application additions. Run AFTER supabase/schema.sql.
-- This migration is compatible with the feature tables already included in schema.sql.
create table if not exists public.notification_preferences (
 user_id uuid primary key references auth.users(id) on delete cascade,
 recovery_reminders boolean not null default true, appointment_reminders boolean not null default true,
 community_updates boolean not null default false, email_notifications boolean not null default true,
 push_notifications boolean not null default true, updated_at timestamptz not null default now()
);
create table if not exists public.content_bookmarks (
 user_id uuid not null references auth.users(id) on delete cascade,
 content_id uuid not null references public.content_items(id) on delete cascade,
 created_at timestamptz not null default now(), primary key(user_id,content_id)
);
create table if not exists public.ai_conversations (
 id uuid primary key default uuid_generate_v4(), user_id uuid not null references auth.users(id) on delete cascade,
 title text, messages jsonb not null default '[]'::jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.audit_logs (
 id uuid primary key default uuid_generate_v4(), actor_id uuid references auth.users(id) on delete set null,
 action text not null, entity_type text, entity_id uuid, metadata jsonb default '{}'::jsonb, created_at timestamptz not null default now()
);
create index if not exists idx_audit_created on public.audit_logs(created_at desc);
create index if not exists idx_ai_user on public.ai_conversations(user_id);
alter table public.notification_preferences enable row level security; alter table public.content_bookmarks enable row level security;
alter table public.ai_conversations enable row level security; alter table public.audit_logs enable row level security;
drop policy if exists prefs_own on public.notification_preferences; create policy prefs_own on public.notification_preferences for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists bookmarks_own on public.content_bookmarks; create policy bookmarks_own on public.content_bookmarks for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists ai_own on public.ai_conversations; create policy ai_own on public.ai_conversations for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists audit_staff_read on public.audit_logs; create policy audit_staff_read on public.audit_logs for select to authenticated using(public.is_staff());
drop policy if exists audit_insert_own on public.audit_logs; create policy audit_insert_own on public.audit_logs for insert to authenticated with check(actor_id=auth.uid() or public.is_staff());
-- Add richer content fields to the existing content table without replacing its shape.
alter table public.content_items add column if not exists excerpt text;
alter table public.content_items add column if not exists media_url text;
alter table public.content_items add column if not exists featured boolean not null default false;
update public.content_items set excerpt=coalesce(excerpt,summary) where excerpt is null;
insert into public.content_items(title,slug,summary,body,category,published,reviewed,excerpt,featured)
values
('The gambling cycle','the-gambling-cycle','Understand the pattern and where a pause can interrupt it.','Gambling can move through triggers, anticipation, betting, wins or losses, and attempts to recover losses. Learning the pattern can create a pause before the next decision.','foundations',true,true,'Understand the pattern and where a pause can interrupt it.',true),
('Chasing losses','chasing-losses','Why trying to win back losses can make the situation harder.','A loss does not create a debt that probability owes back. Trying to recover quickly can increase exposure and deepen financial harm.','money',true,true,'Why trying to win back losses can make the situation harder.',false),
('Cravings are temporary','cravings-are-temporary','Use a short delay to create room for a safer decision.','An urge can feel urgent without being permanent. Delay, distance from gambling access, regulation and connection can help intensity change.','urge-support',true,true,'Use a short delay to create room for a safer decision.',true)
on conflict(slug) do nothing;
