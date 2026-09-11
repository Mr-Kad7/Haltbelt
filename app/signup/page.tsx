'use client';
import { useState } from 'react';
import Link from 'next/link';
import { supabase } from '../../lib/supabase';
export default function Page(){
 const [name,setName]=useState(''),[email,setEmail]=useState(''),[password,setPassword]=useState(''),[busy,setBusy]=useState(false),[message,setMessage]=useState('');
 async function submit(e:React.FormEvent){e.preventDefault();setBusy(true);setMessage('');const {data,error}=await supabase().auth.signUp({email,password,options:{data:{name}}});setBusy(false);if(error){setMessage(error.message);return;} if(data.session){location.href='/onboarding';} else setMessage('Account created. Check your email to confirm your account, then sign in.');}
 return <main className="container page narrow"><div className="eyebrow"><span/> PRIVATE RECOVERY SPACE</div><h1>Create your <span className="red">account.</span></h1><p className="muted">Start with the tools you need today. You stay in control of what you share.</p><form className="card form-card" onSubmit={submit}><label className="label">Name<input required minLength={2} className="input" value={name} onChange={e=>setName(e.target.value)} /></label><label className="label">Email<input required type="email" className="input" value={email} onChange={e=>setEmail(e.target.value)} /></label><label className="label">Password<input required minLength={8} type="password" className="input" value={password} onChange={e=>setPassword(e.target.value)} /></label><button disabled={busy} className="btn btn-red full">{busy?'Creating…':'Create account'}</button>{message&&<p className="notice">{message}</p>}<p className="muted small">By continuing you agree to our <Link href="/terms">Terms</Link> and <Link href="/privacy">Privacy Policy</Link>.</p></form></main>
}
