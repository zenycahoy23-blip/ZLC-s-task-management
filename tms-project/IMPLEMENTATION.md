# Task Management System - Complete Implementation Guide

This is a comprehensive Task Management System with Role-Based Access Control (RBAC), Audit Logging, and Jenkins CI/CD Pipeline.

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Git

### Start All Services

```bash
# Navigate to project directory
cd tms-project

# Start all services (PostgreSQL, Backend, Frontend, Prometheus, Grafana)
docker-compose up -d

# Apply database schema manually
docker cp schema.sql postgres-tms:/schema.sql
docker-compose exec postgres psql -U tms_user -d tms -f /schema.sql

# Verify services are running
docker-compose ps
```

### Access Services

- **Frontend**: http://localhost:9030
- **Backend API**: http://localhost:8082
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin)

### Default Login

- **Email**: admin@taskmanager.com
- **Password**: password

---

## Architecture Overview

### Technology Stack

| Component | Technology | Port |
|-----------|-----------|------|
| Frontend | Nuxt.js 3 (Vue.js) | 9030 |
| Backend API | Laravel 11 (PHP) | 8082 |
| Database | PostgreSQL 15 | 5432 |
| Metrics | Prometheus | 9090 |
| Dashboards | Grafana | 3000 |
| CI/CD | Jenkins | 8080 |
| Container Orchestration | Docker Compose | - |

### Docker Containers

- `postgres-tms`: PostgreSQL database
- `backend-tms`: Laravel API server
- `frontend-tms`: Nuxt.js SPA
- `prometheus-tms`: Prometheus metrics collector
- `grafana-tms`: Grafana visualization
- `jenkins-tms`: Jenkins CI/CD (separate)

All containers run on the `tms-network` Docker network for seamless communication.

---

## Role-Based Access Control (RBAC)

### Roles

1. **Admin (Role ID: 1)**
   - Full system access
   - Can create, read, update, delete all resources
   - Can manage users and roles
   - Can view audit logs
   - Can view dashboard statistics for all users

2. **Manager (Role ID: 2)**
   - Can create and manage tasks
   - Can assign tasks to team members
   - Can view team statistics
   - Can see tasks by status and assignee
   - Cannot access audit logs or user management

3. **Member (Role ID: 3)**
   - Can view assigned tasks
   - Can update task status
   - Can view personal dashboard
   - Cannot create tasks or manage users
   - Limited to their own tasks

---

## API Endpoints

### Authentication
```
POST   /api/login              - Login with email and password
POST   /api/logout             - Logout (authenticated)
GET    /api/user               - Get current user info
```

### Tasks
```
GET    /api/tasks              - List tasks (role-based filtering)
POST   /api/tasks              - Create task (Manager, Admin only)
GET    /api/tasks/{id}         - Get task details
PUT    /api/tasks/{id}         - Update task
PATCH  /api/tasks/{id}/status  - Update task status only
DELETE /api/tasks/{id}         - Delete task (Admin only)
```

### Users (Admin Only)
```
GET    /api/users              - List all users
POST   /api/users              - Create user
GET    /api/users/{id}         - Get user details
PUT    /api/users/{id}         - Update user
DELETE /api/users/{id}         - Delete user
```

### Dashboard
```
GET    /api/dashboard/stats    - Get dashboard statistics (role-based)
```

### Audit Logs (Admin Only)
```
GET    /api/audit-logs         - Get audit logs with filters
```

### Notifications
```
GET    /api/notifications              - Get user notifications
PUT    /api/notifications/{id}/read    - Mark as read
GET    /api/notifications/unread-count - Get unread count
```

### System
```
GET    /api/health             - Health check
GET    /metrics                - Prometheus metrics
```

---

## Database Schema

### Tables

#### `roles`
- `id` (PRIMARY KEY)
- `name` (VARCHAR 50, UNIQUE)

#### `users`
- `id` (PRIMARY KEY)
- `name` (VARCHAR 100)
- `email` (VARCHAR 255, UNIQUE)
- `password` (VARCHAR 255)
- `role_id` (FOREIGN KEY → roles)
- `email_verified` (BOOLEAN)
- `account_locked` (BOOLEAN)
- `created_at` (TIMESTAMP)

