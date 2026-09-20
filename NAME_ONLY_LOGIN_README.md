# Smart Education — Name-only Entry

This version removes Email, Google, and Phone OTP login from the website UI.

## User flow
1. Open the website.
2. `Enter Your Name` screen appears.
3. Enter a name and press `Continue`.
4. Supabase creates an anonymous user with a unique User ID and stores the entered name in user metadata/profile.
5. The user enters the normal Smart Education home interface.

## Supabase setting required
In Supabase Dashboard go to:
`Authentication → Sign In / Providers → Anonymous Sign-Ins`
and turn it **ON**, then save.

## Important
The entered name is a display name. Supabase generates the actual unique User ID (UUID). Two people can have the same name, so the name is not used as the database primary key. Anonymous users cannot recover the same account after signing out, clearing browser data, or switching devices unless a permanent login method is linked later.

For public production sites, Supabase recommends CAPTCHA/Cloudflare Turnstile and appropriate RLS policies for anonymous sign-ins.
