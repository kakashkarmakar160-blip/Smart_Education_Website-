# Smart Education Website

A clean, responsive, static educational question-bank and exam website.

## Current content
- Class 5–8: Bangla, English, Mathematics, Science
- Class 12: 3rd Semester Commercial Law
- Multiple school/model-question cards
- MCQ, fill-in-the-blanks, true/false, short-answer and numerical questions
- Solution button for questions that have worked solutions
- Exam interface, result page and solution panel
- Search by class/subject/school
- Bengali/English language toggle
- Light/dark mode
- No database or paid service is required for the current static version

## Run
Open `frontend/index.html` in a browser.

For GitHub Pages / Netlify / Vercel static deployment, upload the whole folder and use `frontend` as the publish directory if the host asks for one.

## Important
All question content is sample content created for the initial website structure. Replace or expand the JSON files in `data/` whenever you add your own school/model-question sets.


## Recent UI update
- Home now has functional Student / Teacher / Computer mode buttons.
- Role images are replaceable from `data/roles.json` and `assets/roles/`.
- Model Question Set cards use **Practice** instead of Start Exam.
- MCQ practice immediately marks a selected wrong answer red and the correct answer green; correct answers are shown after a wrong selection.
- Math questions retain step-by-step Solution buttons.
- Practice results use a dedicated result dashboard.


## Teacher / Student workflow
- Home page has three role cards: Student, Teacher, Computer.
- Role images are in `assets/roles/`. Replace `student.svg`, `teacher.svg`, or `computer.svg` with your own image while keeping the same filename.
- Teacher → Create Question → Save Question → Question Paper Preview → Publish.
- Teacher can create MCQ, Long Question, Fill in the Blanks, Paragraph Writing, True/False and Match the Following.
- Teacher Publish creates a student access password. In this static demo the published paper is stored in browser `localStorage`.
- Student → Teacher Paper → enter the teacher password → open the published paper → Start Practice.
- During practice, once an answer is selected it is locked. Correct is green and wrong is red. No solution/correct answer is shown during the exam.
- Existing model question sets continue to open in Practice mode.
- Run the project from the project root with a local web server, for example VS Code Live Server.


## Packaging
- Frontend and admin HTML pages now contain their own CSS and JavaScript internally.
- Existing local JSON data/question files and image assets are preserved.
- The Home smart-switch keeps the purple graduation-cap image and its label underneath has been removed.
