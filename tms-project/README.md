# Task Management System (TMS)

A full-stack task management system built with Laravel 11, Nuxt 4, MySQL, and Docker. Features role-based access control (RBAC), audit logging, and collaborative task management.

## Features

- **Role-Based Access Control** – Admin, Manager, and Member roles with specific permissions
- **Task Management** – Create, assign, and track tasks with priority and status
- **Categories** – Organize tasks by category
- **Notifications** – In-app notifications for task assignments and status changes
- **Audit Logging** – Track all user actions with detailed activity logs
- **Deadline Alerts** – Scheduled notifications for approaching and overdue tasks
- **Dashboard** – Role-aware dashboards with task metrics and insights
- **Responsive UI** – Built with Tailwind CSS and Nuxt 4

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | Laravel 11, PHP 8.2+ |
| Frontend | Nuxt 4, Vue 3, Tailwind CSS |
| Database | MySQL 8 |
| Authentication | Laravel Sanctum |
| RBAC | spatie/laravel-permission |
| Audit Logs | spatie/laravel-activitylog |
| Containerization | Docker, docker-compose |

## Project Structure

```
tms-project/
├── laravel/                    # Laravel API backend
│   ├── app/
│   │   ├── Models/            # Eloquent models
│   │   └── Http/
│   │       ├── Controllers/   # API controllers
│   │       └── Middleware/    # Custom middleware
│   ├── database/
│   │   ├── migrations/        # Database migrations
│   │   └── seeders/           # Database seeders
│   ├── routes/api.php         # API routes
│   └── Dockerfile
├── frontend/                   # Nuxt frontend
│   ├── pages/                 # Page components
│   ├── composables/           # Reusable composables
│   ├── middleware/            # Route middleware
│   ├── assets/css/            # Tailwind styles
│   └── Dockerfile
├── docker-compose.yml         # Multi-container orchestration
├── nginx.conf                 # Nginx configuration
└── .env.example               # Environment template
```

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Git

### Installation

1. **Clone and navigate to project**
   ```bash
   git clone <repo>
   cd tms-project
   ```

2. **Build and start containers**
   ```bash
   docker-compose up --build
   ```

3. **Run setup in Laravel container**
   ```bash
   docker-compose exec app bash setup.sh
   ```

   Or manually:
   ```bash
   docker-compose exec app php artisan key:generate
   docker-compose exec app php artisan migrate
   docker-compose exec app php artisan db:seed
   ```

4. **Access the application**
   - Frontend: http://localhost:3000
   - API: http://localhost:8000
   - phpMyAdmin: http://localhost:8080

## Test Credentials

```
Admin:   admin@tms.local / password
Manager: manager@tms.local / password
Member:  member@tms.local / password
```

## API Endpoints

### Authentication
- `POST /api/register` – Register new user
- `POST /api/login` – Login and get token
- `POST /api/logout` – Logout
- `GET /api/user` – Get current user

### Tasks
- `GET /api/tasks` – List tasks (filtered by role)
- `POST /api/tasks` – Create task (admin/manager)
- `GET /api/tasks/{id}` – Get task details
- `PUT /api/tasks/{id}` – Update task
- `DELETE /api/tasks/{id}` – Delete task

### Categories
- `GET /api/categories` – List categories
- `POST /api/categories` – Create category (admin/manager)
- `PUT /api/categories/{id}` – Update category
- `DELETE /api/categories/{id}` – Delete category

### Users (Admin)
- `GET /api/users` – List users
- `POST /api/users` – Create user
- `PUT /api/users/{id}` – Update user
- `PUT /api/users/{id}/role` – Assign role

### Dashboard
- `GET /api/dashboard` – Get role-aware dashboard data

### Notifications
- `GET /api/notifications` – List user notifications
- `PUT /api/notifications/{id}/read` – Mark as read
- `GET /api/notifications/unread-count` – Get unread count

### Logs (Admin)
- `GET /api/logs` – List activity logs

## Frontend Pages

| Page | Role | Purpose |
|------|------|---------|
| `/login` | Guest | User login |
| `/register` | Guest | User registration |
| `/dashboard` | All | Role-aware dashboard |
| `/tasks` | All | Task list with filters |
| `/tasks/[id]` | All | Task detail and edit |
| `/categories` | Manager+ | Manage categories |
| `/users` | Admin | Manage users |
| `/notifications` | All | View notifications |
| `/logs` | Admin | View activity logs |

## Database Schema

