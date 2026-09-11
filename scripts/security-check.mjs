import fs from 'node:fs';
const env=fs.readFileSync('.env.example','utf8');
if(env.includes('sk_live_')) throw new Error('Do not put live Paystack secrets in .env.example');
const tracked=fs.existsSync('.gitignore')?fs.readFileSync('.gitignore','utf8'):'';
if(!tracked.includes('.env')) console.warn('Warning: .env is not listed in .gitignore');
console.log('Security baseline checks passed.');
