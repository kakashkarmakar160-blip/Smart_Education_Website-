Smart Education profile photo, settings, policy and notes image placement

1. Supabase SQL Editor-এ PROFILE_SETTINGS_SETUP.sql পুরোটা একবার Run করুন।
2. GitHub Pages-এ এই ZIP-এর সব ফাইল update করুন।
3. Student Profile / Teacher Profile-এ বড় DP-তে tap করে ছবি নির্বাচন করুন। ছবি compress করে account preferences-এ save হবে।
4. Settings / Permissions থেকে preferences পরিবর্তন করুন। Website Policy button-এ site rules থাকবে।
5. Teacher Notes editor-এ Insert > Pictures থেকে ছবি যোগ করুন। ছবিটিকে আঙুল/মাউস দিয়ে ধরে drag করে notes canvas-এর মধ্যে পছন্দের জায়গায় বসান।

Note: ছবি cloud-এ রাখতে `user_preferences` table তৈরি হওয়া জরুরি। SQL RLS-এর কারণে প্রত্যেকে নিজের row-ই update করতে পারে; authenticated users profile photos read করতে পারে। Permissions page UI preferences সংরক্ষণ করে; camera/mic/screen-share-এর system-level permission Android/browser থেকেই দিতে হবে।
