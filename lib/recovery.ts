export const formatGhs=(n:number)=>`GH₵ ${Number(n||0).toLocaleString(undefined,{minimumFractionDigits:2,maximumFractionDigits:2})}`;
export function calculateStreak(rows:{created_at:string;outcome?:string}[]){const days=new Set(rows.filter(r=>r.outcome!=='lapsed').map(r=>new Date(r.created_at).toISOString().slice(0,10)));let d=new Date();let streak=0;while(days.has(d.toISOString().slice(0,10))){streak++;d.setDate(d.getDate()-1)}return streak;}
export function slugify(v:string){return v.toLowerCase().trim().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'')}
