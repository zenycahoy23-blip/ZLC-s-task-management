#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Task Management System - Setup Guide${NC}\n"

echo "1. Initialize project structure..."
mkdir -p laravel/{app,config,database/{migrations,seeders,factories},routes,resources/views,storage/{logs,framework/{cache,views,sessions}},bootstrap/cache,public,tests/Feature}
mkdir -p frontend/{pages,components,composables,middleware,layouts,public,server,utils,assets/css}
cp laravel/.env.example laravel/.env
cp frontend/.env.example frontend/.env
echo -e "${GREEN}✓ Project structure created${NC}\n"

echo "2. Generate Laravel app key..."
cd laravel
php artisan key:generate --quiet
echo -e "${GREEN}✓ App key generated${NC}\n"

echo "3. Running database migrations..."
php artisan migrate --force
echo -e "${GREEN}✓ Migrations completed${NC}\n"

echo "4. Seeding initial data..."
php artisan db:seed --force
echo -e "${GREEN}✓ Database seeded${NC}\n"

echo -e "${GREEN}✓ Setup complete!${NC}\n"

echo "Test credentials:"
echo "  Admin:   admin@tms.local / password"
echo "  Manager: manager@tms.local / password"
echo "  Member:  member@tms.local / password"
echo ""
echo "Start the application with: docker-compose up"
