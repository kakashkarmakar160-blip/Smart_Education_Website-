Smart Education Marketplace - Student Class Interface Update

পরিবর্তন:
1. Student class view-তে PDF, Notes, Book, Recorded Class, Live Class ও Course আলাদা category box হিসেবে দেখানো হয়।
2. Category খুললে সংশ্লিষ্ট Resource card দেখা যায়।
3. Resource card-এ শিক্ষকের profile photo (profiles.teacher_dp_url; fallback avatar_url), শিক্ষকের নাম, Resource title ও type/description থাকে।
4. View বাটন শিক্ষক-প্রদত্ত URL নতুন ট্যাবে খোলে।
5. Download বাটন Resource-টি ডিভাইসে download করার চেষ্টা করে; এটি Supabase-এ নতুন কোনো file বা row save করে না। Cross-origin server download block করলে link নতুন tab-এ খোলে।
6. Student view-তে Class Edit, Publish, Resource Add/Edit/Delete controls দেখানো হয় না। এগুলো Teacher Manage Class view-তেই থাকে।

নোট: Live Supabase end-to-end test করা হয়নি। Resource download-এর ক্ষেত্রে external host CORS/download permission সীমাবদ্ধতা থাকতে পারে।
