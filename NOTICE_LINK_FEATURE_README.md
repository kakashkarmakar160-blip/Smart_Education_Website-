Smart Education — Notes/Notice Link Update

Changes:
- Teacher Notes toolbar now includes “Create with link”.
- Enter an http/https notice URL and press “Publish Link” to save it as a published notice and receive a Notes/Notice code.
- Student Notes accepts the generated code and redirects to the published URL.
- Live Classroom has a “Notice by Code” input. Teachers can open a notice link and broadcast it to students in the same live room; students see an “Open Notice Link” link.
- Opening a link notice through the Live Notes code also handles the link instead of trying to render it as lesson text.
- Teacher Profile result rows show a circular student DP beside each student name when a photo is available in `profiles` or `user_preferences`; initials are shown as a fallback.
- Notes editor paper/shadow styling was polished without replacing the existing editor tools.

Important:
- Notice links are stored inside the existing `notes.content_html` field using the marker `SMARTEDU_NOTICE_LINK::https://...`, so this update does not require a new SQL table.
- For student DPs, a photo URL/data URL must exist in a `profiles` photo field or in `user_preferences.avatar_data_url`. If the photo preferences table is not installed or no photo is saved, initials are shown instead.
- Test with the existing Supabase policies and a published Notes record before deploying to the live site.
