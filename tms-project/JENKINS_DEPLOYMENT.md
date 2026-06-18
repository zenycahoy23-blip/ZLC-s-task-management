# Jenkins CI/CD Deployment Guide

## Overview

This guide covers setting up and running the Jenkins CI/CD pipeline for the Task Management System. The pipeline handles building, deploying, and monitoring the entire application stack with proper safeguards for the Jenkins container itself.

---

## Jenkins Setup

### Prerequisites

- Docker installed and running
- Docker socket accessible at `/var/run/docker.sock`
- Git repository with Jenkinsfile
- Email server configured (optional, for notifications)

### Building Jenkins Image

Build the custom Jenkins image with Docker support:

```bash
cd tms-project
docker build -f Dockerfile.jenkins -t jenkins-tms:latest .
```

This image includes:
- Jenkins LTS with JDK 17
- Docker CLI and daemon
- Docker Compose
- Docker BuildX
- Required Jenkins plugins for pipeline execution

### Running Jenkins Container

```bash
docker run -d \
  --name jenkins-tms \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /usr/local/bin/docker-compose:/usr/local/bin/docker-compose \
  -v jenkins-home:/var/jenkins_home \
  --restart unless-stopped \
  jenkins-tms:latest
```

**Important**: The jenkins-tms container persists across deployments and should NEVER be recreated.

### Initial Jenkins Setup

1. Access Jenkins at `http://localhost:8080`
2. Get initial admin password:
   ```bash
   docker logs jenkins-tms | grep "initialAdminPassword"
   ```
3. Complete initial setup wizard
4. Create admin user account
5. Install suggested plugins

### Configure Jenkins Credentials

#### Docker Registry Credentials (Optional)

1. Go to Jenkins Dashboard → Manage Jenkins → Credentials
2. Click "Add Credentials"
3. Select "Username with password"
4. Enter Docker Hub credentials

#### Email Configuration

1. Go to Manage Jenkins → Configure System
2. Scroll to "E-mail Notification"
3. Configure SMTP server:
   - SMTP Server: `smtp.gmail.com` (or your provider)
   - SMTP Port: `587`
   - Username: Your email
   - Password: App password
   - TLS: Enabled
4. Click "Test Configuration"

#### Extended Email Plugin

1. Go to Manage Jenkins → Configure System
2. Find "Extended E-mail Notification"
3. Configure SMTP settings and default recipients

---

## Creating the Pipeline Job

### Option 1: Pipeline from SCM (Recommended)

1. New Item → Pipeline
2. Name: `tms-deployment`
3. Configure:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: Your repo URL
   - **Branch**: `*/main` (or your branch)
   - **Script Path**: `Jenkinsfile`
4. Save

### Option 2: Create Pipeline Script Directly

1. New Item → Pipeline
2. Name: `tms-deployment`
3. In Pipeline section, select "Pipeline script"
4. Copy entire Jenkinsfile content
5. Save

---

## Jenkinsfile Overview

### Pipeline Structure

```
Pipeline
├── Stage: Fix Docker Permissions
├── Stage: Clean Workspace
├── Stage: Checkout
├── Stage: Build
├── Stage: Deploy
├── Stage: Health Check
├── Stage: Status
└── Post Actions (Email)
```

### Critical Deployment Logic

#### Container Management

**NEVER does this:**
```groovy
docker-compose down  // WRONG - stops all containers including Jenkins!
```

**ALWAYS does this:**
```groovy
docker-compose rm -f postgres backend frontend prometheus grafana
// Only removes specified containers, Jenkins persists!
```

#### Database Schema Application

```groovy
// Copy schema file to PostgreSQL container
docker cp schema.sql postgres-tms:/schema.sql

// Execute schema in container
docker-compose exec postgres psql -U tms_user -d tms -f /schema.sql
```

#### Service Startup

```groovy
// Start postgres first, wait for health
docker-compose up -d postgres
// ... health check loop ...

// Start remaining services with --no-recreate flag
docker-compose up -d --no-recreate backend frontend prometheus grafana
```

---

## Running the Pipeline

### Manual Trigger

1. Dashboard → tms-deployment
2. Click "Build Now"
3. Monitor console output

### Parameters

Customize pipeline behavior:

```groovy
parameters {
    string(name: 'DOCKER_REGISTRY', defaultValue: 'docker.io')
    string(name: 'ADMIN_EMAIL', defaultValue: 'admin@taskmanager.com')
}
```

### Build Output

Expected console output:

