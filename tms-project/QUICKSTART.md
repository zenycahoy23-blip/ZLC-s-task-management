# Quick Start Guide

## 5-Minute Setup

### Prerequisites
- Docker & Docker Compose installed
- Git
- ~2GB disk space

### Step 1: Clone & Enter Directory
```bash
cd tms-project
```

### Step 2: Start Docker Containers
```bash
docker-compose up --build
```

This will build and start:
- MySQL database on port 3306
- Laravel API on port 9000 (proxied via Nginx on 8000)
- Nuxt frontend on port 3000
- Nginx reverse proxy on port 8000

### Step 3: Initialize Database (In another terminal)

```bash
# Generate Laravel app key
docker-compose exec app php artisan key:generate

# Run migrations
docker-compose exec app php artisan migrate

# Seed sample data
docker-compose exec app php artisan db:seed
```

### Step 4: Access Application

Open your browser and navigate to:

- **Frontend**: http://localhost:3000
- **API**: http://localhost:8000/api/
- **Database Admin** (phpMyAdmin): http://localhost:8080

## Default Test Users

After seeding, use these credentials to login:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@tms.local | password |
| Manager | manager@tms.local | password |
| Member | member@tms.local | password |

## First Time Actions

1. **Login as Admin**
   - Visit http://localhost:3000
   - Enter admin@tms.local / password
   - You'll see the admin dashboard with system stats

2. **Create a Category**
   - Go to Categories (sidebar)
   - Click "Create Category"
   - Add "Development", "Testing", etc.

3. **Create a Task**
   - Go to Tasks
   - Click "Create Task"
   - Fill in title, description, priority, category
   - Assign to a team member

4. **Switch Users**
   - Logout and login as manager@tms.local
   - You'll see manager's dashboard
   - Try assigning and managing tasks

5. **Member View**
   - Logout and login as member@tms.local
   - See only assigned tasks
   - Update task status

## Useful Commands

```bash
# View logs
docker-compose logs -f app
docker-compose logs -f frontend
docker-compose logs -f db

# Run tests
docker-compose exec app php artisan test

# Reset database (warning: destructive)
docker-compose exec app php artisan migrate:fresh --seed

# Access database shell
docker-compose exec db mysql -utms_user -ptms_password -Dtms

# Access Laravel shell (tinker)
docker-compose exec app php artisan tinker
```

## Stop & Clean Up

```bash
# Stop containers (preserves data)
docker-compose down

# Stop and remove volumes (deletes data)
docker-compose down -v

# Remove unused Docker resources
docker system prune
```

## Troubleshooting

**Containers won't start?**
```bash
# Check if ports are in use
lsof -i :3000
lsof -i :8000
lsof -i :3306

# Try rebuilding
docker-compose up --build --force-recreate
```

**Database connection error?**
```bash
# Check MySQL is running
docker-compose ps db

# Check database credentials in laravel/.env
cat laravel/.env | grep DB_
```

**Can't access frontend?**
```bash
# Check Nuxt logs
docker-compose logs frontend

# Restart frontend container
docker-compose restart frontend
```

## Project Structure Overview

```
tms-project/
├── laravel/              # Laravel API (PHP 8.2)
│   ├── app/Models/       # Eloquent models
│   ├── app/Http/         # Controllers & middleware
│   ├── database/         # Migrations & seeders
│   └── routes/api.php    # API routes
├── frontend/             # Nuxt frontend (Vue 3)
│   ├── pages/            # Route components
│   ├── composables/      # Reusable logic
│   └── assets/css/       # Tailwind styles
├── docker-compose.yml    # Multi-container setup
├── nginx.conf            # Nginx reverse proxy
└── README.md             # Full documentation
```

## Key Features to Explore

### Admin Features
- Dashboard with system metrics
- User management
- Activity logs
- Task overview by status/priority

### Manager Features
- Create and assign tasks
- Manage categories
- Team task overview
- Identify overdue tasks

### Member Features
- View assigned tasks
- Update task status
- See upcoming deadlines
- View notifications

## API Examples

### Login
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@tms.local",
    "password": "password"
  }'
```

### Create Task
```bash
curl -X POST http://localhost:8000/api/tasks \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Fix bug in dashboard",
    "description": "Charts not rendering correctly",
    "priority": "high",
    "category_id": 1,
    "assigned_to": 2,
    "due_date": "2024-02-01 17:00:00"
  }'
```

### Get Tasks
```bash
curl -X GET "http://localhost:8000/api/tasks?status=todo&priority=high" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Next Steps

1. **Customize branding**
   - Update app name in Laravel config
   - Modify Tailwind colors in frontend

2. **Add more users**
   - Login as admin
   - Go to Users page
   - Create new team members

3. **Set email notifications**
   - Update MAIL_* variables in `.env`
   - Configure scheduled tasks

4. **Deploy to production**
   - See ARCHITECTURE.md for deployment guide

## Getting Help

- Check **README.md** for full documentation
- See **ARCHITECTURE.md** for system design
- Review **COMMANDS.md** for useful commands
- Check **logs** with `docker-compose logs -f`

## What's Next?

The system is ready for development! Here are some ideas:

- [ ] Add file attachments to tasks
- [ ] Implement real-time notifications with WebSockets
- [ ] Create mobile app
- [ ] Add task templates
- [ ] Implement task comments
- [ ] Add calendar view
- [ ] Create team collaboration features
- [ ] Build advanced reporting

---

**Happy task managing! 🚀**

For issues or questions, open an issue on GitHub or check the documentation files.
