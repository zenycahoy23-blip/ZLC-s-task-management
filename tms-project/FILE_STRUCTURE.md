# 📋 Task Management System - File Structure Reference

## Complete Project Layout

```
tms-project/
│
├── 📄 Documentation Files
│   ├── README.md                    ← START HERE: Full feature documentation
│   ├── QUICKSTART.md                ← 5-minute setup guide
│   ├── ARCHITECTURE.md              ← System design & API specification
│   ├── COMMANDS.md                  ← Useful Docker & Laravel commands
│   ├── BUILD_SUMMARY.md             ← What was built (summary)
│   └── PROJECT_CHECKLIST.md         ← This file
│
├── 🐳 Docker & Infrastructure
│   ├── docker-compose.yml           ← Multi-container orchestration
│   ├── nginx.conf                   ← Nginx reverse proxy config
│   ├── .gitignore                   ← Git ignore patterns
│   ├── setup.sh                     ← Database setup script
│   └── scaffold.sh                  ← Project structure script
│
├── 🚀 CI/CD Pipeline
│   └── .github/
│       └── workflows/
│           └── ci.yml               ← GitHub Actions workflow
│
├── 📦 Laravel Backend (laravel/)
│   ├── Dockerfile                   ← PHP-FPM container
│   ├── composer.json                ← PHP dependencies
│   ├── .env.example                 ← Environment template
│   │
│   ├── 📁 app/
│   │   ├── Models/
│   │   │   ├── User.php             ← User model with Sanctum & roles
│   │   │   ├── Task.php             ← Task model with activity logging
│   │   │   ├── Category.php         ← Category model
│   │   │   └── Notification.php     ← Notification model
│   │   │
│   │   └── Http/
│   │       ├── Controllers/
│   │       │   ├── AuthController.php       ← Auth endpoints
│   │       │   ├── TaskController.php       ← Task CRUD
│   │       │   ├── CategoryController.php   ← Category CRUD
│   │       │   ├── UserController.php       ← User management (admin)
│   │       │   ├── DashboardController.php  ← Dashboard data
│   │       │   ├── NotificationController.php ← Notifications
│   │       │   └── ActivityLogController.php  ← Audit logs
│   │       │
│   │       └── Middleware/
│   │           └── Authenticate.php ← Auth middleware
│   │
│   ├── 📁 database/
│   │   ├── migrations/
│   │   │   ├── 2024_01_01_000001_create_users_table.php
│   │   │   ├── 2024_01_01_000002_create_categories_table.php
│   │   │   ├── 2024_01_01_000003_create_tasks_table.php
│   │   │   └── 2024_01_01_000004_create_notifications_table.php
│   │   │
│   │   └── seeders/
│   │       ├── DatabaseSeeder.php   ← Main seeder
│   │       ├── RoleAndPermissionSeeder.php ← RBAC setup
│   │       ├── UserSeeder.php       ← Test users
│   │       └── CategorySeeder.php   ← Sample categories
│   │
│   ├── 📁 routes/
│   │   └── api.php                  ← All API routes (20+)
│   │
│   ├── 📁 resources/
│   │   └── views/
│   │       └── login.blade.php      ← Blade login view
│   │
│   └── 📁 tests/
│       └── Feature/
│           ├── AuthenticationTest.php ← Auth tests
│           └── TaskPermissionTest.php ← RBAC tests
│
├── 🎨 Nuxt Frontend (frontend/)
│   ├── Dockerfile                   ← Node 22 Alpine container
│   ├── nuxt.config.ts               ← Nuxt configuration
│   ├── tailwind.config.js           ← Tailwind configuration
│   ├── package.json                 ← Node dependencies
│   ├── .env.example                 ← Environment template
│   │
│   ├── 📁 pages/
│   │   ├── login.vue                ← Login page (guest only)
│   │   ├── register.vue             ← Register page (guest only)
│   │   ├── dashboard.vue            ← Dashboard (role-aware)
│   │   ├── notifications.vue        ← Notifications list
│   │   ├── tasks/
│   │   │   ├── index.vue            ← Tasks list with filters
│   │   │   └── _id.vue              ← Task detail/edit
│   │   ├── categories/
│   │   │   └── index.vue            ← Category management
│   │   ├── users/
│   │   │   └── index.vue            ← User management (admin)
│   │   └── logs/
│   │       └── index.vue            ← Activity logs (admin)
│   │
│   ├── 📁 composables/
│   │   ├── useAuth.ts               ← Auth state & methods
│   │   └── useApi.ts                ← Axios API client
│   │
│   ├── 📁 middleware/
│   │   ├── auth.ts                  ← Route guard for auth
│   │   └── guest.ts                 ← Route guard for guests
│   │
│   ├── 📁 assets/
│   │   └── css/
│   │       └── main.css             ← Global Tailwind styles
│   │
│   └── 📁 public/                   ← Static files
│
└── 📊 Environment Files
    ├── laravel/.env.example         ← Laravel env template
    └── frontend/.env.example        ← Nuxt env template
```

## Directory Statistics