### users
- id, name, email (unique), password, timestamps

### roles (spatie/laravel-permission)
- id, name (admin, manager, member), timestamps

### permissions (spatie/laravel-permission)
- manage-users, create-task, assign-task, update-task-status, update-task, delete-task, view-all-tasks, view-own-tasks, manage-categories, view-logs

### categories
- id, category_name, description, timestamps

### tasks
- id, title, description, status (enum), priority (enum), category_id (FK), assigned_to (FK), created_by (FK), due_date, timestamps

### notifications
- id, user_id (FK), task_id (FK), message, is_read (bool), created_at

### activity_log (spatie/laravel-activitylog)
- id, causer_id, subject_id, subject_type, event, properties (JSON), created_at

## Role-Based Permissions

### Admin
- Manage users and roles
- View all tasks and activity logs
- Create, update, delete tasks
- Manage categories

### Manager
- Create and assign tasks to team members
- View team performance and overdue tasks
- Update task status and properties
- Manage categories
- View own activity logs

### Member
- View assigned tasks
- Update task status (mark as todo/in_progress/done)
- View notifications and assigned deadlines
- Cannot create or delete tasks

## Environment Variables

### Laravel (.env)
```
APP_NAME="Task Management System"
APP_ENV=local
APP_DEBUG=true
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=tms
DB_USERNAME=tms_user
DB_PASSWORD=tms_password
SANCTUM_STATEFUL_DOMAINS=localhost:3000,localhost:8000
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=cliffe026@gmail.com
MAIL_PASSWORD=hluicocpimgxpgwf
MAIL_ENCRYPTION=tls
```

### Nuxt (.env)
```
VITE_API_URL=http://localhost:8000
VITE_API_BASE_PATH=/api
```

## Common Commands

### Docker
```bash
# Start containers
docker-compose up

# Stop containers
docker-compose down

# View logs
docker-compose logs -f app
docker-compose logs -f frontend

# Access container shell
docker-compose exec app bash
docker-compose exec frontend sh
```

### Laravel
```bash
# Create migration
php artisan make:migration create_table_name

# Create model
php artisan make:model ModelName

# Create controller
php artisan make:controller ControllerName

# Run migrations
php artisan migrate

# Seed database
php artisan db:seed

# Create admin user
php artisan tinker
# User::create(['name'=>'Admin','email'=>'admin@local','password'=>bcrypt('password')])->assignRole('admin')
```

### Nuxt
```bash
# Build for production
npm run build

# Generate static site
npm run generate

# Preview production build
npm run preview
```

## Testing

```bash
# Run Laravel tests
docker-compose exec app php artisan test

# Run feature tests for auth and RBAC
docker-compose exec app php artisan test tests/Feature
```

## Deployment

The application is configured for local development. For production deployment:

1. Update environment variables in `.env`
2. Set `APP_DEBUG=false`
3. Use `compose.prod.yaml` with optimized Dockerfile stages
4. Configure a production database (managed MySQL service)
5. Set up SSL/TLS with Let's Encrypt
6. Configure CI/CD with GitHub Actions (`.github/workflows/`)
7. Deploy to Kubernetes or Docker Swarm

## Optional Enhancements

- [ ] Email notifications for task deadlines
- [ ] Real-time notifications with WebSockets
- [ ] Task comments and collaboration
- [ ] File attachments to tasks
- [ ] Team management and sub-teams
- [ ] Advanced reporting and analytics
- [ ] Mobile app (React Native / Flutter)
- [ ] API rate limiting and throttling
- [ ] Two-factor authentication (2FA)
- [ ] Dark mode UI theme

## Troubleshooting

### Containers won't start
```bash
# Check Docker daemon is running
docker ps

# Review logs
docker-compose logs

# Rebuild images
docker-compose up --build
```

### Database connection error
```bash
# Ensure MySQL container is healthy
docker-compose ps

# Check MySQL logs
docker-compose logs db

# Verify .env database credentials
```

### API 401 Unauthorized
- Ensure token is being sent in `Authorization: Bearer <token>` header
- Token may have expired; re-login
- Check CORS configuration in Laravel

### Frontend won't load
- Verify Nuxt container is running: `docker-compose ps frontend`
- Check network: `docker network inspect tms_tms`
- Clear browser cache and local storage

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is open source and available under the MIT License.

## Support

For issues, feature requests, or questions:
- Open an issue on GitHub
- Check existing issues for solutions
- Contact: support@example.com
