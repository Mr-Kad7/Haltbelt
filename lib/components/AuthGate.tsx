'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { supabase } from '../supabase';

export default function AuthGate({ children }: { children: React.ReactNode }) {
  const [ready, setReady] = useState(false);
  const [signedIn, setSignedIn] = useState(false);
  useEffect(() => {
    let mounted = true;
    const s = supabase();
    s.auth.getSession().then(({ data }: { data: any }) => { if (mounted) { setSignedIn(!!data.session); setReady(true); } });
    const { data: listener } = s.auth.onAuthStateChange((_e: any, session: any) => { if (mounted) { setSignedIn(!!session); setReady(true); } });
    return () => { mounted = false; listener.subscription.unsubscribe(); };
  }, []);
  if (!ready) return <main className="container page"><div className="card loading-card">Loading your secure recovery space…</div></main>;
  if (!signedIn) return <main className="container page"><div className="card auth-card"><span className="pill">PRIVATE AREA</span><h1>Sign in to continue.</h1><p className="muted">Your recovery information stays connected to your account.</p><div className="hero-actions"><Link className="btn btn-red" href="/login">Sign in</Link><Link className="btn btn-outline" href="/signup">Create account</Link></div></div></main>;
  return <>{children}</>;
}
