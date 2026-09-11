-- Recovery Path — Complete Supabase Database Schema
-- Secure baseline for the Recovery Path gambling-recovery platform.
-- Run this in Supabase SQL Editor on a new/empty project.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  date_of_birth DATE,
  gender TEXT CHECK (gender IN ('male','female','other','prefer_not_to_say')),
  location TEXT,
  profile_image TEXT,
  bio TEXT,
  role TEXT NOT NULL DEFAULT 'USER'
    CHECK (role IN ('USER','THERAPIST','FINANCIAL_PROFESSIONAL','ORGANIZATION','MODERATOR','ADMIN','SUPER_ADMIN')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT name_length CHECK (LENGTH(TRIM(name)) >= 2)
);

CREATE TABLE IF NOT EXISTS public.recovery_plans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  goals TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.assessments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('screening','pgsi','custom')),
  score INTEGER,
  responses JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.triggers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  risk_level TEXT NOT NULL CHECK (risk_level IN ('low','medium','high')),
  coping_strategies TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.urge_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_time TIMESTAMPTZ,
  trigger TEXT,
  intensity INTEGER CHECK (intensity BETWEEN 1 AND 10),
  outcome TEXT CHECK (outcome IN ('abstained','lapsed','relapsed','pending')),
  notes TEXT,
  exercises_completed TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.financial_data (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month TEXT NOT NULL,
  income NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (income >= 0),
  essential_expenses NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (essential_expenses >= 0),
  gambling_losses NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (gambling_losses >= 0),
  debt_payment NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (debt_payment >= 0),
  savings NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (savings >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, month)
);

CREATE TABLE IF NOT EXISTS public.debt (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  creditor TEXT NOT NULL,
  interest_rate NUMERIC(5,2) CHECK (interest_rate >= 0),
  monthly_payment NUMERIC(12,2) CHECK (monthly_payment >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.budget (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  allocated_amount NUMERIC(12,2) NOT NULL CHECK (allocated_amount >= 0),
  spent_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (spent_amount >= 0),
  month TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, category, month)
);

CREATE TABLE IF NOT EXISTS public.progress_milestones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  milestone_type TEXT CHECK (milestone_type IN ('days_sober','financial','mental_health','custom')),
  achieved_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.community_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT title_length CHECK (LENGTH(TRIM(title)) >= 5),
  CONSTRAINT content_length CHECK (LENGTH(TRIM(content)) >= 10)
);

CREATE TABLE IF NOT EXISTS public.comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT comment_length CHECK (LENGTH(TRIM(content)) >= 1)
);

CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reported_item_id UUID NOT NULL,
  reported_item_type TEXT NOT NULL CHECK (reported_item_type IN ('post','comment','user')),
  reason TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','reviewed','resolved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS public.professionals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  profession TEXT CHECK (profession IN ('therapist','financial_advisor','counselor','coach')),
  specialization TEXT NOT NULL,
  license_number TEXT NOT NULL UNIQUE,
  bio TEXT NOT NULL,
  hourly_rate NUMERIC(8,2) NOT NULL CHECK (hourly_rate >= 0),
  verified BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  professional_id UUID NOT NULL REFERENCES public.professionals(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

CREATE TABLE IF NOT EXISTS public.appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  professional_id UUID NOT NULL REFERENCES public.professionals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scheduled_at TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER NOT NULL DEFAULT 60 CHECK (duration_minutes BETWEEN 15 AND 240),
  status TEXT NOT NULL DEFAULT 'scheduled'
    CHECK (status IN ('scheduled','completed','cancelled','no_show')),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan TEXT CHECK (plan IN ('free','premium','professional','organization')),
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active','cancelled','paused')),
  start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  end_date TIMESTAMPTZ,
  payment_method TEXT,
  provider_customer_id TEXT,
  provider_subscription_id TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, plan)
);

CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  currency TEXT NOT NULL DEFAULT 'GHS',
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','completed','failed','refunded')),
  payment_type TEXT CHECK (payment_type IN ('subscription','appointment','donation')),
  transaction_id TEXT UNIQUE,
  provider TEXT DEFAULT 'paystack',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('recovery_check_in','appointment_reminder','urge_support','achievement','community')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- 2. INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_recovery_plans_user_id ON public.recovery_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_assessments_user_id ON public.assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_triggers_user_id ON public.triggers(user_id);
