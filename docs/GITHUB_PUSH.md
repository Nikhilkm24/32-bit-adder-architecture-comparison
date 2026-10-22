# Publish this project to GitHub

1. Create a new empty repository on GitHub. Do not initialize it with a README if you plan to push this directory as-is.
2. Extract this ZIP, open a terminal in the extracted repository root, and review the contents.
3. Do not add `lib/nangate_typ.lib` unless the library's terms allow you to share it. The `.gitignore` excludes local Liberty files.
4. Initialize and push:

```bash
git init
git add .
git status
git commit -m "Add 32-bit adder comparison project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

Replace `YOUR_USERNAME` and `YOUR_REPOSITORY` with your GitHub details. If the repository already has commits, follow GitHub's instructions for that repository instead of force-pushing.

Before publishing final numerical claims, rerun the bundled RTL through simulation, synthesis, and STA. The checked-in CSV/plots preserve historical measurements from the earlier workspace and explicitly disclose that they may not reproduce from the newly bundled BK/KS RTL.
