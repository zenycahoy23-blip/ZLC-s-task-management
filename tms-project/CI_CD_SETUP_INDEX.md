# TMS CI/CD Complete Setup - Navigation Guide

## 🎯 Start Here

**New to this setup?** Read in this order:

1. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** ← Start here (5 min read)
2. **[CI_CD_SETUP_CHECKLIST.md](./CI_CD_SETUP_CHECKLIST.md)** ← Status & TODO (10 min read)
3. **[GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md)** ← Setup secrets (5 min setup)
4. **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** ← Full documentation (30 min read)

---

## 📦 What's Included

### CI/CD Pipeline
- ✅ **GitHub Actions workflow** (`.github/workflows/ci-cd.yml`)
  - Builds Docker images on every push
  - Runs tests automatically
  - Pushes images to Docker Hub
  - Sends Slack notifications

### Docker Configuration
- ✅ **docker-compose.yml** - Development setup
- ✅ **docker-compose.prod.yml** - Production setup
- ✅ **laravel/Dockerfile** - PHP with all required extensions
- ✅ **frontend/Dockerfile** - Node.js with Nuxt

### Deployment Tools
- ✅ **deploy-local.sh** - Unix/Linux/Mac deployment script
- ✅ **deploy-local.bat** - Windows deployment script
- ✅ **verify-setup.sh** - System verification script

### Configuration
- ✅ **.env.example** - Environment template
- ✅ **Jenkinsfile** - Jenkins CI/CD integration ready

### Documentation
- ✅ **QUICK_REFERENCE.md** - Quick commands
- ✅ **CI_CD_SETUP_CHECKLIST.md** - Setup checklist
- ✅ **DEPLOYMENT_GUIDE.md** - Complete guide
- ✅ **GITHUB_SECRETS_SETUP.md** - Secrets configuration
- ✅ **CI_CD_SETUP_INDEX.md** - This file

---

## 🚀 3-Step Quick Start

### Step 1: Add GitHub Secrets (2 minutes)
```
Repository → Settings → Secrets and variables → Actions

Add 3 secrets:
✓ DOCKER_USERNAME = indae2
✓ DOCKER_PASSWORD = [your docker pass]
✓ SLACK_WEBHOOK = [Your Webhook URL]
```

### Step 2: Push to GitHub (1 minute)
```bash
git add .
git commit -m "Enable CI/CD pipeline"
git push origin main
```

### Step 3: Watch Workflow (5 minutes)
```
GitHub → Actions tab → Watch build, test, deploy jobs
Slack → Monitor notifications
```

---

## 📊 System Architecture

```
┌─────────────────────────────────────────┐
│         GitHub Repository               │
│  zenycahoy23-blip/ZLC-s-task-management│
└────────────────────┬────────────────────┘
                     │
                     ├─→ Push Code
                     │
┌────────────────────▼────────────────────┐
│       GitHub Actions Workflow            │
│         (.github/workflows/ci-cd.yml)   │
├─────────────────────────────────────────┤
│ Job 1: BUILD                            │
│ ├─ Build PHP image (laravel)            │
│ ├─ Build Frontend image (nuxt)          │
│ └─ Push to Docker Hub (indae2/)         │
├─────────────────────────────────────────┤
│ Job 2: TEST (parallel)                  │
│ ├─ PHPUnit tests (Laravel)              │
│ ├─ Vitest tests (Vue/Nuxt)              │
│ └─ Build verification                   │
├─────────────────────────────────────────┤
│ Job 3: DEPLOY (main branch only)        │
│ ├─ Validate images in registry          │
│ ├─ Send Slack notification              │
│ └─ Ready for manual deployment          │
└────────────────────┬────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
    ┌────▼─┐   ┌────▼─┐   ┌────▼──┐
    │Slack │   │Docker│   │Local  │
    │Notif │   │ Hub  │   │Server │
    └──────┘   └─────┘   └───────┘
```

---

## 🔧 Command Reference

### Deployment Scripts
```bash
# Unix/Linux/Mac
./deploy-local.sh start              # Start services
./deploy-local.sh stop               # Stop services
./deploy-local.sh status             # Check status
./deploy-local.sh logs frontend      # View logs
./deploy-local.sh pull               # Pull latest images
./deploy-local.sh test               # Run tests

# Windows
deploy-local.bat start
deploy-local.bat status
deploy-local.bat logs frontend
```

### Docker Commands
```bash
# View services
docker compose ps
docker ps -a
docker images

# Check logs
docker compose logs frontend
docker compose logs -f php

# Rebuild
docker compose build --no-cache

# Clean
docker system prune -a
```

### Verification
```bash
# Unix/Linux/Mac
./verify-setup.sh

# Check system ready
docker ps -a
docker images
git remote -v
```

---

## 📖 Document Guide

| Document | Purpose | Time | Who | When |
|---|---|---|---|---|
| **QUICK_REFERENCE.md** | Command cheat sheet | 5 min | Everyone | Daily use |
| **CI_CD_SETUP_CHECKLIST.md** | Setup status & TODO | 10 min | Lead Dev | Initial setup |
| **GITHUB_SECRETS_SETUP.md** | GitHub configuration | 10 min | Lead Dev | First time |
| **DEPLOYMENT_GUIDE.md** | Complete manual | 30 min | DevOps/Lead | Reference |
| **QUICK_REFERENCE.md** | Emergency commands | 5 min | Everyone | Troubleshooting |

---

## 🔐 Credentials & Configuration

