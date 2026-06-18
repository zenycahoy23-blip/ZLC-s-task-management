#!/bin/bash

# TMS CI/CD Setup Verification Script
# Checks if all components are properly configured

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }

echo -e "${BLUE}=== TMS CI/CD Verification ===${NC}\n"

CHECKS_PASSED=0
CHECKS_FAILED=0

# Check Docker
echo -e "${BLUE}Docker Configuration${NC}"
if command -v docker &> /dev/null; then
  pass "Docker is installed"
  ((CHECKS_PASSED++))
else
  fail "Docker not found - install from https://docs.docker.com/get-docker/"
  ((CHECKS_FAILED++))
fi

if docker ps &> /dev/null; then
  pass "Docker daemon is running"
  ((CHECKS_PASSED++))
else
  fail "Docker daemon is not running"
  ((CHECKS_FAILED++))
fi

# Check Docker Compose
echo -e "\n${BLUE}Docker Compose${NC}"
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
  pass "Docker Compose is installed"
  ((CHECKS_PASSED++))
else
  fail "Docker Compose not found"
  ((CHECKS_FAILED++))
fi

# Check Git
echo -e "\n${BLUE}Git Configuration${NC}"
if command -v git &> /dev/null; then
  pass "Git is installed"
  ((CHECKS_PASSED++))
else
  fail "Git not found - install from https://git-scm.com/"
  ((CHECKS_FAILED++))
fi

if git remote -v &> /dev/null; then
  ORIGIN=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ $ORIGIN == *"github.com"* ]]; then
    pass "Git remote is GitHub"
    ((CHECKS_PASSED++))
  else
    warn "Git remote is not GitHub: $ORIGIN"
  fi
else
  fail "Not a git repository"
  ((CHECKS_FAILED++))
fi

# Check GitHub SSH
echo -e "\n${BLUE}GitHub SSH${NC}"
if ssh -T git@github.com &> /dev/null 2>&1; then
  pass "GitHub SSH connection working"
  ((CHECKS_PASSED++))
else
  warn "GitHub SSH connection failed - might need to set up SSH keys"
  info "Run: ssh-keygen -t ed25519 -C 'your_email@example.com'"
  info "Then add the public key to GitHub Settings → SSH and GPG keys"
fi

# Check Dockerfiles
echo -e "\n${BLUE}Project Structure${NC}"
if [ -f "laravel/Dockerfile" ]; then
  pass "Laravel Dockerfile found"
  ((CHECKS_PASSED++))
else
  fail "Laravel Dockerfile not found"
  ((CHECKS_FAILED++))
fi

if [ -f "frontend/Dockerfile" ]; then
  pass "Frontend Dockerfile found"
  ((CHECKS_PASSED++))
else
  fail "Frontend Dockerfile not found"
  ((CHECKS_FAILED++))
fi

if [ -f "docker-compose.yml" ]; then
  pass "docker-compose.yml found"
  ((CHECKS_PASSED++))
else
  fail "docker-compose.yml not found"
  ((CHECKS_FAILED++))
fi

if [ -f ".github/workflows/ci-cd.yml" ]; then
  pass "GitHub Actions workflow found"
  ((CHECKS_PASSED++))
else
  fail "GitHub Actions workflow not found"
  ((CHECKS_FAILED++))
fi

# Check Docker Hub
echo -e "\n${BLUE}Docker Hub Configuration${NC}"
if docker info &> /dev/null | grep -q "Username"; then
  pass "Docker is logged in"
  ((CHECKS_PASSED++))
else
  warn "Not logged in to Docker Hub - run: docker login -u indae2"
fi

# Check images exist locally
echo -e "\n${BLUE}Local Docker Images${NC}"
if docker images | grep -q "tms-project-php"; then
  pass "PHP image built locally"
  ((CHECKS_PASSED++))
else
  warn "PHP image not built - run: docker compose build php"
fi

if docker images | grep -q "tms-project-frontend"; then
  pass "Frontend image built locally"
  ((CHECKS_PASSED++))
else
  warn "Frontend image not built - run: docker compose build frontend"
fi

# Check containers
echo -e "\n${BLUE}Running Services${NC}"
if docker ps | grep -q "tms_db"; then
  pass "Database container running"
  ((CHECKS_PASSED++))
else
  warn "Database not running - run: docker compose up -d db"
fi

if docker ps | grep -q "tms_php"; then
  pass "PHP container running"
  ((CHECKS_PASSED++))
else
  warn "PHP not running - run: docker compose up -d php"
fi

# Summary
echo -e "\n${BLUE}=== Verification Summary ===${NC}"
echo -e "Passed: ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Failed: ${RED}$CHECKS_FAILED${NC}"

if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All checks passed! Your system is ready.${NC}"
  echo -e "\nNext steps:"
  echo "1. Add GitHub Secrets: DOCKER_USERNAME, DOCKER_PASSWORD, SLACK_WEBHOOK"
  echo "2. Push code: git push origin main"
  echo "3. Watch workflow: https://github.com/zenycahoy23-blip/ZLC-s-task-management/actions"
  echo "4. Monitor Slack for notifications"
  exit 0
else
  echo -e "\n${RED}Some checks failed. Please fix the issues above.${NC}"
  exit 1
fi
