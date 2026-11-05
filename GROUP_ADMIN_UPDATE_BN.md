# Group Admin Update (বাংলা)

নতুন Group system চালু করতে Supabase → SQL Editor-এ `edu-groups-setup.sql` ফাইলের সম্পূর্ণ SQL আবার Run করুন। এটি পুরোনো Group বা Message মুছে দেয় না; শুধু প্রয়োজনীয় RLS policies আপডেট করে।

- Student এবং Teacher উভয়েই Settings থেকে Group তৈরি করতে পারবেন।
- Group creator-ই Admin।
- Admin যেকোনো authenticated user-এর Supabase User UUID দিয়ে Add Member করতে পারবেন।
- Admin সদস্য Remove করতে পারবেন।
- অন্য ব্যবহারকারী Group Code পেস্ট করে নিজে Join করতে পারবেন।
- Reset All Settings শুধু এই ব্রাউজারের Design/Theme/Language reset করে; Database-এর তথ্য মুছে না।
