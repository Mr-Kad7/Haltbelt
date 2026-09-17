import Link from "next/link";

const features = [
  ["01", "Urge Support", "A focused 15-minute pathway to help you get through the moment without gambling.", "/urge"],
  ["02", "Recovery Plan", "Turn your goals into practical daily actions, milestones and routines.", "/assessment"],
  ["03", "Financial Rebuild", "Understand the damage, organize debt and build a realistic recovery plan.", "/rebuild"],
  ["04", "Human Support", "Connect with professionals and a community built around dignity, privacy and progress.", "/professionals"],
];

const steps = [
  ["Assess", "Understand your patterns, triggers and current recovery needs."],
  ["Intervene", "Use Urge Support when the pressure to gamble is highest."],
  ["Rebuild", "Work on money, relationships, routines and personal goals."],
  ["Thrive", "Track progress and build a life where gambling is no longer in control."],
];

export default function Home() {
  return (
    <main>
      <section className="hero container">
        <div className="hero-copy">
          <div className="eyebrow"><span /></div>
          <h1>We<span className="#8B0000">&nbsp;build</span><br />New beginnings.</h1>
          <p className="hero-lead">
           Haltbet is a support system for those ready to move beyond gambling. We provide practical pathways to restore financial stability, rebuild relationships, reclaim personal agency, and design a future defined by purpose, prosperity, and freedom.
          </p>
          <div className="hero-actions">
            <Link className="btn btn-red btn-large pulse-btn" href="/urge">I&apos;M HAVING AN URGE <span>↗</span></Link>
            <Link className="btn btn-outline btn-large" href="/assessment">START MY RECOVERY</Link>
          </div>
          <div className="trust-row">
            <div className="avatar-stack"><i /><i /><i /><i /></div>
            <span><strong>There is a life beyond the odds.</strong><br /><small>Recovery is the new identity.</small></span>
          </div>
        </div>

        <div className="hero-visual" aria-label="Haltbet support experience">
           <div className="hero-glow" />
          <img src="/images/Recovery.jpeg" alt="Haltbet recovery support experience" />
          <div className="urge-float glass-card">
            <div>
              <span className="tiny-label">RIGHT NOW</span>
              <strong>15-MINUTE<br /><em>URGE SUPPORT</em></strong>
              <small>One minute at a time.</small>
            </div>
            <div className="timer-ring"><b>15:00</b></div>
          </div>
        </div>
      </section>

      <section className="feature-strip container">
        {features.map(([num, title, body, href]) => (
          <Link href={href} className="feature-card" key={num}>
            <span className="feature-number">{num}</span>
            <span className="feature-icon">{num === "01" ? "♡" : num === "02" ? "◈" : num === "03" ? "$" : "◎"}</span>
            <h3>{title}</h3>
            <p>{body}</p>
            <span className="feature-arrow">Explore →</span>
          </Link>
        ))}
      </section>

      <section className="stats container">
        <div><strong>15 min</strong><span>Urge pathway</span></div>
        <div><strong>5 steps</strong><span>Recovery framework</span></div>
        <div><strong>24/7</strong><span>Self-help access</span></div>
        <div><strong>Private</strong><span>By design</span></div>
      </section>

      <section className="section container">
        <div className="section-heading centered">
          <div className="eyebrow"><span /> A NEW LIFE.</div>
          <h2>How it <span className="red">works.</span></h2>
          <p>Recovery is not a moment of decision. It is the deliberate practice of better choices (made quietly, consistently, and without compromise) until they transform your direction, redefine your identity, and reshape your future.</p>
        </div>
        <div className="steps-grid">
          {steps.map(([title, body], index) => (
            <div className="step-card" key={title}>
              <div className="step-image"><img src={`/images/${["Image2.jpeg","Image3.jpeg","Image4.jpeg","Image5.jpeg"][index]}`} alt="" /></div>
              <div className="step-badge">0{index + 1}</div>
              <h3>{title}</h3>
              <p>{body}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="recovery-banner container">
        <div className="banner-image"><img src="/images/image8.jpeg" alt="A person looking toward a new path" /></div>
        <div className="banner-copy">
          <div className="eyebrow"><span /> YOU ARE NOT ALONE</div>
          <h2>Your next chapter can start <span className="red">today.</span></h2>
          <p>Whether you are dealing with urges, debt, damaged relationships or simply feeling stuck, Haltbet gives you a structured place to begin again.</p>
          <div className="check-list"><span>✓</span> Private and judgment-free <span>✓</span> Practical recovery tools <span>✓</span> Built around real life</div>
          <Link className="btn btn-outline" href="/about">OUR MISSION →</Link>
        </div>
      </section>

      <section className="trust-section container">
        <div className="trust-copy">
          <div className="eyebrow"><span /> BUILT AROUND TRUST</div>
          <h2>Calm when it matters. <span className="red">Clear when it counts.</span></h2>
          <p>Haltbet combines practical self-help tools, human-support pathways, financial rebuilding and private progress tracking in one place. Our content and clinical pathways are reviewed by qualified professionals.</p>
          <div className="trust-points"><span>01 · Privacy-first design</span><span>02 · Human support pathways</span><span>03 · Recovery-focused UX</span><span>04 · Safety escalation</span></div>
        </div>
        <div className="trust-visual"><img src="/images/hero-person.png" alt="Person taking a reflective pause during recovery"/><div className="trust-card"><b>YOUR NEXT SAFE STEP</b><span>Transform your direction.</span></div></div>
      </section>

      <section className="cta container">
        <div>
          <div className="eyebrow"><span /> ONE STEP IS ENOUGH</div>
          <h2>Ready to take back <span className="red">control?</span></h2>
          <p>You do not have to solve everything tonight. Start with the next right step.</p>
        </div>
        <div className="cta-actions">
          <Link className="btn btn-red btn-large" href="/signup">CREATE FREE ACCOUNT →</Link>
          <Link href="/login" className="login-link">Already have an account? <span>Log in</span></Link>
        </div>
      </section>

      <section className="safety-note container">
        <strong>Need immediate help?</strong>
        <span>If you are in crisis or feel unsafe, use our crisis resources for urgent support.</span>
        <Link href="/crisis">CRISIS HELP →</Link>
      </section>
    </main>
  );
}
