# Smart Education — Notes System

এই ZIP-এ Notes system যোগ করা হয়েছে। বর্তমান Teacher Question, Exam, OMR, Practice ইত্যাদি files পরিবর্তন না করে শুধু নতুন Notes pages এবং profile buttons যোগ করা হয়েছে।

## 1) Supabase SQL
Supabase Dashboard → SQL Editor → `notes-system.sql`-এর পুরো SQL paste করে Run করুন।

এতে:
- `notes` table তৈরি হবে
- `notes-media` Storage bucket তৈরি হবে
- Notes-এর RLS policies তৈরি হবে

## 2) Teacher
Teacher Profile → **📚 Make Notes**

Teacher পারবেন:
- Notes Title / Class / Semester / Subject / Chapter / Teacher Name
- Bold, Italic, Underline, Heading
- Text colour
- Text background/highlight colour
- Alignment, lists, links
- Math/Science keyboard
- Shapes
- Image upload + crop
- Image resize/position through the editor
- Background watermark logo
- Preview
- Save & Publish
- Edit / Preview / Publish / Unpublish / Copy Code / Delete
- যত খুশি Notes তৈরি

## 3) Image limit
প্রতিটি uploaded image/logo **সর্বোচ্চ 350 KB** হতে হবে। App upload-এর আগে size check করে এবং প্রয়োজন হলে image compress করে। 350 KB-এর বেশি হলে upload হবে না।

## 4) Student
Student Profile → **📚 Notes** → Notes Code → Open Notes.

Student published Notes পড়তে পারবে এবং **Save as PDF** চাপলে PDF তার device-এ download হবে। PDF database-এ save হয় না।

## 5) PDF
PDF browser-side তৈরি হয়; database-এ PDF file রাখা হয় না।
