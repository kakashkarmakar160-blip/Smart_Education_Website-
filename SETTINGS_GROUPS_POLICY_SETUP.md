SMART EDUCATION UPDATE — SETTINGS, POLICY, GROUPS, NOTICE LINK & DP

Included in this ZIP:
- settings.html: account DP upload (300 KB maximum), theme/language preference and links to Policy/Groups.
- policy.html: student, teacher, photo, notice-link, live-class and privacy rules.
- groups.html: teacher group creation with unique code/logo; students can join multiple groups by code; teacher can change each group logo.
- edu-groups-setup.sql: required Supabase schema and RLS policies for groups and DP columns.
- The previous Notes/Notice link and result-list DP changes are preserved from the preceding build.

SETUP BEFORE TESTING CLOUD FEATURES
1. Open Supabase Dashboard → SQL Editor.
2. Paste and run edu-groups-setup.sql.
3. Deploy all website files from this ZIP together (do not upload only individual pages).
4. Sign in with the existing Smart Education account. Open Settings and save the DP; open Groups to create/join groups.
5. Create with Link currently stores the URL in the existing Notes record; ensure the existing notes-system.sql setup and policies are installed.

Notes:
- Cloud features require an authenticated Supabase user and suitable existing Supabase RLS policies.
- Group creation checks the stored profile role; if the Teacher account's profiles.role is not set to teacher, correct that value in the profile.
- The group directory select policy allows authenticated users to look up codes. Share codes only with intended students.
- This update does not replace or delete existing exam, practice, OMR, teacher paper, or calculator files.
