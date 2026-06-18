# Production Deployment Guide

This guide covers deploying the Task Management System to production environments.

## Pre-Deployment Checklist

- [ ] All tests passing: `php artisan test`
- [ ] Environment variables configured
- [ ] Database backups scheduled
- [ ] SSL/TLS certificates obtained
- [ ] CI/CD pipeline working
- [ ] Security audit completed
- [ ] Performance testing done
- [ ] Monitoring configured

## 1. Environment Configuration

### Create `.env.production` (Laravel)

```env
APP_NAME="Task Management System"
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:...                    # Generate with: php artisan key:generate
APP_URL=https://tms.yourdomain.com

LOG_CHANNEL=stack
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=your-db-host.rds.amazonaws.com
DB_PORT=3306
DB_DATABASE=tms_prod
DB_USERNAME=tms_prod_user
DB_PASSWORD=secure_password_here

CACHE_DRIVER=redis
CACHE_HOST=your-redis-host
CACHE_PASSWORD=redis_password

SANCTUM_STATEFUL_DOMAINS=tms.yourdomain.com
SANCTUM_DOMAIN=tms.yourdomain.com

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=app_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME="Task Management System"
```

### Create `.env.production` (Nuxt)

```env
VITE_API_URL=https://api.yourdomain.com
VITE_API_BASE_PATH=/api
```

## 2. Docker Production Setup

### Create `compose.prod.yaml`

```yaml
version: '3.8'

services:
  db:
    image: mysql:8-alpine
    container_name: tms_db_prod
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_USER: ${DB_USERNAME}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_prod:/var/lib/mysql
    networks:
      - tms_prod
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    build:
      context: ./laravel
      dockerfile: Dockerfile.prod
    container_name: tms_app_prod
    restart: always
    depends_on:
      db:
        condition: service_healthy
    environment:
      APP_ENV: production
      APP_DEBUG: "false"
      DB_HOST: db
      DB_DATABASE: ${DB_DATABASE}
      DB_USERNAME: ${DB_USERNAME}
      DB_PASSWORD: ${DB_PASSWORD}
    volumes:
      - ./laravel:/var/www
      - app_storage:/var/www/storage
    networks:
      - tms_prod
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    container_name: tms_frontend_prod
    restart: always
    environment:
      VITE_API_URL: https://api.yourdomain.com
    volumes:
      - ./frontend/dist:/app/dist
    networks:
      - tms_prod

  nginx:
    image: nginx:alpine
    container_name: tms_nginx_prod
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./laravel:/var/www
      - ./nginx.prod.conf:/etc/nginx/nginx.conf:ro
      - ./certs/fullchain.pem:/etc/nginx/ssl/fullchain.pem:ro
      - ./certs/privkey.pem:/etc/nginx/ssl/privkey.pem:ro
    depends_on:
      - app
      - frontend
    networks:
      - tms_prod

volumes:
  db_prod:
  app_storage:

networks:
  tms_prod:
    driver: bridge
```

### Create Production Dockerfile for Laravel

```dockerfile
# laravel/Dockerfile.prod

FROM php:8.2-fpm-alpine as builder

RUN apk add --no-cache \
    git \
    curl \
    libzip-dev \
    pdo_mysql \
    && docker-php-ext-install pdo_mysql zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    pdo_mysql \
    libzip \
    && docker-php-ext-install pdo_mysql zip

WORKDIR /var/www

COPY --from=builder /var/www /var/www

RUN chown -R www-data:www-data /var/www

EXPOSE 9000

CMD ["php-fpm"]
```

### Create Production Dockerfile for Nuxt

```dockerfile
# frontend/Dockerfile.prod

FROM node:22-alpine as builder

WORKDIR /app

COPY package*.json ./

RUN npm ci

COPY . .

RUN npm run build

FROM node:22-alpine

WORKDIR /app

COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json

EXPOSE 3000

CMD ["npm", "run", "preview"]
```

## 3. SSL/TLS Setup

### Using Let's Encrypt with Certbot

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone \
  -d tms.yourdomain.com \
  -d api.yourdomain.com \
  -d www.yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/tms.yourdomain.com/fullchain.pem ./certs/
