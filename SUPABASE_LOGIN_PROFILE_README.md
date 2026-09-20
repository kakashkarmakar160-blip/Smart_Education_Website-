# Smart Education — Supabase Login + Profile
This version preserves the existing UI and adds Supabase Email/Password authentication and profile storage.

### Added
- `auth.html`: Login + Sign Up using Supabase Auth.
- `student-save.html`: saves Student profile to `public.profiles`.
- `teacher-save.html`: saves Teacher profile to `public.profiles`.
- `student-profile.html`: loads the signed-in Student profile from Supabase.
- `teacher-profile.html`: loads the signed-in Teacher profile from Supabase.
- `profile.html`: shows login status and Logout.
- `supabase-config.js`: Supabase client and profile helpers.

### Existing database requirement
The `public.profiles` table and RLS policies must already exist as configured in Supabase.
The current stage intentionally keeps question/exam/result data on the existing localStorage/JSON system. The next stage will migrate those to Supabase.

### Security
Only the Publishable key belongs in the browser. Never put an `sb_secret_...` key in GitHub or HTML.


## Email OTP Login
The authentication page now uses Supabase Email OTP instead of Email/Password:
1. User enters Email/Gmail.
2. Supabase sends a one-time verification code.
3. User enters the OTP in `auth.html`.
4. `supabaseClient.auth.verifyOtp({ email, token, type: "email" })` verifies it.
5. The existing `profiles` table is reused for Student/Teacher/Computer role data.

### Supabase Dashboard
Make sure Email authentication and passwordless/Email OTP are enabled in the Supabase project. Configure the email provider/template as required by the project.