#### `tasks`
- `id` (PRIMARY KEY)
- `title` (VARCHAR 255)
- `description` (TEXT)
- `status` (VARCHAR 50: todo, in_progress, done)
- `priority` (VARCHAR 50: low, medium, high)
- `assigned_to` (FOREIGN KEY → users)
- `created_by` (FOREIGN KEY → users)
- `category_id` (FOREIGN KEY → categories)
- `due_date` (TIMESTAMP)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### `categories`
- `id` (PRIMARY KEY)
- `name` (VARCHAR 100)
- `description` (TEXT)

#### `audit_logs`
- `id` (PRIMARY KEY)
- `user_id` (FOREIGN KEY → users)
- `action` (VARCHAR 100)
- `description` (TEXT)
- `ip_address` (VARCHAR 45)
- `timestamp` (TIMESTAMP)

#### `notifications`
- `id` (PRIMARY KEY)
- `user_id` (FOREIGN KEY → users)
- `task_id` (FOREIGN KEY → tasks)
- `message` (TEXT)
- `is_read` (BOOLEAN)
- `created_at` (TIMESTAMP)

---

## Audit Logging

Every action in the system is logged to the `audit_logs` table with:
- User ID
- Action performed
- Description of changes
- IP address
- Timestamp

Logged actions include:
- User login/logout
- User creation/update/deletion
- Task creation/update/deletion/status changes
- Category management
- Failed login attempts

Access to audit logs requires Admin role.

---

## Frontend Pages

### Public Pages
- `/login` - Login form (email/password)

### Authenticated Pages

#### Admin Pages
- `/dashboard` - Admin dashboard with system statistics
- `/users` - User management interface
- `/users/[id]` - User detail/edit page
- `/logs` - Audit logs viewer

#### Manager Pages
- `/dashboard` - Manager dashboard with team statistics
- `/tasks` - Task management
- `/tasks/[id]` - Task detail/edit
- `/notifications` - Task notifications

#### Member Pages
- `/dashboard` - Personal task dashboard
- `/tasks` - Assigned tasks list
- `/tasks/[id]` - Task detail (status update only)
- `/notifications` - Notifications

#### Universal Pages (All authenticated users)
- `/categories` - Category management
- Navigation with logout button on all pages

---

## Docker Setup

### Docker Compose Services

#### PostgreSQL
```yaml
container_name: postgres-tms
image: postgres:15-alpine
port: 5432
healthcheck: pg_isready
```

#### Backend
```yaml
container_name: backend-tms
image: php:8.3-fpm-alpine
port: 8082
depends_on: postgres (healthy)
environment: DB_CONNECTION=pgsql
```

#### Frontend
```yaml
container_name: frontend-tms
image: node:22-alpine
port: 9030
environment: NUXT_PUBLIC_API_URL=http://localhost:8082
```

#### Prometheus
```yaml
container_name: prometheus-tms
image: prom/prometheus:latest
port: 9090
config: prometheus.yml
```

#### Grafana
```yaml
container_name: grafana-tms
image: grafana/grafana:latest
port: 3000
datasource: Prometheus
```

### Critical Docker Rules

⚠️ **NEVER DO THE FOLLOWING:**
1. Do NOT use `docker-compose down` - it stops all containers including Jenkins
2. Do NOT mount `schema.sql` as a Docker volume - it becomes a directory
3. Do NOT use `http://backend:8080` in frontend - use `http://localhost:8082`
4. Do NOT recreate Jenkins container during deployment