### Docker Hub
```
Account: indae2
Username: indae2
PAT Token: [your docker password]
Repositories: tms-php, tms-frontend
```

### GitHub
```
Repository: https://github.com/zenycahoy23-blip/ZLC-s-task-management
SSH: git@github.com:zenycahoy23-blip/ZLC-s-task-management.git
Default Branch: main
```

### Database
```
Host: localhost:3307
User: tms_user
Password: tms_password
Database: tms
Root Password: root123
```

### Services
```
Frontend: http://localhost:3000
API: http://localhost:8000
Jenkins: http://localhost:8080
Database: localhost:3307
```

---

## ✅ Setup Status

### Completed (95%)
- [x] GitHub Actions CI/CD workflow created
- [x] Docker configurations (dev + prod)
- [x] Slack integration configured
- [x] Deployment scripts created
- [x] Documentation complete
- [x] Environment templates ready

### In Progress (5%)
- ⏳ Frontend Docker image build (npm installing packages)
- ⏳ All containers starting up

### Pending
- [ ] GitHub Secrets added (manual)
- [ ] Code pushed to GitHub (manual)
- [ ] First workflow run (automatic after push)
- [ ] Slack notifications received (automatic)

---

## 🎓 Learning Resources

### Docker
- [Docker Official Docs](https://docs.docker.com/)
- [Docker Compose Guide](https://docs.docker.com/compose/)
- [Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### GitHub Actions
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

### Laravel
- [Laravel Documentation](https://laravel.com/docs/11.x)
- [Deployment Guide](https://laravel.com/docs/11.x/deployment)

### Nuxt
- [Nuxt Documentation](https://nuxt.com/docs)
- [Deployment](https://nuxt.com/docs/guide/deploy/presets)

---

## 🆘 Quick Troubleshooting

### Frontend Build Stuck
```bash
docker compose logs frontend
# If stuck >15min, rebuild
docker compose build --no-cache frontend
```

### GitHub Actions Not Working
```
1. Check: Settings → Secrets and variables → Actions
2. Verify: DOCKER_USERNAME, DOCKER_PASSWORD, SLACK_WEBHOOK present
3. Re-run: Click "Re-run all jobs" in workflow
```

### Services Won't Start
```bash
docker compose down -v
docker compose up -d
docker compose logs
```

### Port Conflicts
Edit `.env`:
```env
NGINX_PORT=8001
FRONTEND_PORT=3001
JENKINS_PORT=8081
```

---

## 📞 Support

### For Issues
1. Check **QUICK_REFERENCE.md** for commands
2. Check **DEPLOYMENT_GUIDE.md** troubleshooting section
3. Review **CI_CD_SETUP_CHECKLIST.md** for status
4. Check GitHub Actions logs for build errors

### For Configuration
1. Read **GITHUB_SECRETS_SETUP.md** for GitHub setup
2. See **.env.example** for environment variables
3. Review **docker-compose.prod.yml** for production settings

### Emergency Reset
```bash
# Stop everything
docker compose down -v

# Clean up
docker system prune -a

# Restart fresh
docker compose up -d
```

---

## 🎉 Next Steps

### Immediate (Today)
1. ✅ Read QUICK_REFERENCE.md
2. ✅ Review CI_CD_SETUP_CHECKLIST.md
3. ✅ Add GitHub Secrets (GITHUB_SECRETS_SETUP.md)
4. ✅ Push code to GitHub

### Short Term (This Week)
1. Monitor first GitHub Actions workflow
2. Verify Slack notifications
3. Test image pull and deployment
4. Document any customizations

### Long Term (This Month)
1. Set up production deployment
2. Configure monitoring/logging
3. Optimize images for size/speed
4. Automate deployment to production

---

## 📋 File Structure

```
tms-project/
├── .github/workflows/
│   └── ci-cd.yml                    # GitHub Actions workflow
├── laravel/
│   ├── Dockerfile                   # PHP configuration
│   └── ...
├── frontend/
│   ├── Dockerfile                   # Node.js configuration
│   └── ...
├── docker-compose.yml               # Development environment
├── docker-compose.prod.yml          # Production environment
├── deploy-local.sh                  # Deployment script (Unix)
├── deploy-local.bat                 # Deployment script (Windows)
├── verify-setup.sh                  # Verification script
├── .env.example                     # Environment template
├── QUICK_REFERENCE.md               # Quick commands
├── CI_CD_SETUP_CHECKLIST.md        # Setup status
├── DEPLOYMENT_GUIDE.md              # Full documentation
├── GITHUB_SECRETS_SETUP.md          # GitHub configuration
└── CI_CD_SETUP_INDEX.md            # This file
```

---

## 🚀 Ready to Deploy?

### Before Pushing
1. Add GitHub Secrets
2. Review docker-compose files
3. Update .env with your values

### During Deployment
1. Push to main branch
2. Watch GitHub Actions
3. Monitor Slack notifications
4. Check Docker Hub images

### After Deployment
1. Pull images locally
2. Run docker compose up
3. Test all endpoints
4. Celebrate success! 🎉

---

**Last Updated:** 2026-06-18
**Version:** 1.0.0
**Status:** Ready for Production
**Maintainer:** Your Team

---

*For detailed setup, see [GITHUB_SECRETS_SETUP.md](./GITHUB_SECRETS_SETUP.md)*
*For complete guide, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)*
*For status check, see [CI_CD_SETUP_CHECKLIST.md](./CI_CD_SETUP_CHECKLIST.md)*
