# TMS CI/CD Quick Reference Card

## 🚀 Quick Setup (5 minutes)

### 1. Add GitHub Secrets
```
Repository: https://github.com/zenycahoy23-blip/ZLC-s-task-management
Settings → Secrets and variables → Actions → New repository secret

DOCKER_USERNAME = indae2
DOCKER_PASSWORD = [your docker password]
SLACK_WEBHOOK = [Your Webhook URL]
```

### 2. Push Code
```bash
git add .
git commit -m "Enable CI/CD"
git push origin main
```

### 3. Watch Workflow
```
https://github.com/zenycahoy23-blip/ZLC-s-task-management/actions
```

### 4. Check Slack
Notifications will arrive in your Slack channel

---

## 📋 Local Commands

### Start/Stop
```bash
./deploy-local.sh start     # Start all services
./deploy-local.sh stop      # Stop all services
./deploy-local.sh restart   # Restart services
./deploy-local.sh status    # Check status
```

### Logs
```bash
./deploy-local.sh logs              # All services
./deploy-local.sh logs frontend     # Specific service
./deploy-local.sh logs php
./deploy-local.sh logs nginx
./deploy-local.sh logs db
```

### Update Images
```bash
./deploy-local.sh pull      # Pull latest from Docker Hub
```

### Testing
```bash
./deploy-local.sh test      # Run all tests
```

### Cleanup
```bash
./deploy-local.sh clean     # Remove all containers/volumes
```

---

## 🌐 Access Points

| Service | URL | Port |
|---|---|---|
| Frontend | http://localhost:3000 | 3000 |
| API/Backend | http://localhost:8000 | 8000 |
| Jenkins | http://localhost:8080 | 8080 |
| Database | localhost:3307 | 3307 |

---

## 🐳 Docker Commands

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# View images
docker images

# Check service logs
docker compose logs service_name

# Shell into container
docker exec -it container_name bash

# View container stats
docker stats

# Cleanup unused resources
docker system prune -a
```

---

## 📊 Pipeline Status

| Stage | Status | Time |
|---|---|---|
| Build (PHP + Frontend) | ✓ | ~2-3 min |
| Test (PHPUnit + Vitest) | ✓ | ~3-5 min |
| Push to Docker Hub | ✓ | ~1-2 min |
| Slack Notification | ✓ | Instant |

**Total Pipeline Time:** ~6-10 minutes

---

## 🔑 Credentials

```
Docker Hub:
  Username: indae2
  Token: [your docker password]

GitHub:
  Repository: git@github.com:zenycahoy23-blip/ZLC-s-task-management.git
  Branch: main

Database:
  Host: localhost:3307
  User: tms_user
  Pass: tms_password
```

---

## 📝 Files Reference

```
CI/CD Files Created:
├── .github/workflows/
│   └── ci-cd.yml                    # GitHub Actions workflow
├── docker-compose.prod.yml          # Production compose
├── deploy-local.sh                  # Unix deployment script
├── deploy-local.bat                 # Windows deployment script
├── .env.example                     # Environment template
├── verify-setup.sh                  # Setup verification
├── DEPLOYMENT_GUIDE.md              # Full documentation
├── GITHUB_SECRETS_SETUP.md          # Secrets guide
└── CI_CD_SETUP_CHECKLIST.md        # This checklist
```

---

## ⚠️ Common Issues & Fixes

### Images Not Building
```bash
# Check disk space
docker system df

# Clean up
docker system prune -a

# Rebuild
docker compose build --no-cache
```

### Secrets Not Working
```bash
1. Go to: Settings → Secrets and variables → Actions
2. Verify all 3 secrets are present
3. Wait 1 minute
4. Re-run workflow
```

### Port Already in Use
```bash
# Change ports in .env
NGINX_PORT=8001
FRONTEND_PORT=3001
JENKINS_PORT=8081
```

### Database Connection Failed
```bash
# Check DB is running
docker compose logs db

# Restart DB
docker compose restart db

# Check connection
docker compose exec db mysql -u tms_user -p tms -e "SELECT 1;"
```

---

## 🔄 Typical Workflow

```
1. Developer makes changes locally
   ↓
2. Commits and pushes to GitHub
   ↓
3. GitHub Actions automatically:
   - Builds Docker images
   - Runs tests
   - Pushes to Docker Hub
   ↓
4. Slack notification sent
   ↓
5. On local server:
   ./deploy-local.sh pull
   docker compose restart
   ↓
6. Application updated
```

---

## 📚 Full Documentation

- **Complete Setup**: `DEPLOYMENT_GUIDE.md`
- **GitHub Actions**: `GITHUB_SECRETS_SETUP.md`
- **Checklist**: `CI_CD_SETUP_CHECKLIST.md`

---

## 🆘 Emergency Commands

```bash
# Stop everything
docker compose down

# Force stop containers
docker kill $(docker ps -q)

# Remove all stopped containers
docker container prune -f

# Reset everything
docker compose down -v
docker system prune -a
docker compose up -d
```

---

## 📞 Quick Contacts

- **GitHub Issues**: https://github.com/zenycahoy23-blip/ZLC-s-task-management/issues
- **Docker Hub**: https://hub.docker.com/r/indae2
- **Slack**: [Your Slack Workspace]

---

**Last Updated:** 2026-06-18
**Version:** 1.0
**Status:** Ready for Production
