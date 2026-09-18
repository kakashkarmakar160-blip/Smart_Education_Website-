# Smart Education — GitHub Pages Ready

This package is prepared so `index.html`, `data/`, and `assets/` are at the same repository level.

## GitHub Pages
1. Upload **all files and folders inside this folder** to the repository root.
2. Make sure `index.html` is in the repository root.
3. In GitHub: Settings → Pages → Deploy from branch → `main` → `/ (root)` → Save.
4. Open the Pages link and hard-refresh once if an older version is cached.

The JSON question data is inside `data/`. The HTML files use `data/...` and `assets/...` paths, so they work from a GitHub Pages repository URL such as `/SEW/`.

No Docker is required for the static GitHub Pages version.
