# Recovery Path — Production Readiness Pass

## Completed in this pass
- Global metadata, viewport/theme metadata and PWA manifest integration.
- Accessible skip link, visible keyboard focus, mobile navigation semantics and reduced-motion support.
- Global loading and error boundaries plus a branded 404 page.
- Public sitemap and robots rules; private dashboard/admin/API areas are excluded from indexing.
- Production security baseline audit for source-level secret leakage and required files.
- `.gitignore` verification for environment files and build artifacts.
- Final release documentation and explicit separation between code-complete work and account/store/legal requirements.

## Verification
The repository was inspected for required routes/assets/configuration and the ZIP was integrity-tested. A full `next build`/TypeScript build could not be executed in this environment because dependency installation timed out; run `npm install`, then `npm run check` and `npm run build` on the target development machine before deployment.

## Still requires real-world attention
- Real Supabase, Paystack, Resend and optional OpenAI credentials.
- Production hosting/domain and HTTPS.
- Clinical, safeguarding, privacy and legal review of recovery content and crisis pathways.
- Payment provider verification and live webhook configuration.
- Native app signing, store developer accounts, store review and release certificates.
- Production monitoring/backup configuration.
