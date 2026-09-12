import type { Metadata, Viewport } from 'next';
import './globals.css';
import PwaRegister from './pwa-register';
import SiteHeader from '../lib/components/SiteHeader';
import Link from 'next/link';

export const metadata: Metadata = {
  title: { default: 'Haltbet', template: '%s | Haltbet' },
  description: 'A private, practical recovery platform for gambling urges, rebuilding finances, finding support, and building a life beyond gambling.',
  applicationName: 'Haltbet',
  manifest: '/manifest.webmanifest',
  icons: { icon: '/images/Haltbet.png', apple: '/images/Haltbet.png' },
  robots: { index: true, follow: true },
  openGraph: { title: 'Haltbet', description: 'Private, practical support for taking back control from gambling.', type: 'website' },
};

export const viewport: Viewport = {
  themeColor: '#050505',
  colorScheme: 'dark',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body>
    <a className="skip-link" href="#main-content">Skip to content</a>
    <PwaRegister />
    <SiteHeader />
    <div id="main-content">{children}</div>
    <footer>
      <div className="container footer-inner">
        <div><Link href="/" className="brand"><img className="brand-logo" src="/site-logo.svg" alt="Haltbet" /></Link><p className="muted"> No Judgement</p></div>
        <div className="footer-links">
          <div><b>Recovery</b><Link href="/assessment">Assessment</Link><Link href="/urge">Urge Support</Link><Link href="/progress">Progress</Link><Link href="/rebuild">Financial Rebuild</Link><Link href="/care-team">Care Team</Link></div>
          <div><b>Support</b><Link href="/professionals">Professionals</Link><Link href="/community">Community</Link><Link href="/family">Family Support</Link><Link href="/crisis">Crisis Help</Link></div>
          <div><b>Company</b><Link href="/about">About</Link><Link href="/privacy">Privacy</Link><Link href="/terms">Terms</Link><Link href="/downloads">Apps</Link></div>
        </div>
      </div>
      <div className="container footer-bottom">© {new Date().getFullYear()} Haltbet. Recovery tools are educational and do not replace professional care.</div>
    </footer>
  </body></html>;
}
