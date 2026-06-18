# TMS Deployment & CI/CD Guide

## Quick Start

### Local Development

```bash
# Start all services
./deploy-local.sh start

# View logs
./deploy-local.sh logs

# Access points
- Frontend: http://localhost:3000
- API: http://localhost:8000
- Jenkins: http://localhost:8080
- Database: localhost:3307
```

### Windows

```bash
# Start all services
deploy-local.bat start

# View logs
deploy-local.bat logs frontend
```

## CI/CD Pipeline Overview

The GitHub Actions pipeline automatically:

1. **Builds** Docker images (PHP & Frontend) on every push to `main`/`develop`
2. **Tests** Laravel (PHPUnit) and Nuxt (Jest/Vitest)
3. **Pushes** images to Docker Hub (`indae2/tms-php`, `indae2/tms-frontend`)
4. **Notifies** Slack on success/failure
5. **Prepares** for deployment

### Pipeline Workflow

```
GitHub Push
    ↓
Build Job (Build & Push Images)
    ↓
Test Job (PHPUnit + Vitest)
    ↓
Deploy Job (Local Deployment Ready)
    ↓
Slack Notification
```

## GitHub Setup

### 1. Repository SSH Key Setup

```bash
# Clone the repository
git clone git@github.com:zenycahoy23-blip/ZLC-s-task-management.git
cd ZLC-s-task-management

# Verify SSH connection
ssh -T git@github.com
```

### 2. Add GitHub Secrets

Go to: **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret Name | Value |
|---|---|
| `DOCKER_USERNAME` | `indae2` |
| `DOCKER_PASSWORD` | `[your docker password]` |
| `SLACK_WEBHOOK` | [Your Slack Webhook URL] |

### 3. Push Code to Trigger Pipeline

```bash
git add .
git commit -m "Enable CI/CD pipeline"
git push origin main
```

### 4. Monitor Workflow

1. Go to **Actions** tab
2. Watch the workflow run in real-time
3. Check Slack for notifications

## Docker Registry (Docker Hub)

### Login to Docker Hub

```bash
docker login -u indae2
# Paste token: [your docker password]
```

### Pull Latest Images

```bash
# PHP image
docker pull indae2/tms-php:latest

# Frontend image
docker pull indae2/tms-frontend:latest
```

### Verify Images

```bash
docker images | grep indae2
```

## Slack Integration

### Webhook Notifications

The CI/CD pipeline sends notifications to Slack for:

- ✅ Build successful
- ❌ Build failed
- ✅ Tests passed
- ❌ Tests failed
- 🚀 Deployment starting
- ✅ Deployment complete

### Custom Alerts

To add more Slack channels or alerts, modify `.github/workflows/ci-cd.yml`:

```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1.24.0
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK }}
    payload: |
      {
        "text": "Your custom message"
      }
```

## Local Deployment Commands

### Start Services

```bash
# Using shell script (Linux/Mac)
./deploy-local.sh start

# Using batch file (Windows)
deploy-local.bat start

# Or manually
docker compose up -d
```

### Stop Services

```bash
./deploy-local.sh stop
# or
docker compose down
```

### View Logs

```bash
# All services
./deploy-local.sh logs

# Specific service
./deploy-local.sh logs frontend
./deploy-local.sh logs php
./deploy-local.sh logs nginx
./deploy-local.sh logs db
```

### Check Status

```bash
./deploy-local.sh status
# or
docker compose ps
```

### Pull Latest Images from Registry

```bash
./deploy-local.sh pull
```

This pulls the latest built images from Docker Hub and restarts services.

### Run Tests Locally

```bash
./deploy-local.sh test

# Or manually
docker compose exec php php artisan test --parallel
docker compose exec frontend npm run test:unit
```

### Access Container Shells

```bash
# PHP container
./deploy-local.sh shell-php

# Frontend container
./deploy-local.sh shell-frontend
```

### Clean Up Everything

```bash
./deploy-local.sh clean

# This removes:
# - All containers
# - All volumes
# - All networks
# WARNING: This deletes database data!
```

