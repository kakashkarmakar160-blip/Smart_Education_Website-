Smart Education — DP and Group Chat UI fixes

Changes in this build:
- Student DP selection now reloads the student_dp_url field separately from teacher_dp_url. Saving requests the updated profile row and updates the preview/status only after Supabase confirms the save.
- Student Profile avatar uses student_dp_url; Teacher Profile avatar uses teacher_dp_url.
- Group chat member list and messages now try profile names first, then user_preferences.display_name, then message sender name, and finally a role label (rather than displaying a UUID).
- Group chat shows role-specific shortcuts: Teacher gets Live Class, Create Notes, Create Link, Question Paper; Student gets Live Class, Notes, Open Link, Question Paper.
- The small Home button on the home page now displays a dark graduation-cap icon.

Important: these changes were syntax-checked locally. Actual cloud saving and realtime/chat behavior still require testing on the deployed website with the Supabase project and its RLS policies.
