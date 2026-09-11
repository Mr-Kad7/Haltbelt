-- Recovery Path professional polish migration. Run after schema.sql and feature-complete.sql.
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS onboarding_completed boolean NOT NULL DEFAULT false;
CREATE TABLE IF NOT EXISTS public.care_team (
 id uuid primary key default uuid_generate_v4(), user_id uuid not null references auth.users(id) on delete cascade,
 name text not null, role text not null, contact text, notes text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
CREATE TABLE IF NOT EXISTS public.account_deletion_requests (
 id uuid primary key default uuid_generate_v4(), user_id uuid not null unique references auth.users(id) on delete cascade,
 reason text, status text not null default 'requested' check(status in ('requested','processing','completed','cancelled')),
 created_at timestamptz not null default now(), processed_at timestamptz
);
CREATE INDEX IF NOT EXISTS idx_care_team_user ON public.care_team(user_id);
CREATE INDEX IF NOT EXISTS idx_delete_requests_status ON public.account_deletion_requests(status);
ALTER TABLE public.care_team ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_deletion_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS care_team_own ON public.care_team;
CREATE POLICY care_team_own ON public.care_team FOR ALL TO authenticated USING(auth.uid()=user_id) WITH CHECK(auth.uid()=user_id);
DROP POLICY IF EXISTS delete_request_own ON public.account_deletion_requests;
CREATE POLICY delete_request_own ON public.account_deletion_requests FOR INSERT TO authenticated WITH CHECK(auth.uid()=user_id);
CREATE POLICY delete_request_read_own ON public.account_deletion_requests FOR SELECT TO authenticated USING(auth.uid()=user_id OR public.is_staff());
CREATE TRIGGER update_care_team_timestamp BEFORE UPDATE ON public.care_team FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