CREATE INDEX IF NOT EXISTS idx_urge_sessions_user_id ON public.urge_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_financial_data_user_id ON public.financial_data(user_id);
CREATE INDEX IF NOT EXISTS idx_debt_user_id ON public.debt(user_id);
CREATE INDEX IF NOT EXISTS idx_budget_user_id ON public.budget(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_milestones_user_id ON public.progress_milestones(user_id);
CREATE INDEX IF NOT EXISTS idx_community_posts_user_id ON public.community_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_post_id ON public.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON public.comments(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter_id ON public.reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_appointments_user_id ON public.appointments(user_id);
CREATE INDEX IF NOT EXISTS idx_appointments_professional_id ON public.appointments(professional_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);

-- ============================================================
-- 3. UPDATED_AT FUNCTION
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS update_user_profiles_timestamp ON public.user_profiles;
CREATE TRIGGER update_user_profiles_timestamp
BEFORE UPDATE ON public.user_profiles
FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS update_recovery_plans_timestamp ON public.recovery_plans;
CREATE TRIGGER update_recovery_plans_timestamp
BEFORE UPDATE ON public.recovery_plans
FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS update_assessments_timestamp ON public.assessments;
CREATE TRIGGER update_assessments_timestamp
BEFORE UPDATE ON public.assessments
FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS update_community_posts_timestamp ON public.community_posts;
CREATE TRIGGER update_community_posts_timestamp
BEFORE UPDATE ON public.community_posts
FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

DROP TRIGGER IF EXISTS update_comments_timestamp ON public.comments;
CREATE TRIGGER update_comments_timestamp
BEFORE UPDATE ON public.comments
FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();

-- ============================================================
-- 4. PROFILE CREATION ON SIGN-UP
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  display_name TEXT;
BEGIN
  display_name := COALESCE(
    NULLIF(TRIM(NEW.raw_user_meta_data ->> 'name'), ''),
    NULLIF(TRIM(NEW.raw_user_meta_data ->> 'full_name'), ''),
    split_part(COALESCE(NEW.email, 'user'), '@', 1)
  );

  INSERT INTO public.user_profiles (id, email, name)
  VALUES (NEW.id, COALESCE(NEW.email, ''), display_name)
  ON CONFLICT (id) DO UPDATE
    SET email = EXCLUDED.email;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 5. ADMIN / MODERATOR HELPER
-- ============================================================

CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_profiles
    WHERE id = auth.uid()
      AND role IN ('MODERATOR','ADMIN','SUPER_ADMIN')
  );
$$;

REVOKE ALL ON FUNCTION public.is_staff() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_staff() TO authenticated;

-- ============================================================
-- 6. ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recovery_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.triggers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.urge_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debt ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budget ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progress_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professionals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 7. POLICIES
-- ============================================================

-- Profiles
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
CREATE POLICY "Users can view their own profile"
ON public.user_profiles FOR SELECT
TO authenticated
USING (auth.uid() = id OR public.is_staff());

DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
CREATE POLICY "Users can update their own profile"
ON public.user_profiles FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Prevent normal users from changing their own role through the client.
CREATE OR REPLACE FUNCTION public.prevent_role_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role AND NOT public.is_staff() THEN
    RAISE EXCEPTION 'Only staff can change roles';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS prevent_role_change_trigger ON public.user_profiles;
CREATE TRIGGER prevent_role_change_trigger
BEFORE UPDATE ON public.user_profiles
FOR EACH ROW EXECUTE FUNCTION public.prevent_role_change();

-- Recovery plans
DROP POLICY IF EXISTS "Users can view own recovery plans" ON public.recovery_plans;
CREATE POLICY "Users can view own recovery plans"
ON public.recovery_plans FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create recovery plans" ON public.recovery_plans;
CREATE POLICY "Users can create recovery plans"
ON public.recovery_plans FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own recovery plans" ON public.recovery_plans;
CREATE POLICY "Users can update own recovery plans"
ON public.recovery_plans FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own recovery plans" ON public.recovery_plans;
CREATE POLICY "Users can delete own recovery plans"
ON public.recovery_plans FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Assessments
DROP POLICY IF EXISTS "Users can view own assessments" ON public.assessments;
CREATE POLICY "Users can view own assessments"
ON public.assessments FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own assessments" ON public.assessments;
CREATE POLICY "Users can create own assessments"
ON public.assessments FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own assessments" ON public.assessments;
CREATE POLICY "Users can update own assessments"
ON public.assessments FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Triggers
DROP POLICY IF EXISTS "Users can manage own triggers" ON public.triggers;
CREATE POLICY "Users can view own triggers"
ON public.triggers FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can create own triggers"
ON public.triggers FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own triggers"
ON public.triggers FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own triggers"
ON public.triggers FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Urge sessions
DROP POLICY IF EXISTS "Users can view own urge sessions" ON public.urge_sessions;
CREATE POLICY "Users can view own urge sessions"
ON public.urge_sessions FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create urge sessions" ON public.urge_sessions;
CREATE POLICY "Users can create urge sessions"
ON public.urge_sessions FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own urge sessions" ON public.urge_sessions;
CREATE POLICY "Users can update own urge sessions"
ON public.urge_sessions FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Financial data
DROP POLICY IF EXISTS "Users can view own financial data" ON public.financial_data;
CREATE POLICY "Users can view own financial data"
ON public.financial_data FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create financial data" ON public.financial_data;
CREATE POLICY "Users can create financial data"
ON public.financial_data FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own financial data" ON public.financial_data;
CREATE POLICY "Users can update own financial data"
ON public.financial_data FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own financial data" ON public.financial_data;
CREATE POLICY "Users can delete own financial data"
ON public.financial_data FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Debt
CREATE POLICY "Users can view own debt"
ON public.debt FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can create own debt"
ON public.debt FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own debt"
ON public.debt FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own debt"
ON public.debt FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Budget
CREATE POLICY "Users can view own budget"
ON public.budget FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can create own budget"
ON public.budget FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budget"
ON public.budget FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own budget"
ON public.budget FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Progress milestones
CREATE POLICY "Users can view own milestones"
ON public.progress_milestones FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can create own milestones"
ON public.progress_milestones FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own milestones"
ON public.progress_milestones FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Community posts
CREATE POLICY "Anyone can view community posts"
ON public.community_posts FOR SELECT TO anon, authenticated
USING (TRUE);

CREATE POLICY "Authenticated users can create posts"
ON public.community_posts FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
ON public.community_posts FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
ON public.community_posts FOR DELETE TO authenticated
USING (auth.uid() = user_id OR public.is_staff());

-- Comments
CREATE POLICY "Anyone can view comments"
ON public.comments FOR SELECT TO anon, authenticated
USING (TRUE);

CREATE POLICY "Authenticated users can create comments"
ON public.comments FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments"
ON public.comments FOR UPDATE TO authenticated
USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
ON public.comments FOR DELETE TO authenticated
USING (auth.uid() = user_id OR public.is_staff());

-- Reports
CREATE POLICY "Users can create reports"
ON public.reports FOR INSERT TO authenticated
WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can view own reports"
ON public.reports FOR SELECT TO authenticated
USING (auth.uid() = reporter_id OR public.is_staff());

CREATE POLICY "Staff can update reports"
ON public.reports FOR UPDATE TO authenticated
USING (public.is_staff())
WITH CHECK (public.is_staff());

-- Professionals: public listing is through a safe view below.
CREATE POLICY "Professionals can view own profile"
ON public.professionals FOR SELECT TO authenticated
USING (auth.uid() = user_id OR public.is_staff());

CREATE POLICY "Professionals can create own profile"
ON public.professionals FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Professionals can update own profile"
ON public.professionals FOR UPDATE TO authenticated
USING (auth.uid() = user_id OR public.is_staff())
WITH CHECK (auth.uid() = user_id OR public.is_staff());

-- Availability
CREATE POLICY "Anyone can view availability"
ON public.availability FOR SELECT TO anon, authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.verified = TRUE
  )
);