✅ **ALWAYS DO:**
1. Use `docker-compose up -d --no-recreate` for deployment
2. Apply schema manually with `docker cp` and `docker exec psql`
3. Use localhost:8082 in frontend (browser can't resolve Docker hostnames)
4. Only remove/restart: postgres, backend, frontend, prometheus, grafana (NEVER jenkins)

---

## Jenkins CI/CD Pipeline

### Setup Jenkins

1. Build Jenkins image:
```bash
docker build -f Dockerfile.jenkins -t jenkins-tms:latest .
```

2. Run Jenkins container:
```bash
docker run -d \
  --name jenkins-tms \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /usr/local/bin/docker-compose:/usr/local/bin/docker-compose \
  -e JENKINS_OPTS="--logfile=/var/jenkins_home/jenkins.log" \
  jenkins-tms:latest
```

### Jenkinsfile Pipeline Stages

1. **Fix Docker Permissions**
   - Ensures Docker socket has correct permissions

2. **Clean Workspace**
   - Cleans up workspace for fresh build

3. **Checkout**
   - Pulls latest code from repository

4. **Build**
   - Builds all Docker images with `docker-compose build`

5. **Deploy**
   - Removes old containers (except jenkins-tms)
   - Starts PostgreSQL and waits for health check
   - Applies database schema manually
   - Ensures admin user exists (with ON CONFLICT)
   - Starts remaining services with --no-recreate

6. **Health Check**
   - Verifies backend health endpoint
   - Confirms services are operational

7. **Status**
   - Displays final container status

### Email Notifications

On success and failure, Jenkins sends emails to:
- Build requestor
- Developers
- Admin email (parameter)

---

## Configuration Files

### Environment Variables

**.env** (Backend):
```
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=tms
DB_USERNAME=tms_user
DB_PASSWORD=tms_password
APP_KEY=base64:xxxxx
SANCTUM_STATEFUL_DOMAINS=localhost:9030
```

**Frontend** (docker-compose):
```
NUXT_PUBLIC_API_URL=http://localhost:8082
```

### CORS Configuration

Configured to accept requests from:
- http://localhost:9030
- http://localhost:3000
- Wildcard allows all origins in development

Update `laravel/config/cors.php` for production.

---

## Monitoring & Metrics

### Prometheus Metrics

Backend exposes Prometheus metrics at `/metrics`:
- `tms_total_tasks` - Total number of tasks
- `tms_total_users` - Total number of users
- `tms_completed_tasks` - Number of completed tasks

### Grafana Dashboards

1. Create datasource pointing to Prometheus (http://prometheus-tms:9090)
2. Create dashboards to visualize:
   - Task completion rate
   - User activity
   - System performance

---

## Troubleshooting

### PostgreSQL Connection Issues
```bash
# Check PostgreSQL is healthy
docker-compose exec postgres pg_isready -U tms_user -d tms

# View PostgreSQL logs
docker-compose logs postgres
```

### Backend Not Starting
```bash
# Check backend logs
docker-compose logs backend

# Verify database connection
docker-compose exec backend php artisan tinker
> DB::connection()->getPdo();
```

### Frontend Can't Connect to Backend
```bash
# Verify API URL is correct
# Use http://localhost:8082 NOT http://backend:8080

# Check backend is running on port 8082
curl http://localhost:8082/api/health

# Check CORS headers
curl -H "Origin: http://localhost:9030" http://localhost:8082/api/health
```

### Schema Not Applied
```bash
# Manually apply schema
docker cp schema.sql postgres-tms:/schema.sql
docker-compose exec postgres psql -U tms_user -d tms -f /schema.sql

# Verify tables
docker-compose exec postgres psql -U tms_user -d tms -c "\\dt"
```

---

## Common Commands

```bash
# Start services
docker-compose up -d

# Stop services (without removing)
docker-compose stop

# View logs
docker-compose logs -f [service_name]

# Execute command in container
docker-compose exec [service] [command]

# Remove containers (keeps volumes)
docker-compose down

# Remove everything including volumes
docker-compose down -v

# Rebuild images
docker-compose build

# View container status
docker-compose ps
```

---

## Security Notes

1. **Passwords**: Default admin password should be changed immediately
2. **JWT Tokens**: Using Laravel Sanctum for token-based auth
3. **RBAC**: Implemented at controller level with role_id checks
4. **Audit Logging**: All actions logged with user, action, timestamp, IP
5. **CORS**: Configured for frontend origin - update for production
6. **Docker**: Jenkins container never recreated to maintain persistence

---

## Performance Optimization

1. **Database**: PostgreSQL with proper indexing
2. **Caching**: Implement Redis for session caching
3. **API**: Pagination on all list endpoints
4. **Frontend**: Nuxt static generation for deployments
5. **Monitoring**: Prometheus + Grafana for visibility

---

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Database schema applied
- [ ] Admin user created
- [ ] CORS origins updated
- [ ] Docker images built
- [ ] Jenkins pipeline configured
- [ ] Email notifications setup
- [ ] Monitoring dashboards created
- [ ] Health checks verified
- [ ] Security audit performed

---

For support and detailed documentation, refer to:
- [Architecture Documentation](ARCHITECTURE.md)
- [Build Summary](BUILD_SUMMARY.md)
- [Commands Reference](COMMANDS.md)
