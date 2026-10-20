# Smart Education — Groups, Chat, DP and Link Codes

1. Supabase Dashboard → SQL Editor → New query.
2. Open `edu-groups-setup.sql`, copy the entire file, paste into SQL Editor and Run.
3. Publish the complete website folder to GitHub Pages (keep existing paths).
4. Teacher: Teacher Profile → Groups & Chat → Create Group. Share its code.
5. Student: Student Profile → Open Group → enter code → Join Group → Open Chat.
6. Teacher: Teacher Profile → Create with Link → title + https URL → Publish & Generate Code.
7. Student: Student Profile → Open Link → enter the Link Code.
8. Settings → choose Student DP/Teacher DP, select a JPG/PNG/WebP image up to 300 KB, preview and Save DP.

## Important
- Run the SQL before testing the new features.
- The browser uses the project's existing Supabase session. Users need to be signed in for cloud group/chat/link data.
- Teacher role must be saved as a role containing `teacher` in `profiles.role` or `localStorage.smartEduRole`.
- The chat refreshes messages every 5 seconds; it does not require a realtime publication.
- Admin add-member requires the target user's Supabase Auth UUID. Student can join by code, leave self, and cannot manage other members or rename/relogo a group.
- Do not replace existing question creator, OMR, practice, calculator, exam, or results files with unrelated versions.
