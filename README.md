# Recovery Path — Production Platform Build

Recovery Path is a privacy-first gambling-recovery platform organized around **Prevent → Intervene → Stabilize → Rebuild → Thrive**.

## Included in this build
- Professional black/red responsive web experience with animated hero, cards, glow, hover and reduced-motion support.
- Supabase Auth signup/login, profile settings and password reset flow.
- Recovery assessment with saved results and automatic first recovery plan/tasks.
- 15-minute Urge Support with timer, guided steps, intensity/trigger capture and saved sessions.
- Recovery dashboard with live Supabase data, notifications and next actions.
- Progress/check-ins and recovery task tracking.
- Financial Rebuild with monthly figures and debt records.
- Accountability support contacts.
- Moderated community posts and safety reporting.
- Verified professional directory, provider application and appointment requests.
- Family Support, searchable Recovery Library, bookmarks and article pages.
- Notification center, privacy preferences, accountability contacts and Recovery Path AI support endpoint.
- Admin console for staff, provider verification, moderation queue and content CMS.
- Paystack server-side payment initialization and verification/webhook baseline.
- PWA installability plus Android/iOS/desktop distribution scaffolding.
- Security headers and environment-secret separation.

## Supabase setup
1. Create a Supabase project.
2. For a new project, run `supabase/schema.sql` in the SQL editor.
3. If you already ran the original schema, run `supabase/production-additions.sql` and then `supabase/feature-complete.sql` next.
4. Enable Email authentication.
5. Add the values from `.env.example` to `.env.local`.
6. Never expose `SUPABASE_SERVICE_ROLE_KEY` or `PAYSTACK_SECRET_KEY` to the browser/mobile client.

## Local development
```bash
npm install
npm run dev
```
Then open `http://localhost:3000`.

## Verification
```bash
npm run typecheck
npm run security:check
npm run build
```

## Paystack
Set the server-only Paystack secret and public key. The application initializes transactions on the server, stores a pending payment, verifies the reference server-side, and records the subscription. Configure the Paystack webhook to `/api/paystack/webhook` on your deployed domain.

## Email, AI, analytics
The environment file includes optional server-side slots for Resend, OpenAI and analytics/monitoring providers. Connect these only after the clinical/safety, privacy and consent policies are approved. Do not send sensitive recovery data to third-party services without a documented lawful basis, data-minimization plan and user-facing disclosure.

## Native platforms
- **Chrome/Chromebook:** use the PWA install flow.
- **Android/iPhone/iPad:** use Capacitor after the production web app is deployed; configure the native project and signing certificates on the appropriate build machine.
- **Windows/macOS/Linux:** package the deployed web experience with the selected desktop wrapper and sign each release.

This repository contains the source/configuration needed for those release builds; store-signed binaries are not bundled because they require your developer accounts, certificates and platform build environments.

## Safety and launch gate
Recovery Path is not a substitute for emergency care, diagnosis or individualized professional advice. Before public launch, have qualified local professionals review intervention content, assessment wording, crisis resources, professional verification, privacy/consent and financial guidance.

## Latest professional layer
The latest build adds premium onboarding, Recovery Momentum, a private care team, provider search and availability-aware booking, notification controls, personal data export/deletion request workflow, stronger trust messaging, responsive visual polish and additional safety/privacy copy.

Database migration order: `supabase/schema.sql` → `supabase/feature-complete.sql` → `supabase/professional-polish.sql`.
