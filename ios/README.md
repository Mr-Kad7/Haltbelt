# Apple iPhone/iPad distribution

Use Capacitor + Xcode.

1. On macOS, install Xcode.
2. Install Node.js.
3. Run:
   `npm install @capacitor/core @capacitor/cli @capacitor/ios`
4. Initialize if needed:
   `npx cap init "Recovery Path" "com.recoverypath.app" --web-dir .next`
5. Add iOS:
   `npx cap add ios`
6. Build:
   `npm run build`
7. Sync:
   `npx cap sync ios`
8. Open:
   `npx cap open ios`
9. Configure signing/team in Xcode and archive the app.

An Apple Developer account is required for App Store distribution.
