#!/bin/bash

# Task Management System - Comprehensive Initialization
# Auto-detects missing components and initializes the system

set +e  # Don't exit on errors, we want to catch them and report

# ============================================
# COLORS & UTILITIES
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}!${NC} $1"; }
log_info() { echo -e "${BLUE}→${NC} $1"; }
log_header() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

# ============================================
# ERROR TRACKING
# ============================================
ERRORS=()
WARNINGS=()
MISSING=()

add_error() { ERRORS+=("$1"); log_error "$1"; }
add_warning() { WARNINGS+=("$1"); log_warning "$1"; }
add_missing() { MISSING+=("$1"); log_warning "MISSING: $1"; }

# ============================================
# STARTUP
# ============================================
log_header "TMS - Automatic Initialization & Health Check"
log_info "Starting initialization sequence..."

# ============================================
# PHASE 1: WAIT FOR DATABASE
# ============================================
log_header "PHASE 1: Database Connection"

DB_HOST="db"
DB_PORT="3306"
DB_USER="tms_user"
DB_PASS="tms_password"
DB_NAME="tms"
RETRY=0
MAX_RETRIES=60

log_info "Waiting for MySQL at $DB_HOST:$DB_PORT..."

while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --silent 2>/dev/null; do
    RETRY=$((RETRY + 1))
    if [ $RETRY -ge $MAX_RETRIES ]; then
        add_error "Database connection failed after $MAX_RETRIES attempts"
        break
    fi
    echo -n "."
    sleep 1
done

if [ $RETRY -lt $MAX_RETRIES ]; then
    log_success "Database connection established (${RETRY}s)"
else
    add_error "Cannot connect to database at $DB_HOST:$DB_PORT"
fi

# ============================================
# PHASE 2: FILE STRUCTURE CHECK
# ============================================
log_header "PHASE 2: File Structure Verification"

# Check critical files
CRITICAL_FILES=(
    ".env"
    "artisan"
    "composer.json"
    "composer.lock"
    "bootstrap/app.php"
    "public/index.php"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "/var/www/$file" ]; then
        log_success "File exists: $file"
    else
        add_missing "Critical file missing: $file"
    fi
done

# Check critical directories
CRITICAL_DIRS=(
    "app"
    "config"
    "database"
    "database/migrations"
    "database/seeders"
    "routes"
    "storage"
    "bootstrap/cache"
)

for dir in "${CRITICAL_DIRS[@]}"; do
    if [ -d "/var/www/$dir" ]; then
        log_success "Directory exists: $dir"
    else
        add_missing "Critical directory missing: $dir"
    fi
done

# ============================================
# PHASE 3: DEPENDENCIES CHECK
# ============================================
log_header "PHASE 3: Dependencies Verification"

# Check PHP extensions
PHP_EXTENSIONS=("pdo_mysql" "zip" "bcmath" "json" "ctype" "fileinfo")
for ext in "${PHP_EXTENSIONS[@]}"; do
    if php -m | grep -qi "$ext"; then
        log_success "PHP extension installed: $ext"
    else
        add_missing "PHP extension not installed: $ext"
    fi
done

# Check vendor directory
if [ ! -d "/var/www/vendor" ]; then
    add_warning "Vendor directory not found - installing composer dependencies"
    cd /var/www
    
    log_info "Running: composer install --no-interaction --optimize-autoloader --no-dev"
    composer install --no-interaction --optimize-autoloader --no-dev 2>&1 | tail -5
    
    if [ $? -eq 0 ]; then
        log_success "Composer dependencies installed"
    else
        add_error "Composer installation failed"
    fi
else
    log_success "Vendor directory exists"
    
    # Check key composer packages
    COMPOSER_PACKAGES=("laravel/framework" "laravel/sanctum" "spatie/laravel-permission" "spatie/laravel-activitylog")
    for package in "${COMPOSER_PACKAGES[@]}"; do
        if [ -d "/var/www/vendor/${package%/*}" ]; then
            log_success "Composer package installed: $package"
        else
            add_warning "Composer package may be missing: $package"
        fi
    done
fi

# ============================================
# PHASE 4: LARAVEL CONFIGURATION
# ============================================
log_header "PHASE 4: Laravel Configuration"

cd /var/www

# Check .env file
if [ ! -f ".env" ]; then
    add_error ".env file not found"
else
    log_success ".env file exists"
    
    # Check .env values
    if grep -q "APP_KEY=base64:" .env; then
        log_success "APP_KEY is configured"
    else
        log_warning "APP_KEY not properly configured - generating..."
        php artisan key:generate --force 2>/dev/null
        if [ $? -eq 0 ]; then
            log_success "APP_KEY generated"
        else
            add_error "Failed to generate APP_KEY"
        fi
    fi
    
    # Check database config in .env
    if grep -q "DB_HOST=db" .env; then
        log_success "Database host configured (db)"
    else
        add_warning "Database host not set to 'db' in .env"
    fi
fi

# Check if app is runnable
if php artisan list > /dev/null 2>&1; then
    log_success "Laravel artisan commands available"
else
    add_error "Laravel artisan commands not available"
fi

# ============================================
# PHASE 5: DATABASE SCHEMA
# ============================================
log_header "PHASE 5: Database Schema"

# Check if database exists
if mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME;" 2>/dev/null; then
    log_success "Database '$DB_NAME' exists"
else
    add_warning "Database '$DB_NAME' not accessible"