## Environment Variables

Create `.env` file in project root:

```bash
cp .env.example .env
```

Edit `.env` for your environment:

```env
# Database
DB_DATABASE=tms
DB_USERNAME=tms_user
DB_PASSWORD=tms_password

# Laravel
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:your-key-here

# Frontend
VITE_API_URL=http://localhost:8000

# Docker
IMAGE_TAG=latest
REGISTRY=docker.io

# Ports
NGINX_PORT=8000
FRONTEND_PORT=3000
JENKINS_PORT=8080
```

## Production Setup (Future)

When you have a production server, use `docker-compose.prod.yml`:

```bash
# On production server
docker compose -f docker-compose.prod.yml up -d

# With custom domain
VITE_API_URL=https://api.yourdomain.com \
NGINX_PORT=80 \
docker compose -f docker-compose.prod.yml up -d
```

## Troubleshooting

### Images not building

```bash
# Check Docker status
docker ps -a

# View build logs
docker compose logs frontend
docker compose logs php

# Rebuild with no cache
docker compose build --no-cache
```

### Containers won't start

```bash
# Check logs
docker compose logs service_name

# Inspect container
docker inspect container_name

# Check network
docker network ls
docker network inspect tms_tms
```

### Database connection issues

```bash
# Check if MySQL is healthy
docker compose logs db

# Verify database exists
docker compose exec db mysql -u tms_user -p tms -e "SELECT 1;"
```

### Port conflicts

```bash
# Find process using port
lsof -i :8000
netstat -ano | findstr :8000  # Windows

# Change in .env
NGINX_PORT=8001
FRONTEND_PORT=3001
```

## GitHub Actions Workflow Structure

### Build Job

Builds Docker images for:
- PHP (Laravel 11 with all extensions)
- Frontend (Nuxt 4 with dependencies)

Pushes to Docker Hub with tags:
- `indae2/tms-php:latest`
- `indae2/tms-php:sha256`
- `indae2/tms-frontend:latest`
- `indae2/tms-frontend:sha256`

### Test Job

Runs after build:
- PHPUnit tests (Laravel)
- Vitest/Jest tests (Nuxt)
- Frontend build verification

### Deploy Job

Runs on `main` branch only:
- Validates images pushed to registry
- Sends deployment notification to Slack
- Ready for manual pull on local server

## Monitoring

### View All Workflows

GitHub Actions **Actions** tab shows:
- Workflow status (success/failure)
- Duration
- Commit message
- Author
- Branch

### View Individual Run Details

1. Click workflow name
2. See jobs (build, test, deploy)
3. See individual step logs
4. Download artifacts

### Slack Channel Monitoring

The configured Slack channel receives:
- Real-time build updates
- Test results
- Deployment readiness
- Error alerts

## Next Steps

### When Ready for Production

1. Get a domain (free option: GitHub Pages, Vercel)
2. Set up a production server or use cloud service (AWS, DigitalOcean, Heroku)
3. Update `.github/workflows/ci-cd.yml` with deployment step
4. Add secrets for production credentials
5. Configure DNS and SSL certificates

### Monitoring & Logging

1. Set up centralized logging (ELK, Datadog)
2. Configure error tracking (Sentry)
3. Monitor performance (New Relic, APM)
4. Set up alerting rules

### Scaling

1. Use Docker Swarm or Kubernetes
2. Set up load balancing (Nginx, HAProxy)
3. Configure auto-scaling
4. Use managed services (RDS for DB, etc.)

## Support

### Common Issues

- **Build hangs**: Check Docker disk space with `docker system df`
- **Tests fail**: Check MySQL is healthy with `docker compose exec db mysqladmin ping`
- **Images won't push**: Verify Docker Hub credentials

### Useful Commands

```bash
# Check Docker status
docker system info

# Clean up unused resources
docker system prune -a

# View resource usage
docker stats

# Check image layers
docker history image_name
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Laravel Documentation](https://laravel.com/docs)
- [Nuxt Documentation](https://nuxt.com/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
