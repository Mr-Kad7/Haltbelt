# Platform Distribution

Recovery Path is delivered as a responsive Next.js web app and installable PWA. Native packaging is intentionally kept separate from secrets and production credentials.

## Web / Chrome / Chromebook
Deploy the Next.js app to a Node-capable host. Users can install the PWA from a supported Chromium browser.

## Android / iOS
Capacitor dependencies and configuration are included. On a build machine:
1. Deploy the web app.
2. Configure the Capacitor native project for the deployed app.
3. Add Android/iOS platforms with the Capacitor CLI.
4. Sync web assets/plugins.
5. Open Android Studio or Xcode.
6. Configure application identifiers, signing, icons, privacy declarations and store metadata.
7. Build and sign release artifacts.

Do not put Supabase service-role or Paystack secret keys in the native bundle.

## Windows / macOS / Linux
Use the deployed web application as the source for the selected desktop wrapper (Electron/Tauri or an equivalent approved framework), then configure application IDs, icons, auto-update strategy and platform signing. The repository includes desktop distribution guidance but does not claim to contain signed store installers.
