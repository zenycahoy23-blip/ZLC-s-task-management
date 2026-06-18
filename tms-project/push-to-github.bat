@echo off
REM TMS Project - Push All Files to GitHub (Windows)
REM Run this script to initialize and push all files to your empty GitHub repository

setlocal enabledelayedexpansion

echo === TMS Project - GitHub Push Script (Windows) ===
echo.
echo This script will:
echo 1. Initialize Git in the project directory (if needed)
echo 2. Add all files
echo 3. Create initial commit
echo 4. Set up remote to your GitHub repository
echo 5. Push all files to main branch
echo.

REM Check if git is installed
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is not installed
    echo Download from: https://git-scm.com/
    pause
    exit /b 1
)

echo [INFO] Current directory: %cd%
echo.

REM Initialize git if not already initialized
if not exist ".git" (
    echo [INFO] Initializing Git repository...
    git init
    echo [OK] Git initialized
) else (
    echo [OK] Git repository already exists
)

echo.
echo [INFO] Configuring Git user...

REM Configure git user
git config user.email "ci@tms.local"
git config user.name "TMS CI/CD"

echo [OK] Git user configured

echo.
echo [INFO] Staging all files...

REM Add all files
git add .

echo.
echo [INFO] Files to be committed:
git diff --cached --name-only

echo.
set /p CONFIRM="Continue? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo Cancelled
    exit /b 0
)

echo.
echo [INFO] Creating initial commit...
git commit -m "Initial commit: TMS project with complete CI/CD setup

- Docker Compose configuration (dev + prod)
- GitHub Actions CI/CD workflow
- Slack notifications integration
- Docker Hub integration (indae2)
- Deployment scripts (Unix + Windows)
- Complete documentation
- Environment templates
- Verification tools"

echo [OK] Commit created

echo.
echo [INFO] Setting up GitHub remote...

REM Check if remote exists and remove it
for /f "tokens=*" %%i in ('git remote') do (
    if "%%i"=="origin" git remote remove origin
)

REM Add GitHub remote
set REPO_URL=git@github.com:zenycahoy23-blip/ZLC-s-task-management.git
echo [INFO] Adding remote: !REPO_URL!
git remote add origin !REPO_URL!

echo [OK] Remote configured

echo.
echo [INFO] Setting main as default branch...
git branch -M main

echo.
echo [INFO] Pushing to GitHub...
echo (This may take a few minutes depending on file size)
echo.

REM Push to main branch
git push -u origin main

if errorlevel 1 (
    echo.
    echo [ERROR] Push failed!
    echo.
    echo Troubleshooting:
    echo - Make sure SSH keys are set up: https://github.com/settings/keys
    echo - Or use HTTPS: git remote set-url origin https://github.com/zenycahoy23-blip/ZLC-s-task-management.git
    pause
    exit /b 1
)

echo.
echo [OK] All files pushed successfully!
echo.
echo Verify at: https://github.com/zenycahoy23-blip/ZLC-s-task-management
echo.
echo Next steps:
echo 1. Add GitHub Secrets (Settings - Secrets and variables - Actions)
echo    - DOCKER_USERNAME: indae2
echo    - DOCKER_PASSWORD: [your docker password]
echo    - SLACK_WEBHOOK: [Your Slack Webhook]
echo.
echo 2. Visit Actions tab to see CI/CD pipeline running
echo.
echo 3. Check Slack for notifications
echo.

pause