```
[Pipeline] Start of Pipeline
[Pipeline] node
Running in /var/jenkins_home/workspace/tms-deployment

========== Fixing Docker Permissions ==========
Running as root to fix socket permissions...

========== Cleaning Workspace ==========
Cleaned workspace

========== Checking Out Repository ==========
Checking out from repository...

========== Building Docker Images ==========
Building images...

========== Starting Deployment ==========
Removing old containers...
Starting PostgreSQL...
Waiting for PostgreSQL to be healthy...
PostgreSQL is healthy!
Applying database schema...
Schema applied successfully!
Ensuring admin user exists...
Starting remaining services...

========== Running Health Checks ==========
Checking backend health...
Backend is healthy!

========== Container Status ==========
CONTAINER ID   STATUS          PORTS
abc123...      Up 2 minutes     0.0.0.0:8082->8000/tcp
...
```

---

## Post-Pipeline Actions

### Email Notifications

On success:
```
Build succeeded!

Project: tms-deployment
Build Number: 42
Build Status: SUCCESS

Services running:
- Backend: http://localhost:8082
- Frontend: http://localhost:9030
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
```

On failure:
```
Build failed!

Project: tms-deployment
Build Number: 42
Build Status: FAILED

Console: http://jenkins:8080/job/tms-deployment/42/console

Please check the console output for errors.
```

---

## Troubleshooting Pipeline Issues

### Docker Socket Permission Denied

**Error**: `permission denied while trying to connect to Docker daemon`

**Solution**:
```bash
# Verify docker.sock is accessible
ls -la /var/run/docker.sock

# Fix permissions
sudo chmod 666 /var/run/docker.sock

# Restart Jenkins
docker restart jenkins-tms
```

### PostgreSQL Health Check Fails

**Error**: `pg_isready: could not translate host name "postgres" to address`

**Solution**:
```bash
# Ensure postgres-tms is on same network
docker network ls
docker network inspect tms-network

# Check postgres container
docker logs postgres-tms
```

### Schema Application Fails

**Error**: `schema.sql: No such file or directory`

**Cause**: Schema file not in workspace

**Solution**:
1. Verify `schema.sql` exists in repo root
2. Check git ignore doesn't exclude it
3. Verify workspace is clean
4. Run "Build Now" again

### Backend Health Check Timeout

**Error**: `curl: (7) Failed to connect to localhost port 8082`

**Solution**:
```bash
# Check backend container
docker ps | grep backend-tms
docker logs backend-tms

# Verify port mapping
docker port backend-tms

# Test manually
curl http://localhost:8082/api/health
```

### Email Notifications Not Sending

**Cause**: Email configuration incomplete

**Solution**:
1. Verify SMTP settings: Manage Jenkins → Configure System
2. Test with "Test Configuration" button
3. Check Jenkins logs: `docker logs jenkins-tms`
4. Verify recipient email addresses

---

## Advanced Pipeline Customization

### Adding Stages

```groovy
stage('Run Tests') {
    steps {
        sh '''
            cd ${PROJECT_PATH}
            docker-compose exec -T backend php artisan test
        '''
    }
}

stage('Deploy to Staging') {
    when { branch 'staging' }
    steps {
        // Additional deployment steps
    }
}
```

### Conditional Deployment

```groovy
options {
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
}

when {
    branch 'main'
}
```

### Slack Notifications

```groovy
post {
    always {
        slackSend(
            color: currentBuild.result == 'SUCCESS' ? 'good' : 'danger',
            message: "Build ${env.BUILD_NUMBER}: ${currentBuild.result}"
        )
    }
}
```

---

## Best Practices

### 1. Backup Jenkins Configuration

```bash
# Backup Jenkins home
docker cp jenkins-tms:/var/jenkins_home ./jenkins_backup

# Backup should be committed to version control
git add jenkins_backup/
git commit -m "Backup Jenkins configuration"
```

### 2. Monitor Pipeline Performance

- Check Console Output for timing
- Monitor Docker build times
- Identify slow stages
- Optimize docker-compose build layers

### 3. Clean Up Resources

Add cleanup stage:

```groovy
stage('Cleanup') {
    steps {
        sh '''
            docker system prune -f --volumes
            docker image prune -f
        '''
    }
}
```

### 4. Security

- Never hardcode credentials in Jenkinsfile
- Use Jenkins credentials storage
- Rotate API keys regularly
- Enable Jenkins authentication
- Use firewall to restrict Jenkins port

### 5. Logging

- All actions logged to console
- Container logs accessible via `docker logs`
- Failed stages include full output
- Email notifications include console link

