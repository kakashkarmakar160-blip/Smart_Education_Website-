# Smart Education — Supabase Connection

This version keeps the existing HTML/CSS/JS interface unchanged and adds the Supabase browser client to the HTML pages.

## Supabase project
Project URL: https://adneuympnwijfrudycwu.supabase.co

## What was added
- `supabase-config.js` creates `window.supabaseClient`.
- Supabase JS v2 is loaded from the official jsDelivr CDN.
- The existing pages load the connection automatically.

## Important
- The key in `supabase-config.js` is a Publishable key and is intended for browser use with RLS enabled.
- Never add an `sb_secret_...` key to this project or GitHub.
- Existing application data still uses the project's current localStorage/JSON logic. This ZIP only establishes the Supabase client connection; Teacher published papers are now stored in `public.teacher_papers` so a paper code can work across different phones. The included SQL setup file creates the table and RLS policies. Other question/exam/result data still uses the existing localStorage/JSON logic.
