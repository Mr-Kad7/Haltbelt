# Recovery Path — Final Professional Build

This package contains the completed application-layer professionalization requested for the current build: premium onboarding, Recovery Momentum, Urge Support, recovery planning, progress, financial rebuild, private care team, provider search and availability-aware appointments, community safety, content library/CMS, notifications, AI support routing, admin operations, privacy/data controls, accessibility/reduced-motion styling, PWA and cross-platform wrappers.

## Database migrations
Run in this order in the target Supabase project:
1. `supabase/schema.sql`
2. `supabase/feature-complete.sql`
3. `supabase/professional-polish.sql`

## External launch items intentionally not fabricated
The application still needs the owner's real credentials/accounts and professional/legal review for production: Supabase project values, Paystack keys/webhooks, email provider, AI key if enabled, hosting/domain, monitoring/analytics, qualified review of recovery/clinical content and crisis information, and native app signing/store accounts.

## Validation note
A full Next.js production build could not be executed in this sandbox because dependency installation timed out; the package is therefore shipped without `node_modules`. Static file/reference checks were completed, and the project retains its `npm run typecheck`, `npm run security:check`, `npm run build`, and `npm run check` commands for execution after dependencies are installed in the user's environment.