---

## Health Check Endpoints

### Backend Health

```bash
curl http://localhost:8082/api/health

# Expected response
{
  "status": "healthy"
}
```

### Database Connection

```bash
docker-compose exec postgres pg_isready -U tms_user -d tms
# Output: accepting connections
```

### Metrics Endpoint

```bash
curl http://localhost:8082/metrics

# Returns Prometheus format metrics
# HELP tms_total_tasks Total number of tasks
# TYPE tms_total_tasks gauge
# tms_total_tasks 42
```

---

## Monitoring Pipeline Health

### View Pipeline History

1. Dashboard → tms-deployment
2. Click "Build History" on left

### View Build Details

1. Click build number (e.g., "#42")
2. View Console Output
3. Check Build Artifacts (if any)

### Real-time Monitoring

```bash
# Follow Jenkins logs
docker logs -f jenkins-tms

# Follow service logs during pipeline
docker-compose logs -f [service_name]
```

---

## Disaster Recovery

### If Jenkins Container Crashes

Jenkins persists its data in volumes. To recover:

```bash
# Check if container still exists
docker ps -a | grep jenkins-tms

# If exists but stopped, restart
docker start jenkins-tms

# If removed, rebuild and run with same volume
docker build -f Dockerfile.jenkins -t jenkins-tms:latest .
docker run -d \
  --name jenkins-tms \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /usr/local/bin/docker-compose:/usr/local/bin/docker-compose \
  -v jenkins-home:/var/jenkins_home \
  jenkins-tms:latest
```

### If Pipeline Fails Mid-Deployment

1. Check what containers are running: `docker-compose ps`
2. Check logs: `docker-compose logs [service]`
3. Fix issue manually if needed
4. Run pipeline again with same Git commit

### If PostgreSQL Data Corrupts

```bash
# Backup current data
docker cp postgres-tms:/var/lib/postgresql/data ./postgres_backup

# Remove container and volume
docker-compose rm -f postgres
docker volume rm tms-project_postgres_data

# Restart pipeline
# Schema will be reapplied automatically
```

---

## Performance Optimization

### Reduce Build Time

```groovy
// Use BuildKit for faster builds
environment {
    DOCKER_BUILDKIT = 1
}
```

### Cache Docker Layers

Ensure Dockerfile uses layer caching:

```dockerfile
# Good: stable dependencies first
RUN apk add --no-cache dependencies
RUN composer install

# Bad: changes frequently, invalidates cache
COPY . .
RUN apk add --no-cache dependencies
```

### Parallel Builds

Current pipeline is sequential. For large deployments:

```groovy
parallel(
    'Build Backend': {
        sh 'docker build -t backend-tms ./laravel'
    },
    'Build Frontend': {
        sh 'docker build -t frontend-tms ./frontend'
    }
)
```

---

## Security Hardening

### Restrict Jenkins Access

```bash
# Add firewall rules
sudo ufw allow 8080/tcp from 192.168.1.0/24  # Your network only

# Jenkins authentication
1. Go to Manage Jenkins → Security
2. Enable "Use Jenkins' own user database"
3. Enable "Prevent Cross Site Request Forgery (CSRF)"
```

### Secrets Management

```groovy
// Use Jenkins credentials
withCredentials([
    usernamePassword(
        credentialsId: 'docker-creds',
        usernameVariable: 'DOCKER_USER',
        passwordVariable: 'DOCKER_PASS'
    )
]) {
    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
}
```

### Audit Logging

```bash
# Jenkins audit logs
docker logs jenkins-tms | grep "Build"

# Application audit logs
docker-compose exec backend tail -f storage/logs/laravel.log
```

---

## Appendix: Quick Reference

### Common Commands

```bash
# View pipeline status
docker exec jenkins-tms curl http://localhost:8080/api/json

# Trigger pipeline via URL
curl -X POST http://localhost:8080/job/tms-deployment/build

# Get build logs
docker exec jenkins-tms cat /var/jenkins_home/jobs/tms-deployment/builds/lastBuild/log

# Restart Jenkins
docker restart jenkins-tms

# Check resource usage
docker stats jenkins-tms
```

### Critical Files

- `Jenkinsfile` - Pipeline definition
- `Dockerfile.jenkins` - Jenkins image build
- `docker-compose.yml` - Application services
- `schema.sql` - Database schema
- `laravel/.env` - Backend configuration

---

For additional support, refer to:
- [Implementation Guide](IMPLEMENTATION.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Official Jenkins Documentation](https://www.jenkins.io/doc/)
