# Cross-device Teacher Paper update

This ZIP keeps the existing UI and adds cloud storage for published Teacher Papers.

## One-time Supabase setup
1. Open Supabase -> SQL Editor.
2. Open/copy `SUPABASE_TEACHER_PAPERS_SETUP.sql`.
3. Run the complete SQL once.
4. Make sure Authentication -> Sign In / Providers -> Anonymous Sign-Ins is ON.

## How it works
- Teacher creates questions and publishes a code.
- The paper is saved to `public.teacher_papers` in Supabase.
- A student/friend on another phone enters the same code.
- `student-paper.html` first checks Supabase, then falls back to the old localStorage paper for backward compatibility.

The old localStorage copy is retained so the existing interface is not disrupted.
