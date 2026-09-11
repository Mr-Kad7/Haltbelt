# Android distribution

The web app can be packaged as an Android application with Capacitor.

## Build on a machine with Android Studio
1. Install Node.js and Android Studio.
2. From the project root run:
   `npm install`
3. Add Capacitor:
   `npm install @capacitor/core @capacitor/cli @capacitor/android`
4. Initialize if needed:
   `npx cap init "Recovery Path" "com.recoverypath.app" --web-dir .next`
5. Add Android:
   `npx cap add android`
6. Build Next.js:
   `npm run build`
7. Sync:
   `npx cap sync android`
8. Open:
   `npx cap open android`
9. Build/sign the release in Android Studio.

A Google Play developer account and signed release are required for Play Store publication.
