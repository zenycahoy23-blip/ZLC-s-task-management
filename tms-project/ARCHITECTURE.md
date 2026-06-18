# Task Management System - Architecture & Setup Guide

## Overview

The Task Management System (TMS) is a full-stack web application for managing team tasks with role-based access control, audit logging, and collaborative features. The system is containerized with Docker and designed for easy local development and deployment.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Browser                            │
└─────────────────┬───────────────────────────────────────────┘
                  │ HTTP/HTTPS
┌─────────────────▼───────────────────────────────────────────┐
│              Nuxt 4 Frontend (Port 3000)                     │
│  - Vue 3 Components                                          │
│  - Tailwind CSS Styling                                      │
│  - Axios API Client with Interceptors                        │
│  - Route Guards (Auth Middleware)                            │
└─────────────────┬───────────────────────────────────────────┘
                  │ REST API Calls (/api/*)
┌─────────────────▼───────────────────────────────────────────┐
│              Nginx Reverse Proxy (Port 8000)                 │
│  - Routes /api/* to PHP-FPM                                  │
│  - Static file serving                                       │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│            Laravel 11 API Backend (Port 9000)                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ HTTP Controllers                                     │   │
│  │ - AuthController                                     │   │
│  │ - TaskController                                     │   │
│  │ - CategoryController                                 │   │
│  │ - UserController                                     │   │
│  │ - DashboardController                                │   │
│  │ - NotificationController                             │   │
│  │ - ActivityLogController                              │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Middleware & Services                                │   │
│  │ - Sanctum Authentication                             │   │
│  │ - spatie/laravel-permission (RBAC)                   │   │
│  │ - spatie/laravel-activitylog                          │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Eloquent Models                                      │   │
│  │ - User, Task, Category, Notification                 │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────┬───────────────────────────────────────────┘
                  │ MySQL Queries
┌─────────────────▼───────────────────────────────────────────┐
│         MySQL 8 Database (Port 3306)                         │
│  Tables: users, roles, permissions, tasks, categories,       │
│          notifications, activity_log, etc.                   │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Authentication Flow

```
User → Nuxt Login Page
    ↓
POST /api/login (email, password)
    ↓
AuthController::login
    ↓
Hash::check() validation
    ↓
Generate Sanctum Token
    ↓
Return: {user, token}
    ↓
Nuxt stores token in localStorage
    ↓
All subsequent requests include: Authorization: Bearer <token>
```

### 2. Task Creation Flow

```
Manager → Nuxt Task Form
    ↓
POST /api/tasks {title, description, priority, assigned_to}
    ↓
TaskController::store
    ↓
Permission check (authorize 'create-task')
    ↓
TaskModel::create() → Database
    ↓
Activity Log created (spatie/laravel-activitylog)
    ↓
Notification created for assigned user
    ↓
Return: Created Task JSON
    ↓
Nuxt receives & displays confirmation
```

### 3. Notification Flow

```
Task Status Changed
    ↓
TaskController::update
    ↓
Activity logged
    ↓
Check if status changed & create Notification record
    ↓
Nuxt polls GET /api/notifications/unread-count periodically
    ↓
Display unread badge
    ↓
User clicks notifications → GET /api/notifications
    ↓
Display all notifications with timestamps
    ↓
User marks as read → PUT /api/notifications/{id}/read
```

## Role-Based Access Control (RBAC)

### Permission Matrix

| Permission | Admin | Manager | Member |
|-----------|-------|---------|--------|
| manage-users | ✓ | | |
| create-task | ✓ | ✓ | |
| assign-task | ✓ | ✓ | |
| update-task | ✓ | ✓ | |
| update-task-status | ✓ | ✓ | ✓ |
| delete-task | ✓ | ✓ | |
| view-all-tasks | ✓ | ✓ | |
| view-own-tasks | ✓ | ✓ | ✓ |
| manage-categories | ✓ | ✓ | |
| view-logs | ✓ | | |

### Implementation

```php
// In Controller
$this->authorize('create-task');

// In Model Policy (optional)
public function create(User $user): bool
{
    return $user->hasPermissionTo('create-task');
}

// In Middleware (optional)
Route::middleware(['auth:sanctum', 'permission:view-all-tasks'])
    ->get('/tasks', [TaskController::class, 'index']);
```

## Database Schema

### Core Tables

#### users
```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  password VARCHAR(255),
  email_verified_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

#### tasks
```sql
CREATE TABLE tasks (
  id BIGINT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status ENUM('todo', 'in_progress', 'done') DEFAULT 'todo',
  priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
  category_id BIGINT FOREIGN KEY,
  assigned_to BIGINT FOREIGN KEY users(id),
  created_by BIGINT FOREIGN KEY users(id),
  due_date DATETIME,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  INDEX (status, priority, assigned_to, created_by)
);
```

#### categories
```sql
CREATE TABLE categories (
  id BIGINT PRIMARY KEY,
  category_name VARCHAR(255),
  description TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

#### notifications
```sql
CREATE TABLE notifications (
  id BIGINT PRIMARY KEY,
  user_id BIGINT FOREIGN KEY,
  task_id BIGINT FOREIGN KEY,
  message VARCHAR(255),
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP,
  INDEX (user_id, is_read)
);
```

#### activity_log (spatie/laravel-activitylog)
```sql
CREATE TABLE activity_log (
  id BIGINT PRIMARY KEY,
  log_name VARCHAR(255),
  description VARCHAR(255),
  subject_type VARCHAR(255),
  subject_id BIGINT,
  causer_type VARCHAR(255),
  causer_id BIGINT,
  properties LONGTEXT (JSON),
  created_at TIMESTAMP,
  INDEX (causer_id, subject_type)
);
```

## API Specification

### Authentication Endpoints

```
POST   /api/register
  Body: { name, email, password, password_confirmation }
  Response: { user, message }

POST   /api/login
  Body: { email, password }
  Response: { user, token }

POST   /api/logout
  Headers: Authorization: Bearer <token>
  Response: { message }

GET    /api/user
  Headers: Authorization: Bearer <token>
  Response: User object with roles & permissions
```

### Task Endpoints

```
GET    /api/tasks
  Query: ?status=todo&priority=high&category_id=1&assigned_to=2&due_date=2024-01-15
  Response: Paginated task list

POST   /api/tasks
  Headers: Authorization: Bearer <token>
  Body: { title, description, priority, category_id, assigned_to, due_date }
  Response: Created task object

GET    /api/tasks/{id}
  Response: Task object with relations

PUT    /api/tasks/{id}
  Body: { title, description, status, priority, category_id, assigned_to, due_date }
  Response: Updated task object

DELETE /api/tasks/{id}
  Response: { message: "Task deleted" }
```

### Additional Endpoints

```
GET    /api/categories                    # List all
POST   /api/categories                    # Create (manager+)
PUT    /api/categories/{id}               # Update (manager+)
DELETE /api/categories/{id}               # Delete (manager+)

GET    /api/users                         # List all (admin)
POST   /api/users                         # Create (admin)
PUT    /api/users/{id}                    # Update (admin)
PUT    /api/users/{id}/role               # Change role (admin)

GET    /api/dashboard                     # Role-aware summary

GET    /api/notifications                 # User's notifications
PUT    /api/notifications/{id}/read       # Mark as read
GET    /api/notifications/unread-count    # Unread count

GET    /api/logs                          # Activity logs (admin)
```

## Frontend Architecture

### Component Tree

```
App.vue
├── Login.vue (guest only)
├── Register.vue (guest only)
├── Layout.vue (authenticated)
│   ├── Navbar.vue
│   │   ├── NotificationBell.vue
│   │   └── UserMenu.vue
│   ├── Sidebar.vue
│   └── RouterView
│       ├── Dashboard.vue
│       ├── Tasks/
│       │   ├── Index.vue
│       │   └── [id].vue
│       ├── Categories.vue
│       ├── Users.vue (admin)
│       ├── Notifications.vue
│       └── Logs.vue (admin)
```

### State Management (Composables)

```typescript
useAuth()
  ├── user (ref)
  ├── token (ref)
  ├── isAuthenticated()
  ├── login(email, password)
  ├── logout()
  └── fetchUser()

useApi()
  ├── instance (axios)
  ├── interceptors
  │   ├── request (add Authorization header)
  │   └── response (handle 401)
  └── GET, POST, PUT, DELETE methods
```

### Route Guards

```typescript
// middleware/auth.ts
- Checks if authenticated
- Redirects to /login if not
- Refreshes user from API

// middleware/guest.ts
- Redirects authenticated users away from /login
```

## Security Considerations

1. **Authentication**
   - Sanctum token-based API authentication
   - Tokens stored in localStorage (vulnerable to XSS - use httpOnly cookies in production)
   - CORS configured to allow only frontend origin

2. **Authorization**
   - spatie/laravel-permission provides fine-grained access control
   - Every API endpoint checks permissions
   - Database policies enforce rules

3. **Data Validation**
   - Laravel Form Request validation
   - Frontend client-side validation
   - Sanitization of user inputs

4. **Audit Logging**
   - spatie/laravel-activitylog tracks all changes
   - Includes causer, subject, event, and property changes
   - Accessible only to admins

5. **Rate Limiting** (to implement)
   - throttle middleware on auth endpoints
   - Prevent brute force attacks

## Deployment Considerations

### Development
- Single docker-compose file with all services
- Hot reload enabled
- Debug mode on

### Production
- Separate production Dockerfile with multi-stage builds
- Environment variables from .env
- Database backups and monitoring
- SSL/TLS certificates (Let's Encrypt)
- CI/CD pipeline with GitHub Actions
- Horizontal scaling with Kubernetes or Docker Swarm

## Performance Optimization

1. **Database**
   - Indexes on frequently queried columns (status, priority, assigned_to)
   - Eager loading with ->with('category', 'assignee')
   - Pagination for large datasets

2. **Caching**
   - Redis cache for dashboard metrics
   - Query result caching

3. **Frontend**
   - Code splitting and lazy loading
   - Image optimization
   - Minification and tree-shaking

4. **API**
   - Response pagination (default 15 items)
   - Selective field loading with ?fields=id,name

## Monitoring & Logging

- Laravel logs: `laravel/storage/logs/laravel.log`
- Docker logs: `docker-compose logs -f`
- Activity log: `activity_log` table in database
- Error tracking: (integrate Sentry or similar)
- Performance monitoring: (integrate New Relic or similar)

## Development Workflow

1. Create feature branch
2. Make changes in containers
3. Run tests: `docker-compose exec app php artisan test`
4. Commit with descriptive message
5. Push and create pull request
6. CI/CD runs tests and builds
7. After review, merge to main
8. CI/CD deploys to production

## Troubleshooting

### Common Issues

**Containers won't start**
- Check if ports are in use: `lsof -i :3000`, `lsof -i :8000`
- Rebuild images: `docker-compose up --build`

**Database connection error**
- Ensure MySQL is running: `docker-compose ps`
- Check credentials in `.env`
- Verify network: `docker network ls`

**API 401 Unauthorized**
- Token expired - re-login
- Token not sent correctly in header
- Check CORS configuration

**Frontend won't load**
- Verify Nuxt container is running
- Check browser console for errors
- Clear cache: `docker-compose logs frontend`

## Next Steps

1. Implement email notifications for overdue tasks
2. Add WebSocket support for real-time updates
3. Create mobile app (React Native/Flutter)
4. Add advanced reporting and analytics
5. Implement file attachments to tasks
6. Add team management features
7. Implement two-factor authentication
8. Set up automated backups
9. Create monitoring dashboard
10. Performance optimization and load testing
