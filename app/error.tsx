'use client';
import { useEffect } from 'react';
import Link from 'next/link';
export default function Error({ error, reset }: { error: Error & { digest?: string }; reset: () => void }){
  useEffect(()=>{ console.error(error); },[error]);
  return <main className="container page narrow-wide"><div className="card result-card"><span className="pill">TEMPORARY ERROR</span><h1>Something went wrong.</h1><p className="muted">Your information has not been intentionally changed by this screen. Try again, or return to a safe starting point.</p><div className="hero-actions"><button className="btn btn-red" onClick={()=>reset()}>Try again</button><Link className="btn btn-outline" href="/">Return home</Link></div></div></main>
}
