import { NextResponse } from 'next/server';
import { supabaseAdmin } from '../../../../lib/supabase-admin';

const confirmationText = `Hello,

Thank you for signing up for HaltBet.
Please confirm your email address by clicking the button below:

Confirm My Email

If you did not create a HaltBet account, you can safely ignore this email.
For your security, please do not share your verification link with anyone.

Best regards,
The HaltBet Team`;

export async function POST(request: Request) {
  try {
    const body = await request.json() as { name?: string; email?: string; password?: string };
    const name = body.name?.trim();
    const email = body.email?.trim().toLowerCase();
    const password = body.password;

    if (!name || name.length < 2 || !email || !password || password.length < 8) {
      return NextResponse.json({ error: 'Please provide a name, valid email, and password of at least 8 characters.' }, { status: 400 });
    }

    const resendApiKey = process.env.RESEND_API_KEY;
    const resendFromEmail = process.env.RESEND_FROM_EMAIL;
    if (!resendApiKey || resendApiKey === 'YOUR_RESEND_API_KEY' || !resendFromEmail || resendFromEmail === 'YOUR_VERIFIED_EMAIL') {
      return NextResponse.json({ error: 'Email confirmation is not configured yet.' }, { status: 503 });
    }

    const admin = supabaseAdmin();
    const appUrl = process.env.NEXT_PUBLIC_APP_URL || new URL(request.url).origin;
    const { data: linkData, error: linkError } = await admin.auth.admin.generateLink({
      type: 'signup',
      email,
      password,
      options: { data: { name }, redirectTo: `${appUrl}/onboarding` },
    });

    if (linkError || !linkData.properties?.action_link) {
      return NextResponse.json({ error: linkError?.message || 'Unable to create the confirmation link.' }, { status: 500 });
    }

    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: resendFromEmail,
        to: [email],
        subject: 'Confirm your HaltBet email address',
        text: confirmationText,
        html: `<p>Hello,</p><p>Thank you for signing up for HaltBet.<br>Please confirm your email address by clicking the button below:</p><p><a href="${linkData.properties.action_link}" style="display:inline-block;background:#c62828;color:#ffffff;padding:12px 20px;text-decoration:none;border-radius:4px;font-weight:600;">Confirm My Email</a></p><p>If you did not create a HaltBet account, you can safely ignore this email.<br>For your security, please do not share your verification link with anyone.</p><p>Best regards,<br>The HaltBet Team</p>`,
      }),
    });

    if (!resendResponse.ok) {
      const resendError = await resendResponse.json().catch(() => null) as { message?: string } | null;
      return NextResponse.json({ error: resendError?.message || 'Unable to send the confirmation email.' }, { status: 502 });
    }

    return NextResponse.json({ ok: true });
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : 'Unable to create your account.' }, { status: 500 });
  }
}