@echo off
REM Clean Git History - Remove All Secret Commits (Windows)
REM This completely rewrites history to remove secrets

echo.
echo WARNING: This will rewrite all git history!
echo Run this ONLY if you haven't shared the repo with others yet
echo.
set /p confirm="Continue? (type 'YES' to proceed): "

if /i not "!confirm!"=="YES" (
    echo Cancelled
    exit /b 0
)

echo Removing all commits and starting fresh...

REM Remove all history
rmdir /s /q .git 2>nul

REM Reinitialize
git init

REM Set remote
git remote add origin git@github.com:zenycahoy23-blip/ZLC-s-task-management.git

REM Add all current files (without history)
git add .

REM Create fresh commit
git commit -m "Initial commit: TMS with CI/CD setup (secrets removed from history)

- Complete GitHub Actions workflow
- Docker Compose configuration (dev + prod)
- Deployment automation scripts
- Comprehensive documentation
- All credentials stored in GitHub Secrets only
- No secrets in repository history"

REM Set main branch
git branch -M main

REM Force push (ONLY safe if repo is brand new)
git push -u --force origin main

echo.
echo [OK] Clean history pushed!
echo All commits with exposed secrets have been removed
pause
