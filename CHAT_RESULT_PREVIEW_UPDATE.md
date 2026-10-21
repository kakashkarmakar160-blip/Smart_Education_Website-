Smart Education update

- Group Chat includes an explicit “Open Teacher Question Paper” button.
- Teacher result Preview now uses the correct answer-list element and displays a student result summary (DP, grade, obtained/total marks, percentage, trophy) above the answer review.
- Student DP lookup uses get_public_profile_cards RPC first, then profiles and user_preferences fallbacks.

Deployment: replace the corresponding files in the GitHub Pages repository. If the RPC is not installed or profile RLS prevents reads, run the relevant edu-groups-setup.sql from this ZIP or inspect the Supabase error. Live backend behavior must be tested on the deployed site.
