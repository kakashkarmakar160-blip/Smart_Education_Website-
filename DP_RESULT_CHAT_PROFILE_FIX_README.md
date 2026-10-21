Smart Education: Student DP in Teacher Results and Group Chat

Changes:
- Teacher Profile student result rows now fetch the student's saved DP from profiles via a narrow RPC, with compatibility fallbacks.
- Group chat message/member rows use the same RPC so the student's saved DP can appear beside their name.
- Added SQL function get_public_profile_cards() to edu-groups-setup.sql.

IMPORTANT: Run the updated edu-groups-setup.sql in Supabase SQL Editor so the RPC exists. This function exposes only profile name and avatar fields to signed-in users, not all profile columns.

Then upload the updated website files to GitHub Pages and hard-refresh/reopen the site. The actual Supabase policy/session must be tested on the live site.
