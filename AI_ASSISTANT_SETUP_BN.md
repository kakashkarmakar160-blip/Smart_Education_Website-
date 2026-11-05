SMART EDUCATION AI — SETUP

১) Settings > AI Assistant & Personal Memory খুলুন।
২) Google AI Studio থেকে Gemini API Key তৈরি করে Key ঘরে পেস্ট করে Save API Key চাপুন।
৩) ওয়েবসাইটের যেকোনো পেজে নিচে থাকা ✦ AI Assistant বাটনে চাপ দিয়ে চ্যাট করুন।
৪) কথোপকথন এই ডিভাইসের এই ব্রাউজারের IndexedDB-তে সেভ হয়। API Key Local Storage-এ থাকে।
৫) Settings থেকে নিজের Memory-তে গুরুত্বপূর্ণ তথ্য যোগ, API Key মুছে ফেলা, অথবা সব AI Memory/Chat মুছে ফেলা যাবে।
৬) Memory অন্য মোবাইল/ব্রাউজারে সিঙ্ক হবে না। Browser data clear করলে Memory হারাতে পারে।

নিরাপত্তা:
- Gemini API Key browser-এ ব্যবহার করলে browser/devtools access থাকা ব্যক্তি key দেখতে পারে। ব্যক্তিগত/নিজস্ব ব্যবহারে ব্যবহার করুন; key usage limit/billing নজরে রাখুন।
- AI memory এবং AI chat Supabase-এ পাঠানো হয় না। Gemini-কে প্রশ্নের সঙ্গে প্রাসঙ্গিক local memory পাঠানো হয় উত্তর তৈরির জন্য; Gemini service সেই request পায়।
- বিদ্যমান ফলাফল/marksheet Supabase-এ যে নিয়মে আগে থেকে সংরক্ষিত হয় তা অপরিবর্তিত। AI memory নিজে সেগুলো database-এ লেখে না।
