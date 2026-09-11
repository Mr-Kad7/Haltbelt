'use client';
import { supabase } from '../supabase';
export default function SignOutButton(){return <button className="btn btn-outline" onClick={async()=>{await supabase().auth.signOut(); location.href='/';}}>Sign out</button>}