| Directory | Files | Purpose |
|-----------|-------|---------|
| `laravel/app/Models` | 4 | Eloquent models |
| `laravel/app/Http/Controllers` | 7 | API controllers |
| `laravel/database/migrations` | 4 | Database schemas |
| `laravel/database/seeders` | 3 | Data seeders |
| `laravel/tests/Feature` | 2 | Feature tests |
| `frontend/pages` | 8 | Vue page components |
| `frontend/composables` | 2 | Reusable logic |
| `frontend/middleware` | 2 | Route guards |
| Root | 7 | Config & setup files |
| Documentation | 6 | Guides & references |
| **Total** | **50+** | **Complete TMS** |

## 🔍 File Purpose Guide

### Must Read (Documentation)
- `README.md` – Complete feature list and setup
- `QUICKSTART.md` – Fastest way to get running (5 min)
- `ARCHITECTURE.md` – System design and API details

### Configuration Files
- `docker-compose.yml` – Service orchestration
- `nginx.conf` – Web server setup
- `.env.example` files – Environment variables

### Backend Entry Points
- `laravel/routes/api.php` – All API routes
- `laravel/app/Http/Controllers/*` – Endpoint handlers
- `laravel/database/migrations/*` – Database schema

### Frontend Entry Points
- `frontend/pages/login.vue` – User entry point
- `frontend/pages/dashboard.vue` – Main app view
- `frontend/composables/useAuth.ts` – State management

### Key Files to Modify
| Task | File |
|------|------|
| Add API endpoint | `laravel/routes/api.php` |
| Create new page | Create in `frontend/pages/` |
| Add database table | Create migration in `laravel/database/migrations/` |
| Modify styling | Edit `frontend/assets/css/main.css` |
| Change permissions | Edit `laravel/database/seeders/RoleAndPermissionSeeder.php` |
| Add test | Create in `laravel/tests/Feature/` |

## 🚀 How Files Work Together

```
User Request
    ↓
Browser → frontend/pages/[route].vue
    ↓
frontend/composables/useApi.ts (Axios)
    ↓
HTTP Request to /api/[endpoint]
    ↓
Nginx (nginx.conf) routes to PHP-FPM
    ↓
laravel/routes/api.php (Route definition)
    ↓
laravel/app/Http/Controllers/[Controller].php (Logic)
    ↓
laravel/app/Models/[Model].php (Eloquent ORM)
    ↓
MySQL (via migrations schema)
    ↓
Response JSON → Browser
    ↓
frontend/pages component updates
```

## 📋 Common Tasks & Files

### To Add a New Feature
1. Create migration: `laravel/database/migrations/`
2. Create model: `laravel/app/Models/`
3. Create controller: `laravel/app/Http/Controllers/`
4. Add routes: `laravel/routes/api.php`
5. Create page: `frontend/pages/`
6. Add tests: `laravel/tests/Feature/`

### To Add a Database Table
1. `php artisan make:migration create_table_name`
2. Edit migration file
3. `php artisan migrate`

### To Add an API Endpoint
1. Create controller method
2. Add route to `api.php`
3. Add permission check if needed
4. Create Nuxt component to call it

### To Add a Frontend Page
1. Create `.vue` file in `frontend/pages/`
2. Add route guard if needed (reference `middleware/auth.ts`)
3. Import and use `useApi()` and `useAuth()` composables
4. Add navigation link to sidebar/navbar

## 🔐 Security-Related Files

| File | Purpose |
|------|---------|
| `laravel/app/Http/Middleware/Authenticate.php` | Auth enforcement |
| `laravel/database/seeders/RoleAndPermissionSeeder.php` | Permission definitions |
| `laravel/app/Http/Controllers/*` | Permission checks with `$this->authorize()` |
| `frontend/middleware/auth.ts` | Frontend route protection |
| `docker-compose.yml` | Port isolation & network security |

## 📚 Learning Path by Role

### DevOps/DevSecOps
1. `docker-compose.yml`
2. `.github/workflows/ci.yml`
3. `nginx.conf`
4. Documentation

### Backend Developer
1. `laravel/routes/api.php`
2. `laravel/app/Http/Controllers/`
3. `laravel/app/Models/`
4. `laravel/database/migrations/`

### Frontend Developer
1. `frontend/pages/login.vue`
2. `frontend/composables/useAuth.ts`
3. `frontend/composables/useApi.ts`
4. `frontend/middleware/auth.ts`

### QA / Tester
1. `laravel/tests/Feature/`
2. `.github/workflows/ci.yml`
3. API endpoints in `ARCHITECTURE.md`

### Product Manager
1. `README.md` (features)
2. `ARCHITECTURE.md` (API spec)
3. Frontend pages in `frontend/pages/`

## 🎯 Quick Navigation

```
Need to...                          → Go to...
─────────────────────────────────────────────────────
Run the system                      → QUICKSTART.md
Understand the architecture         → ARCHITECTURE.md
Find useful commands                → COMMANDS.md
Know what was built                 → BUILD_SUMMARY.md
Add a new API endpoint              → laravel/routes/api.php
Create a new page                   → frontend/pages/
Add a database table                → laravel/database/migrations/
Manage user permissions             → laravel/database/seeders/RoleAndPermissionSeeder.php
Write tests                         → laravel/tests/Feature/
Deploy to production                → ARCHITECTURE.md (Deployment section)
Fix a bug in frontend               → frontend/pages/ or frontend/composables/
Check CI/CD configuration           → .github/workflows/ci.yml
```

---

**Everything you need is here. Start with QUICKSTART.md! 🚀**