sudo cp /etc/letsencrypt/live/tms.yourdomain.com/privkey.pem ./certs/
sudo chmod 644 ./certs/*

# Auto-renew
sudo crontab -e
# Add: 0 0 1 * * certbot renew --quiet
```

## 4. Production Nginx Configuration

```nginx
# nginx.prod.conf

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main buffer=32k;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;

    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/javascript application/json application/javascript;

    upstream php {
        server app:9000;
    }

    upstream frontend {
        server frontend:3000;
    }

    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name tms.yourdomain.com www.yourdomain.com;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        root /var/www/public;
        index index.php;

        location / {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
            fastcgi_pass php;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }

    server {
        listen 443 ssl http2;
        server_name api.yourdomain.com;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        root /var/www/public;
        index index.php;

        location /api {
            try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
            fastcgi_pass php;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            include fastcgi_params;
        }
    }
}
```

## 5. Database Migration to Production

```bash
# 1. Create backup of local data
docker-compose exec db mysqldump -utms_user -ptms_password tms > backup.sql

# 2. Set up production database
# Create RDS/managed database with same credentials

# 3. Import data
mysql -h your-db-host -u tms_prod_user -p tms_prod < backup.sql

# 4. Run migrations
docker-compose -f compose.prod.yaml exec app php artisan migrate --force

# 5. Seed production data
docker-compose -f compose.prod.yaml exec app php artisan db:seed --force
```

## 6. Deployment Steps

```bash
# 1. Pull latest code
git pull origin main

# 2. Build images
docker-compose -f compose.prod.yaml build --no-cache

# 3. Pull and start services
docker-compose -f compose.prod.yaml pull
docker-compose -f compose.prod.yaml up -d

# 4. Run migrations (if any)
docker-compose -f compose.prod.yaml exec app php artisan migrate --force

# 5. Clear caches
docker-compose -f compose.prod.yaml exec app php artisan cache:clear
docker-compose -f compose.prod.yaml exec app php artisan config:clear

# 6. Verify services
docker-compose -f compose.prod.yaml ps
```

## 7. Monitoring & Logging

### Set Up Log Aggregation

```bash
# Enable structured logging
# In laravel/.env:
LOG_CHANNEL=singlefile
LOG_LEVEL=warning

# Configure external logging (e.g., CloudWatch, Datadog)
```

### Health Checks

```bash
# Monitor endpoints
curl https://tms.yourdomain.com/health
curl https://api.yourdomain.com/health

# Container health
docker ps
```

### Backup Strategy

```bash
# Daily database backups
0 2 * * * docker-compose -f compose.prod.yaml exec -T db mysqldump -u${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE} > /backups/db_$(date +\%Y\%m\%d).sql

# Retain 30 days
find /backups -name "db_*.sql" -mtime +30 -delete
```

## 8. Security Hardening

### Update PHP Configuration

```ini
# In Laravel Dockerfile
disable_functions=exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source
expose_php=Off
upload_max_filesize=100M
post_max_size=100M
```

### Rate Limiting

```php
// In Laravel routes/api.php
Route::middleware(['throttle:60,1'])->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
});
```

### CORS Configuration

```php
// config/cors.php
'allowed_origins' => [
    'https://tms.yourdomain.com',
],
```

## 9. Performance Optimization

### Redis Cache

```bash
# Install Redis
docker run -d --name redis -p 6379:6379 redis:alpine

# Update .env
CACHE_DRIVER=redis
CACHE_HOST=redis
```

### Database Optimization

```sql
-- Add indexes
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_activity_log_causer_id ON activity_log(causer_id);
```

## 10. Rollback Procedure

```bash
# Keep previous version
git tag v1.0.0 commit-hash

# If deployment fails
git checkout v1.0.0
docker-compose -f compose.prod.yaml down
docker-compose -f compose.prod.yaml build
docker-compose -f compose.prod.yaml up -d
```

## 11. Post-Deployment Checklist

- [ ] Test login with production URL
- [ ] Verify API endpoints working
- [ ] Check SSL certificate
- [ ] Monitor error logs
- [ ] Run smoke tests
- [ ] Verify backups running
- [ ] Test email notifications
- [ ] Monitor database performance
- [ ] Check uptime monitoring

## 12. Troubleshooting Production Issues

### Container crashes
```bash
docker-compose -f compose.prod.yaml logs app
docker-compose -f compose.prod.yaml restart app
```

### Database connection error
```bash
docker-compose -f compose.prod.yaml exec app php artisan tinker
>>> DB::connection()->getPdo()
```

### SSL certificate issues
```bash
sudo certbot renew
docker-compose -f compose.prod.yaml restart nginx
```

## Support Resources

- Docker Documentation: https://docs.docker.com
- Laravel Deployment: https://laravel.com/docs/deployment
- Nginx Configuration: https://nginx.org/en/docs/
- Let's Encrypt: https://letsencrypt.org/

---

**Your TMS is ready for production! 🚀**
