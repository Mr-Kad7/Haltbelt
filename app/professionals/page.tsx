'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { supabase } from '../../lib/supabase';

type Professional = {
  id: string;
  name?: string;
  specialization?: string;
  profession?: string;
  bio?: string;
  hourly_rate?: number;
};

export default function Page() {
  const [professionals, setProfessionals] = useState<Professional[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState('');
  const [draftQuery, setDraftQuery] = useState('');
  const [query, setQuery] = useState('');
  const [profession, setProfession] = useState('all');

  useEffect(() => {
    supabase()
      .rpc('get_public_professionals')
      .then(({ data, error }: { data: Professional[] | null; error: { message: string } | null }) => {
        if (error) setLoadError('Professional directory could not be loaded. Please try again.');
        setProfessionals(data || []);
        setLoading(false);
      });
  }, []);

  const filtered = useMemo(() => professionals.filter((professional) => {
    const text = `${professional.name} ${professional.specialization} ${professional.profession} ${professional.bio}`.toLowerCase();
    return text.includes(query.trim().toLowerCase())
      && (profession === 'all' || professional.profession === profession);
  }), [professionals, query, profession]);

  function submitSearch(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setQuery(draftQuery);
  }

  const hasSearch = Boolean(query.trim()) || profession !== 'all';

  return (
    <main className="container page">
      <div className="eyebrow"><span /> PROFESSIONAL SUPPORT</div>
      <h1>Qualified support, <span className="red">when you're ready.</span></h1>
      <p className="muted">Explore verified providers. Availability and clinical suitability should always be confirmed before an appointment.</p>

      <form className="directory-tools" onSubmit={submitSearch} role="search">
        <div className="directory-search">
          <input
            className="input"
            aria-label="Search professional support"
            placeholder="Search name, specialty or support type..."
            value={draftQuery}
            onChange={(event) => setDraftQuery(event.target.value)}
          />
          <button className="btn btn-red" type="submit">Search</button>
        </div>
        <select className="input" aria-label="Filter by support type" value={profession} onChange={(event) => setProfession(event.target.value)}>
          <option value="all">All support types</option>
          <option value="therapist">Therapist</option>
          <option value="counselor">Counsellor</option>
          <option value="coach">Recovery coach</option>
          <option value="financial_advisor">Financial advisor</option>
        </select>
      </form>

      {loading ? <div className="card">Loading verified professionals...</div> : loadError ? (
        <div className="card empty-state">
          <h2>Directory unavailable</h2>
          <p className="muted">{loadError}</p>
        </div>
      ) : filtered.length === 0 ? (
        <div className="card empty-state">
          <h2>{hasSearch ? 'No matching verified professionals.' : 'Professional directory is being prepared.'}</h2>
          <p className="muted">{hasSearch ? 'Try a different name, specialty or support type.' : 'Providers will appear after verification.'}</p>
          <Link className="btn btn-outline" href="/crisis">Need immediate help? -&gt;</Link>
        </div>
      ) : (
        <>
          <p className="muted search-summary" aria-live="polite">
            {query.trim() ? `${filtered.length} professional${filtered.length === 1 ? '' : 's'} found for "${query.trim()}".` : `${filtered.length} verified professional${filtered.length === 1 ? '' : 's'} available.`}
          </p>
          <div className="grid grid3">
            {filtered.map((professional) => (
              <article className="card pro-card professional-card" key={professional.id}>
                <div className="pro-avatar">{professional.name?.slice(0, 1) || 'P'}</div>
                <div className="pro-head"><span className="pill">VERIFIED</span><span className="pro-type">{String(professional.profession || 'support').replaceAll('_', ' ')}</span></div>
                <h2>{professional.name}</h2>
                <b>{professional.specialization}</b>
                <p className="muted">{professional.bio || 'Professional support profile.'}</p>
                <div className="pro-meta"><span>Verification completed</span><strong>GH₵ {Number(professional.hourly_rate || 0).toLocaleString()}/hr</strong></div>
                <Link className="btn btn-red" href={`/appointments?professional=${professional.id}`}>View availability -&gt;</Link>
              </article>
            ))}
          </div>
        </>
      )}
    </main>
  );
}