CREATE POLICY "Professionals can manage own availability"
ON public.availability FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.user_id = auth.uid()
  )
);

CREATE POLICY "Professionals can update own availability"
ON public.availability FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.user_id = auth.uid()
  )
);

CREATE POLICY "Professionals can delete own availability"
ON public.availability FOR DELETE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.user_id = auth.uid()
  )
);

-- Appointments
CREATE POLICY "Users can view own appointments"
ON public.appointments FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Professionals can view their appointments"
ON public.appointments FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.user_id = auth.uid()
  )
);

CREATE POLICY "Users can create appointments"
ON public.appointments FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own appointments"
ON public.appointments FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Professionals can update their appointments"
ON public.appointments FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.professionals p
    WHERE p.id = professional_id AND p.user_id = auth.uid()
  )
);

-- Subscriptions: client can read; server/webhook should write.
CREATE POLICY "Users can view own subscriptions"
ON public.subscriptions FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Payments: client can read own payments; server/webhook should write.
CREATE POLICY "Users can view own payments"
ON public.payments FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Notifications
CREATE POLICY "Users can view own notifications"
ON public.notifications FOR SELECT TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
ON public.notifications FOR UPDATE TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- 8. SAFE PUBLIC PROFESSIONAL DIRECTORY
-- ============================================================

CREATE OR REPLACE VIEW public.public_professionals
WITH (security_invoker = true)
AS
SELECT
  p.id,
  p.user_id,
  p.profession,
  p.specialization,
  p.bio,
  p.hourly_rate,
  p.verified,
  p.verified_at,
  u.name,
  u.profile_image,
  u.location
FROM public.professionals p
JOIN public.user_profiles u ON u.id = p.user_id
WHERE p.verified = TRUE;

-- ============================================================
-- 9. COMMENTS
-- ============================================================
-- Payment records and subscription updates should be written by
-- trusted server-side code/webhooks, not directly by the browser.
-- Never expose the Supabase service-role key to the client.
-- Complete feature additions included in this file.
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
