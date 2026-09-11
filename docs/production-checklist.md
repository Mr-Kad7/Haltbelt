# Recovery Path Production Checklist

## Code / QA
- [x] Responsive layouts and mobile navigation
- [x] Accessibility baseline and reduced-motion support
- [x] Loading, error and 404 states
- [x] Metadata, sitemap and robots rules
- [x] PWA manifest/service worker assets
- [x] Source-level secret scan
- [ ] Run `npm install` on target machine
- [ ] Run `npm run check`
- [ ] Run `npm run build`
- [ ] Browser/device acceptance testing

## Security
- [x] Environment files ignored
- [x] Server-only secret variables documented
- [x] Security headers baseline
- [x] Supabase RLS/schema included
- [ ] Review RLS against final production roles
- [ ] Add production rate limiting/abuse controls at the hosting edge
- [ ] Configure monitoring and alerting

## Product / Safety
- [x] Recovery, urge-support, financial, community and professional pathways represented
- [x] AI safety disclaimer and crisis handoff language
- [ ] Qualified professional review of clinical/safety content
- [ ] Legal/privacy terms finalized
- [ ] Verify all local crisis/support information before launch

## Release
- [ ] Configure real credentials
- [ ] Configure domain/HTTPS
- [ ] Configure Paystack live verification/webhook
- [ ] Configure email provider
- [ ] Generate signed Android/iOS/desktop builds
- [ ] Store submission/review
