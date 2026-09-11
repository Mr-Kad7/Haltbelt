import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const failures = [];
const warnings = [];
const textFiles = [];
function walk(dir){
  for(const name of fs.readdirSync(dir)){
    if(['node_modules','.next','.git'].includes(name)) continue;
    const full=path.join(dir,name), stat=fs.statSync(full);
    if(stat.isDirectory()) walk(full); else textFiles.push(full);
  }
}
walk(root);

for(const file of textFiles){
  const rel=path.relative(root,file);
  if(!/\.(tsx?|css|mjs|json|md|yml|yaml)$/.test(file)) continue;
  const s=fs.readFileSync(file,'utf8');
  if(/sk_live_[A-Za-z0-9]+|pk_live_[A-Za-z0-9]+/.test(s)) failures.push(`${rel}: live Paystack credential detected`);
  if(/-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----/.test(s)) failures.push(`${rel}: private key material detected`);
  if(/SUPABASE_SERVICE_ROLE_KEY\s*=\s*['"](?!YOUR_|$)/.test(s)) failures.push(`${rel}: possible service-role secret in source`);
}

const required=['.env.example','.gitignore','app/sitemap.ts','app/robots.ts','app/error.tsx','app/not-found.tsx','public/manifest.webmanifest','public/sw.js','supabase/schema.sql','scripts/security-check.mjs'];
for(const f of required) if(!fs.existsSync(path.join(root,f))) failures.push(`missing required file: ${f}`);

const gitignore=fs.readFileSync(path.join(root,'.gitignore'),'utf8');
for(const f of ['.env','.env.local','.next','node_modules']) if(!gitignore.includes(f)) failures.push(`.gitignore missing ${f}`);

const pkg=JSON.parse(fs.readFileSync(path.join(root,'package.json'),'utf8'));
for(const script of ['build','typecheck','security:check','check']) if(!pkg.scripts?.[script]) failures.push(`package.json missing script: ${script}`);

const manifest=JSON.parse(fs.readFileSync(path.join(root,'public/manifest.webmanifest'),'utf8'));
for(const icon of manifest.icons ?? []) if(!fs.existsSync(path.join(root,'public',icon.src.replace(/^\//,'')))) failures.push(`manifest icon missing: ${icon.src}`);

if(!process.env.NEXT_PUBLIC_APP_URL) warnings.push('NEXT_PUBLIC_APP_URL is not set in this audit environment; sitemap/robots use localhost fallback.');

if(failures.length){ console.error('PRODUCTION AUDIT FAILED'); failures.forEach(x=>console.error(' - '+x)); process.exit(1); }
console.log('PRODUCTION AUDIT PASSED');
console.log(`Checked ${textFiles.length} files; ${warnings.length} non-blocking warning(s).`);
warnings.forEach(x=>console.log(' - '+x));
