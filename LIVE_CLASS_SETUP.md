# Smart Education — Live Class Setup

## 1. Supabase
Run `live-class-system.sql` once in Supabase SQL Editor.

## 2. Live video
The live classroom uses the Jitsi Meet IFrame API. The website does not upload or store the live video file. The browser connects to the live room directly.

## 3. Teacher
Teacher Profile → **🎥 Live Class** → fill in title/class/subject/chapter/start time/duration → **Create & Start Live Class**.

A unique `LC-XXXXXX` code and a browser link are generated. Use **Copy Live Link** to share it.

## 4. Student
Student Profile → **🎥 Live Class** → enter the Live Code. The student joins the live room in the browser.

## 5. Teacher controls
Teacher gets student list, star rating (0–5), mute mic/video, pin, kick and block. A blocked student is denied by the website on re-entry and the teacher can kick them from the current room.

## 6. Notes/PDF/teaching board
The Live Class has a Notes button and a local PDF Teaching Board. PDFs are opened locally in the browser and are not uploaded to Supabase. Pen/text/color annotations are drawn over the local PDF; the teacher can then share that browser tab/window through Jitsi Screen Share.

## Important
The browser cannot be given unrestricted control over another student's device screen. The teacher controls exposed here are meeting-level controls (mic/video, pin, kick, block, lobby/moderation where supported by the meeting provider).
