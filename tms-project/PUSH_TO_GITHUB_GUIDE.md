# Push Project to GitHub - Step by Step Guide

## ⚠️ Important: Your GitHub Repository is Currently Empty

You have 2 options to push all files:

### Option 1: Automated Script (Recommended)

#### Windows
1. Open Command Prompt or PowerShell
2. Navigate to the project directory:
   ```
   cd "C:\Users\Acer\OneDrive\Desktop\ZLC Task Management\tms-project"
   ```
3. Run the script:
   ```
   push-to-github.bat
   ```
4. Follow the prompts

#### Mac/Linux
1. Open Terminal
2. Navigate to the project directory:
   ```bash
   cd ~/path/to/ZLC\ Task\ Management/tms-project
   ```
3. Make the script executable:
   ```bash
   chmod +x push-to-github.sh
   ```
4. Run the script:
   ```bash
   ./push-to-github.sh
   ```
5. Follow the prompts

---

### Option 2: Manual Command Line

#### Step 1: Navigate to Project
```bash
# Windows (PowerShell)
cd "C:\Users\Acer\OneDrive\Desktop\ZLC Task Management\tms-project"

# Mac/Linux
cd ~/path/to/tms-project
```

#### Step 2: Initialize Git (if not already done)
```bash
git init
```

#### Step 3: Configure Git User (first time only)
```bash
git config user.email "your-email@example.com"
git config user.name "Your Name"
```

#### Step 4: Add All Files
```bash
git add .
```

#### Step 5: Check What Will Be Committed
```bash
git status
```

You should see all files listed under "Changes to be committed"

#### Step 6: Create Initial Commit
```bash
git commit -m "Initial commit: TMS project with complete CI/CD setup

- Docker Compose configuration (dev + prod)
- GitHub Actions CI/CD workflow
- Slack notifications integration
- Docker Hub integration
- Deployment scripts
- Complete documentation"
```

#### Step 7: Add GitHub Remote
```bash
git remote add origin git@github.com:zenycahoy23-blip/ZLC-s-task-management.git
```

#### Step 8: Rename Branch to Main (if needed)
```bash
git branch -M main
```

#### Step 9: Push to GitHub
```bash
git push -u origin main
```

---

## ⚠️ SSH Keys Setup (Required)

If you get an SSH authentication error, you need to set up SSH keys:

### Check if SSH Keys Exist
```bash
# Mac/Linux
ls -la ~/.ssh/id_rsa

# Windows (Git Bash)
dir %USERPROFILE%\.ssh\id_rsa
```

### Generate SSH Keys (if they don't exist)
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
# Press Enter for all prompts to use defaults
```

### Add SSH Key to GitHub

1. Copy your public key:
   ```bash
   # Mac/Linux
   cat ~/.ssh/id_ed25519.pub
   
   # Windows (Git Bash)
   type %USERPROFILE%\.ssh\id_ed25519.pub
   ```

2. Go to GitHub: https://github.com/settings/keys

3. Click "New SSH key"

4. Title: "My Computer" (or your computer name)

5. Paste the key you copied

6. Click "Add SSH key"

### Test SSH Connection
```bash
ssh -T git@github.com
```

You should see:
```
Hi zenycahoy23-blip! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 🔗 Alternative: HTTPS Instead of SSH

If SSH is too complicated, use HTTPS instead:

### Set Remote with HTTPS
Instead of Step 7 above, use:
```bash
git remote add origin https://github.com/zenycahoy23-blip/ZLC-s-task-management.git
```

### Generate Personal Access Token
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: "GitHub CLI"
4. Select scopes:
   - ✓ repo (full control)
   - ✓ workflow
5. Generate token and copy it

### When Pushing with HTTPS
When you run `git push`, it will ask for:
- **Username:** zenycahoy23-blip
- **Password:** Paste the token you just generated

---

## 📊 File Count Reference

You should see approximately:

