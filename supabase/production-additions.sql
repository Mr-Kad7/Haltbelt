-- Recovery Path production feature additions. Run after the original schema if upgrading an existing database.
CREATE TABLE IF NOT EXISTS public.recovery_tasks (
 id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
 title TEXT NOT NULL, description TEXT, category TEXT NOT NULL DEFAULT 'recovery', due_date DATE, completed_at TIMESTAMPTZ,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_recovery_tasks_user ON public.recovery_tasks(user_id);
CREATE TABLE IF NOT EXISTS public.check_ins (
 id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
 mood INTEGER NOT NULL CHECK(mood BETWEEN 1 AND 10), urge_level INTEGER NOT NULL CHECK(urge_level BETWEEN 0 AND 10), note TEXT,
 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_check_ins_user ON public.check_ins(user_id);
CREATE TABLE IF NOT EXISTS public.support_contacts (
 id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
 name TEXT NOT NULL, relationship TEXT, phone TEXT, email TEXT, preferred_channel TEXT CHECK(preferred_channel IN('call','sms','whatsapp','email')), created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.content_items (
 id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), title TEXT NOT NULL, slug TEXT UNIQUE NOT NULL, summary TEXT, body TEXT, category TEXT NOT NULL DEFAULT 'education',
 published BOOLEAN NOT NULL DEFAULT FALSE, reviewed BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.organizations (
 id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), name TEXT NOT NULL, type TEXT NOT NULL CHECK(type IN('university','employer','ngo','health_service','other')),
 contact_email TEXT, website TEXT, verified BOOLEAN NOT NULL DEFAULT FALSE, created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS public.organization_members (
 organization_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE, user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
 member_role TEXT NOT NULL DEFAULT 'member', created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), PRIMARY KEY(organization_id,user_id)
);
ALTER TABLE public.recovery_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS tasks_own ON public.recovery_tasks;
DROP POLICY IF EXISTS tasks_own ON public.recovery_tasks;
CREATE POLICY tasks_own ON public.recovery_tasks FOR ALL TO authenticated USING(auth.uid()=user_id) WITH CHECK(auth.uid()=user_id);
DROP POLICY IF EXISTS checkins_own ON public.check_ins;
DROP POLICY IF EXISTS checkins_own ON public.check_ins;
CREATE POLICY checkins_own ON public.check_ins FOR ALL TO authenticated USING(auth.uid()=user_id) WITH CHECK(auth.uid()=user_id);
DROP POLICY IF EXISTS contacts_own ON public.support_contacts;
DROP POLICY IF EXISTS contacts_own ON public.support_contacts;
CREATE POLICY contacts_own ON public.support_contacts FOR ALL TO authenticated USING(auth.uid()=user_id) WITH CHECK(auth.uid()=user_id);
DROP POLICY IF EXISTS content_public ON public.content_items;
DROP POLICY IF EXISTS content_public ON public.content_items;
CREATE POLICY content_public ON public.content_items FOR SELECT TO anon,authenticated USING(published=true OR public.is_staff());
DROP POLICY IF EXISTS org_public ON public.organizations;
DROP POLICY IF EXISTS org_public ON public.organizations;
CREATE POLICY org_public ON public.organizations FOR SELECT TO anon,authenticated USING(verified=true OR public.is_staff());
DROP POLICY IF EXISTS org_members_own ON public.organization_members;
DROP POLICY IF EXISTS org_members_own ON public.organization_members;
CREATE POLICY org_members_own ON public.organization_members FOR SELECT TO authenticated USING(auth.uid()=user_id OR public.is_staff());
DROP TRIGGER IF EXISTS update_recovery_tasks_timestamp ON public.recovery_tasks;
CREATE TRIGGER update_recovery_tasks_timestamp BEFORE UPDATE ON public.recovery_tasks FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
DROP TRIGGER IF EXISTS update_content_items_timestamp ON public.content_items;
CREATE TRIGGER update_content_items_timestamp BEFORE UPDATE ON public.content_items FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
CREATE OR REPLACE FUNCTION public.get_public_professionals()
RETURNS TABLE(id UUID,user_id UUID,profession TEXT,specialization TEXT,bio TEXT,hourly_rate NUMERIC,verified BOOLEAN,verified_at TIMESTAMPTZ,name TEXT,profile_image TEXT,location TEXT)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path=public AS $$
 SELECT p.id,p.user_id,p.profession,p.specialization,p.bio,p.hourly_rate,p.verified,p.verified_at,u.name,u.profile_image,u.location
 FROM public.professionals p JOIN public.user_profiles u ON u.id=p.user_id WHERE p.verified=true;
$$;
GRANT EXECUTE ON FUNCTION public.get_public_professionals() TO anon,authenticated;
-- Staff read/write policies for administration and moderation.
DROP POLICY IF EXISTS staff_read_assessments ON public.assessments;
CREATE POLICY staff_read_assessments ON public.assessments FOR SELECT TO authenticated USING(public.is_staff() OR auth.uid()=user_id);
DROP POLICY IF EXISTS staff_read_urge_sessions ON public.urge_sessions;
CREATE POLICY staff_read_urge_sessions ON public.urge_sessions FOR SELECT TO authenticated USING(public.is_staff() OR auth.uid()=user_id);
DROP POLICY IF EXISTS staff_read_financial_data ON public.financial_data;
CREATE POLICY staff_read_financial_data ON public.financial_data FOR SELECT TO authenticated USING(public.is_staff() OR auth.uid()=user_id);
DROP POLICY IF EXISTS staff_read_debt ON public.debt;
CREATE POLICY staff_read_debt ON public.debt FOR SELECT TO authenticated USING(public.is_staff() OR auth.uid()=user_id);
DROP POLICY IF EXISTS staff_read_appointments ON public.appointments;
CREATE POLICY staff_read_appointments ON public.appointments FOR SELECT TO authenticated USING(public.is_staff() OR auth.uid()=user_id OR EXISTS(SELECT 1 FROM public.professionals p WHERE p.id=professional_id AND p.user_id=auth.uid()));
DROP POLICY IF EXISTS staff_manage_content ON public.content_items;
CREATE POLICY staff_manage_content ON public.content_items FOR ALL TO authenticated USING(public.is_staff()) WITH CHECK(public.is_staff());
DROP POLICY IF EXISTS staff_manage_orgs ON public.organizations;
CREATE POLICY staff_manage_orgs ON public.organizations FOR ALL TO authenticated USING(public.is_staff()) WITH CHECK(public.is_staff());
DROP POLICY IF EXISTS staff_manage_professionals ON public.professionals;
CREATE POLICY staff_manage_professionals ON public.professionals FOR ALL TO authenticated USING(public.is_staff() OR auth.uid()=user_id) WITH CHECK(public.is_staff() OR auth.uid()=user_id);
