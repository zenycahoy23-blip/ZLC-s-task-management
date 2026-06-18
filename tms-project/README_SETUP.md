# TMS (Task Management System) - Complete Setup Guide

Complete CI/CD pipeline with GitHub Actions, Docker, Slack integration, and local deployment automation.

## 🎯 Quick Start (Choose Your Path)

### Path 1: I Want to Push Code NOW (5 minutes)
→ Read: **[QUICK_PUSH.md](./QUICK_PUSH.md)**

Steps:
1. Open `push-to-github.bat` (Windows) or `push-to-github.sh` (Mac/Linux)
2. Follow the prompts
3. Add GitHub secrets
4. Done!

### Path 2: I Want to Understand Everything (30 minutes)
→ Read: **[CI_CD_SETUP_INDEX.md](./CI_CD_SETUP_INDEX.md)**

Then:
1. [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Common commands
2. [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Full documentation
3. [GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md) - GitHub configuration

### Path 3: I Need Detailed Instructions (1 hour)
→ Read: **[PUSH_TO_GITHUB_GUIDE.md](./PUSH_TO_GITHUB_GUIDE.md)**

Step-by-step with troubleshooting for every situation.

---

## 📦 What's Included

### CI/CD Pipeline
✅ GitHub Actions workflow (`.github/workflows/ci-cd.yml`)
- Builds Docker images on every push
- Runs tests (PHPUnit + Vitest)
- Pushes to Docker Hub
- Sends Slack notifications

### Docker Setup
✅ Development: `docker-compose.yml`
✅ Production: `docker-compose.prod.yml`
✅ PHP Dockerfile with all extensions
✅ Frontend Dockerfile with Nuxt

### Deployment Automation
✅ `deploy-local.sh` - Unix/Linux/Mac script
✅ `deploy-local.bat` - Windows batch script
✅ Full automation: start/stop/logs/test/pull images

### Documentation
✅ 8+ comprehensive guides
✅ Quick reference cards
✅ Troubleshooting sections
✅ All configurations explained

---

## 🚀 First Time Setup (10 minutes)

### Step 1: Push Code to GitHub
```bash
# Option A: Automated
push-to-github.bat  # Windows
./push-to-github.sh # Mac/Linux

# Option B: Manual commands
git init
git add .
git commit -m "Initial commit: TMS with CI/CD"
git remote add origin git@github.com:zenycahoy23-blip/ZLC-s-task-management.git
git branch -M main
git push -u origin main
```

### Step 2: Add GitHub Secrets (3 minutes)
Go to: `https://github.com/zenycahoy23-blip/ZLC-s-task-management/settings/secrets/actions`

Click "New repository secret" and add:
| Secret | Value |
|--------|-------|
| `DOCKER_USERNAME` | `indae2` |
| `DOCKER_PASSWORD` | [Your Docker Hub Personal Access Token] |
| `SLACK_WEBHOOK` | Your webhook URL |

### Step 3: Watch It Work (5 minutes)
1. Go to Actions tab
2. Watch workflow run
3. Check Slack for notifications
4. Verify images in Docker Hub

---

## 📊 System Architecture

```
Your Computer
    ↓
Git Push to GitHub
    ↓
GitHub Actions (Automated)
├─ Build PHP + Frontend images
├─ Run tests
├─ Push to Docker Hub
└─ Send Slack notification
    ↓
Docker Hub
├─ indae2/tms-php:latest
└─ indae2/tms-frontend:latest
    ↓
Your Local Server
└─ Pull images & run services
```

---

## 🛠️ Local Development

### Start Services
```bash
# Option 1: Script
./deploy-local.sh start      # Unix/Mac/Linux
deploy-local.bat start       # Windows

# Option 2: Docker directly
docker compose up -d
```

### Access Services
```
Frontend: http://localhost:3000
API/Backend: http://localhost:8000
Jenkins: http://localhost:8080
Database: localhost:3307
```

### Common Commands
```bash
./deploy-local.sh start       # Start all
./deploy-local.sh stop        # Stop all
./deploy-local.sh logs        # View logs
./deploy-local.sh status      # Check status
./deploy-local.sh pull        # Update images
./deploy-local.sh test        # Run tests
./deploy-local.sh clean       # Delete everything
```

---

## 📚 Documentation Index

| File | Purpose | Read Time |
|------|---------|-----------|
| **QUICK_PUSH.md** | Push code in 30 seconds | 2 min |
| **PUSH_TO_GITHUB_GUIDE.md** | Detailed push instructions | 10 min |
| **QUICK_REFERENCE.md** | Command cheat sheet | 5 min |
| **CI_CD_SETUP_INDEX.md** | Navigation & overview | 10 min |
| **CI_CD_SETUP_CHECKLIST.md** | Setup status | 10 min |
| **DEPLOYMENT_GUIDE.md** | Complete manual | 30 min |
| **GITHUB_SECRETS_SETUP.md** | GitHub configuration | 5 min |

---

## 🔐 Credentials & Configuration

### Docker Hub
```
Account: indae2
Username: indae2
Token: [Stored in GitHub Secrets - DOCKER_PASSWORD]
Repositories: tms-php, tms-frontend
```

### GitHub Repository
```
URL: https://github.com/zenycahoy23-blip/ZLC-s-task-management
SSH: git@github.com:zenycahoy23-blip/ZLC-s-task-management.git
Branch: main
```

### Database
```
Host: localhost:3307
Username: tms_user
Password: tms_password
Database: tms
```

### Slack Webhook
```
Provides notifications for:
✓ Build status (success/failure)
✓ Test results
✓ Deployment readiness
✓ Image tags and sizes
```

---

## ✅ Current Status

```
✅ All CI/CD files created
✅ Docker configurations ready
✅ Documentation complete
✅ Deployment scripts prepared

⏳ Frontend image building (final step)
🔄 Services starting up

Next: Push to GitHub + Add secrets
```

---

## 🎯 Typical Workflow

```
1. Developer makes changes
   ↓
2. Commits and pushes code
   git push origin main
   ↓
3. GitHub Actions automatically:
   • Builds Docker images
   • Runs tests
   • Pushes to Docker Hub
   ↓
4. Slack notification received
   ✅ Build successful
   Commit: abc123 by Developer
   Images: indae2/tms-php:abc123
   ↓
5. Locally pull and deploy
   ./deploy-local.sh pull
   docker compose restart
   ↓
6. Application updated! 🎉
```

---

## 🆘 Help & Troubleshooting

### I Can't Push Code
→ Read: [PUSH_TO_GITHUB_GUIDE.md](./PUSH_TO_GITHUB_GUIDE.md) - Complete troubleshooting

### GitHub Actions Not Running
→ Check: Are secrets added? Settings → Secrets and variables → Actions

### Docker Images Not Pushing
→ Verify: Docker Hub credentials in GitHub secrets

### Services Won't Start
→ Run: `docker compose logs` to see error messages

### Need Quick Commands
→ Use: [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

---

## 📋 File Structure

```
tms-project/
├── .github/workflows/
│   └── ci-cd.yml                    ← GitHub Actions workflow
├── docker-compose.yml               ← Development setup
├── docker-compose.prod.yml          ← Production setup
├── laravel/Dockerfile               ← PHP configuration
├── frontend/Dockerfile              ← Node.js configuration
├── deploy-local.sh                  ← Unix deployment script
├── deploy-local.bat                 ← Windows deployment script
├── push-to-github.sh                ← Unix push script
├── push-to-github.bat               ← Windows push script
├── verify-setup.sh                  ← System verification
├── .env.example                     ← Environment template
├── QUICK_PUSH.md                    ← 30-second push guide
├── PUSH_TO_GITHUB_GUIDE.md          ← Detailed push guide
├── QUICK_REFERENCE.md               ← Commands cheat sheet
├── CI_CD_SETUP_INDEX.md             ← Navigation guide
├── CI_CD_SETUP_CHECKLIST.md         ← Setup status
├── DEPLOYMENT_GUIDE.md              ← Complete manual
├── GITHUB_SECRETS_SETUP.md          ← GitHub config
└── This file (README)
```

---

## 🚀 Getting Started

### Absolutely First Time? (Choose one)

**Option A: I just want it to work (5 min)**
1. Open `QUICK_PUSH.md`
2. Run the script
3. Add GitHub secrets
4. Done!

**Option B: I want to learn (30 min)**
1. Open `CI_CD_SETUP_INDEX.md`
2. Read through the guides
3. Run the setup scripts
4. Monitor the workflow

**Option C: I need detailed help (1 hour)**
1. Open `PUSH_TO_GITHUB_GUIDE.md`
2. Follow step-by-step instructions
3. Troubleshoot any issues
4. Complete the setup

---

## 📞 Support

### For Different Issues

| Issue | Solution |
|-------|----------|
| Can't push code | [PUSH_TO_GITHUB_GUIDE.md](./PUSH_TO_GITHUB_GUIDE.md) |
| GitHub Actions failing | [GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md) |
| Containers won't start | [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md#troubleshooting) |
| Need quick commands | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) |
| Everything! | [CI_CD_SETUP_INDEX.md](./CI_CD_SETUP_INDEX.md) |

---

## 🎉 Success Indicators

When setup is complete, you should see:

```
✅ Files visible at: https://github.com/zenycahoy23-blip/ZLC-s-task-management
✅ Workflow running in Actions tab
✅ Images building in Docker Hub
✅ Slack notifications arriving
✅ Services running locally: http://localhost:3000
```

---

## 📚 Learning Resources

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Compose Guide](https://docs.docker.com/compose/)
- [Laravel Docs](https://laravel.com/docs)
- [Nuxt Documentation](https://nuxt.com/docs)

---

## 📝 Version Info

```
TMS CI/CD Setup: v1.0
Created: 2026-06-18
Status: Ready for Production
Components:
  ✓ GitHub Actions
  ✓ Docker Compose
  ✓ Slack Integration
  ✓ Docker Hub Integration
  ✓ Local Deployment Scripts
```

---

## 🎯 Next Steps

1. **Today**: Push code to GitHub (use `QUICK_PUSH.md`)
2. **Today**: Add GitHub secrets
3. **Tomorrow**: Monitor first workflow run
4. **This Week**: Test local deployment
5. **This Month**: Set up production deployment

---

**Ready?** → Start with [QUICK_PUSH.md](./QUICK_PUSH.md) ⚡

Or read the [CI_CD_SETUP_INDEX.md](./CI_CD_SETUP_INDEX.md) for complete navigation 📚
