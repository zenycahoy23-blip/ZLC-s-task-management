#!/bin/bash

# Frontend Initialization Script
set +e

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

log_header "Frontend - Initialization & Verification"

# Check Node.js
if command -v node &> /dev/null; then
    log_success "Node.js installed: $(node --version)"
else
    log_error "Node.js not found"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    log_success "npm installed: $(npm --version)"
else
    log_error "npm not found"
    exit 1
fi

# Check package.json
if [ ! -f "package.json" ]; then
    log_error "package.json not found"
    exit 1
fi

log_success "package.json exists"

# Install dependencies
log_info "Installing npm dependencies..."
if npm install --legacy-peer-deps 2>&1 | grep -q "added"; then
    log_success "Dependencies installed"
else
    log_warning "Dependencies installation completed with notes"
fi

# Check if node_modules exists
if [ -d "node_modules" ]; then
    log_success "node_modules directory created"
else
    log_error "node_modules directory not created"
fi

# Check critical packages
PACKAGES=("nuxt" "vue" "vite" "@nuxtjs/tailwindcss" "axios")
for pkg in "${PACKAGES[@]}"; do
    if [ -d "node_modules/$pkg" ]; then
        log_success "Package installed: $pkg"
    else
        log_warning "Package may be missing: $pkg"
    fi
done

# Check .env
if [ ! -f ".env" ]; then
    log_warning ".env not found - creating..."
    cat > .env << EOF
VITE_API_URL=http://localhost:8000
VITE_APP_NAME=Task Management System
NITRO_HOST=0.0.0.0
NITRO_PORT=3000
EOF
    log_success ".env created"
else
    log_success ".env exists"
fi

log_header "Frontend Ready"
log_info "Starting development server on port 3000..."

# Start dev server
npm run dev