fi

# Check migrations
log_info "Checking migration status..."
MIGRATION_STATUS=$(php artisan migrate:status --no-ansi 2>&1)

if echo "$MIGRATION_STATUS" | grep -q "Pending"; then
    add_warning "Pending migrations detected - running migrations"
    
    log_info "Running: php artisan migrate --force"
    php artisan migrate --force --no-interaction 2>&1 | tail -10
    
    if [ $? -eq 0 ]; then
        log_success "Migrations completed successfully"
    else
        add_error "Migration execution failed"
    fi
elif echo "$MIGRATION_STATUS" | grep -q "Migration name"; then
    log_success "All migrations already applied"
else
    log_info "Running initial migrations..."
    php artisan migrate --force --no-interaction 2>&1 | tail -10
    
    if [ $? -eq 0 ]; then
        log_success "Initial migrations completed"
    else
        add_error "Initial migration failed"
    fi
fi

# ============================================
# PHASE 6: DATABASE TABLES CHECK
# ============================================
log_header "PHASE 6: Database Tables"

REQUIRED_TABLES=("users" "tasks" "categories" "permissions" "roles" "role_has_permissions" "model_has_roles")

for table in "${REQUIRED_TABLES[@]}"; do
    if mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES LIKE '$table';" 2>/dev/null | grep -q "$table"; then
        # Get row count
        COUNT=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM $table;" 2>/dev/null | tail -1)
        log_success "Table '$table' exists (${COUNT:-0} rows)"
    else
        add_missing "Required table missing: $table"
    fi
done

# ============================================
# PHASE 7: DATA SEEDING
# ============================================
log_header "PHASE 7: Database Seeding"

# Check if users exist
USER_COUNT=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM users;" 2>/dev/null | tail -1)

if [ "$USER_COUNT" -lt 3 ]; then
    add_warning "Only $USER_COUNT users found - seeding test data"
    
    log_info "Running: php artisan db:seed"
    php artisan db:seed --force --no-interaction 2>&1 | tail -10
    
    if [ $? -eq 0 ]; then
        log_success "Database seeding completed"
        USER_COUNT=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM users;" 2>/dev/null | tail -1)
    else
        add_warning "Database seeding completed with warnings"
    fi
else
    log_success "Database already seeded ($USER_COUNT users found)"
fi

# ============================================
# PHASE 8: PERMISSIONS & OWNERSHIP
# ============================================
log_header "PHASE 8: File Permissions"

log_info "Setting storage permissions..."
chmod -R 755 /var/www/storage /var/www/bootstrap/cache 2>/dev/null
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache 2>/dev/null

if [ -w /var/www/storage ]; then
    log_success "Storage directory is writable"
else
    add_warning "Storage directory may not be writable"
fi

# ============================================
# PHASE 9: HEALTH CHECKS
# ============================================
log_header "PHASE 9: Health Checks"

# Laravel health
if php artisan about --only=environment --no-ansi > /dev/null 2>&1; then
    log_success "Laravel framework operational"
else
    add_error "Laravel framework health check failed"
fi

# Database health
DB_TEST=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT 1;" 2>&1)
if [ $? -eq 0 ]; then
    log_success "Database operational"
else
    add_error "Database health check failed"
fi

# ============================================
# PHASE 10: SUMMARY REPORT
# ============================================
log_header "INITIALIZATION SUMMARY"

# System Information
log_info "System Information:"
echo "  PHP Version: $(php --version | head -1)"
echo "  Laravel Version: $(php artisan --version 2>/dev/null || echo 'Unknown')"
echo "  Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo "  Users: $USER_COUNT"

TASK_COUNT=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SELECT COUNT(*) FROM tasks;" 2>/dev/null | tail -1)
echo "  Tasks: $TASK_COUNT"

# Error Summary
log_header "STATUS REPORT"

if [ ${#ERRORS[@]} -eq 0 ] && [ ${#MISSING[@]} -eq 0 ]; then
    log_success "All checks passed! System is ready."
    STATUS="✓ READY"
else
    if [ ${#ERRORS[@]} -gt 0 ]; then
        log_error "Found ${#ERRORS[@]} critical error(s):"
        for err in "${ERRORS[@]}"; do
            echo "  - $err"
        done
    fi
    
    if [ ${#MISSING[@]} -gt 0 ]; then
        log_warning "Found ${#MISSING[@]} missing component(s):"
        for miss in "${MISSING[@]}"; do
            echo "  - $miss"
        done
    fi
    
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        log_warning "Found ${#WARNINGS[@]} warning(s):"
        for warn in "${WARNINGS[@]}"; do
            echo "  - $warn"
        done
    fi
    
    if [ ${#ERRORS[@]} -gt 0 ]; then
        STATUS="✗ ERRORS"
    else
        STATUS="⚠ WARNINGS"
    fi
fi

echo ""
log_info "Final Status: $STATUS"
echo ""

log_header "ACCESS INFORMATION"
echo "Frontend:      http://localhost:3000"
echo "API:           http://localhost:8000/api"
echo "Jenkins:       http://localhost:8080"
echo ""
echo "Test Credentials:"
echo "  admin@tms.local / password"
echo "  manager@tms.local / password"
echo "  member@tms.local / password"
echo ""

log_header "Ready to start PHP-FPM"

# ============================================
# START PHP-FPM
# ============================================
exec php-fpm
