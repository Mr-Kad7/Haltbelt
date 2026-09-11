# Recovery Path — Feature-complete application layer

This build includes the code paths for authentication, assessment, recovery tasks, urge support, check-ins, financial planning, support contacts, community moderation, professional profiles/availability, appointments, content CMS/bookmarks, notifications, AI support, admin operations, PWA and desktop/mobile wrappers.

## Before public launch
- Run `supabase/schema.sql`, then `supabase/feature-complete.sql` in the target Supabase project.
- Configure environment variables from `.env.example`.
- Configure Paystack, email, AI, monitoring and analytics only after reviewing privacy, consent and safety requirements.
- Have qualified professionals review all assessment/intervention content and local crisis resources.
- Run `npm run typecheck`, `npm run security:check`, and `npm run build`.
- Perform end-to-end testing with test accounts and Paystack test mode.

## Security model
Private recovery, financial and contact data are protected with Supabase RLS. Service-role and payment secrets are server-only. AI calls are routed through a server endpoint; the browser never receives the OpenAI API key.

## Professional experience layer
- Guided onboarding with recovery priority, support style and current-stage choices.
- Recovery Momentum dashboard (activity-derived, explicitly non-clinical) with Prevent → Intervene → Stabilize → Rebuild → Thrive framing.
- Private care-team directory for trusted contacts.
- Data export and account-deletion request controls.
- Provider directory search/filter and availability-aware appointment selection.
- Notification center with mark-read and mark-all-read actions.
- Accessibility-friendly reduced-motion CSS foundation and responsive layouts.
- Trust/credibility messaging that avoids unsupported clinical claims.
