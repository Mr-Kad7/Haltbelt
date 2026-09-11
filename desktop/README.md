# Recovery Path Desktop

The desktop wrapper loads the deployed Recovery Path web application in an isolated Electron window with context isolation and no Node integration in the renderer.

Set `RECOVERY_PATH_APP_URL` to the deployed HTTPS application before packaging. Use a real certificate/signing identity for Windows, macOS and Linux releases. Never embed Supabase service-role or Paystack secret keys in the desktop package.