```
10+ new files created:
├── .github/workflows/ci-cd.yml
├── docker-compose.prod.yml
├── deploy-local.sh
├── deploy-local.bat
├── push-to-github.sh
├── push-to-github.bat
├── verify-setup.sh
├── .env.example
├── QUICK_REFERENCE.md
├── CI_CD_SETUP_CHECKLIST.md
├── DEPLOYMENT_GUIDE.md
├── GITHUB_SECRETS_SETUP.md
├── CI_CD_SETUP_INDEX.md
└── PUSH_TO_GITHUB_GUIDE.md (this file)

Modified files:
├── docker-compose.yml (updated for builds)
├── frontend/Dockerfile (simplified)
├── laravel/Dockerfile (added extensions)
└── other existing files...
```

---

## ✅ Verification Checklist

After pushing, verify:

1. **GitHub Repository**
   - [ ] Go to: https://github.com/zenycahoy23-blip/ZLC-s-task-management
   - [ ] Confirm main branch has new files
   - [ ] Check `.github/workflows/ci-cd.yml` exists

2. **GitHub Actions**
   - [ ] Go to: Actions tab
   - [ ] Workflow should be running or completed
   - [ ] All jobs (build, test, deploy) show status

3. **Docker Hub**
   - [ ] Check: https://hub.docker.com/r/indae2/tms-php
   - [ ] Check: https://hub.docker.com/r/indae2/tms-frontend
   - [ ] New tags should appear after workflow completes

4. **Slack**
   - [ ] Check your Slack channel
   - [ ] Build notifications should appear
   - [ ] Include commit hash and author info

---

## 🆘 Troubleshooting

### Error: "fatal: destination path already exists and is not an empty directory"
**Solution:** The directory already has git
```bash
# Check if .git exists
ls -la .git    # Mac/Linux
dir .git       # Windows

# If it exists, skip the `git init` step
```

### Error: "Permission denied (publickey)"
**Solution:** SSH keys not set up
- Follow the "SSH Keys Setup" section above
- Or use HTTPS method instead

### Error: "fatal: The current branch main does not have any commits yet"
**Solution:** Commit wasn't created
```bash
git status  # Check what's staged
git commit -m "Initial commit"  # Try again
```

### Error: "Please make sure you have the correct access rights"
**Solution:** Check SSH key or GitHub credentials
- Verify SSH key is added to GitHub (Settings → SSH and GPG keys)
- Or use HTTPS with Personal Access Token

### Git commands not found
**Solution:** Git is not installed
- Download from: https://git-scm.com/
- Or use GitHub Desktop: https://desktop.github.com/

---

## 📝 Sample Output

When successful, you should see:

```
Initializing Git repository...
✓ Git initialized

Configuring Git user...
✓ Git user configured

Staging all files...
✓ 300+ files added

Creating initial commit...
✓ Commit created

Setting up GitHub remote...
✓ Remote configured

Pushing to GitHub...
(This may take a few minutes depending on file size)

✓ All files pushed successfully!

Verify at: https://github.com/zenycahoy23-blip/ZLC-s-task-management
```

---

## 🎯 Next Steps After Push

1. **Add GitHub Secrets**
   - Go to: Settings → Secrets and variables → Actions
   - Add: DOCKER_USERNAME, DOCKER_PASSWORD, SLACK_WEBHOOK

2. **Monitor CI/CD**
   - Go to: Actions tab
   - Watch workflow execution
   - Check build logs

3. **Verify Deployment**
   - Check Docker Hub for new images
   - Verify Slack notifications
   - Pull images locally: `./deploy-local.sh pull`

---

## 📞 Quick Commands Reference

```bash
# Check git status
git status

# View commit history
git log

# Check remote URL
git remote -v

# List all branches
git branch -a

# Undo last commit (keep changes)
git reset --soft HEAD~1

# View pending changes
git diff

# Pull latest from GitHub
git pull origin main

# Push changes
git push origin main
```

---

**Need Help?** 
- Read: GITHUB_SECRETS_SETUP.md (next step)
- Check: DEPLOYMENT_GUIDE.md (complete reference)
- Use: QUICK_REFERENCE.md (quick commands)
