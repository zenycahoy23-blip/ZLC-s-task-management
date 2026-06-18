#!/bin/bash

# TMS Deployment Script for Local Environment
# Usage: ./deploy-local.sh [start|stop|restart|logs|status|pull]

set -e

COMMAND=${1:-start}
DOCKER_USERNAME="${DOCKER_USERNAME:-indae2}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
REGISTRY="${REGISTRY:-docker.io}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

case $COMMAND in
  start)
    log_info "Starting TMS services..."
    docker compose -f docker-compose.yml up -d
    log_success "Services started"
    docker compose ps
    log_info "Access points:"
    echo "  - Frontend: http://localhost:3000"
    echo "  - API: http://localhost:8000"
    echo "  - Jenkins: http://localhost:8080"
    echo "  - Database: localhost:3307"
    ;;

  stop)
    log_info "Stopping TMS services..."
    docker compose -f docker-compose.yml down
    log_success "Services stopped"
    ;;

  restart)
    log_info "Restarting TMS services..."
    docker compose -f docker-compose.yml restart
    log_success "Services restarted"
    ;;

  logs)
    SERVICE=${2:-}
    if [ -z "$SERVICE" ]; then
      docker compose logs -f
    else
      docker compose logs -f "$SERVICE"
    fi
    ;;

  status)
    log_info "TMS Services Status:"
    docker compose ps
    ;;

  pull)
    log_info "Pulling latest images from registry..."
    docker pull $REGISTRY/$DOCKER_USERNAME/tms-php:$IMAGE_TAG
    log_success "PHP image pulled"
    docker pull $REGISTRY/$DOCKER_USERNAME/tms-frontend:$IMAGE_TAG
    log_success "Frontend image pulled"
    log_info "Restarting services..."
    docker compose restart php frontend
    log_success "Services restarted with latest images"
    ;;

  test)
    log_info "Running tests..."
    log_info "Running Laravel tests..."
    docker compose exec -T php php artisan test --parallel
    log_success "Laravel tests passed"
    
    log_info "Running frontend tests..."
    docker compose exec -T frontend npm run test:unit || true
    log_success "Frontend tests completed"
    ;;

  shell-php)
    log_info "Entering PHP container shell..."
    docker compose exec php bash
    ;;

  shell-frontend)
    log_info "Entering Frontend container shell..."
    docker compose exec frontend sh
    ;;

  clean)
    log_warning "Removing all containers and volumes..."
    docker compose down -v
    log_success "Cleanup complete"
    ;;

  *)
    echo "TMS Deployment Script"
    echo ""
    echo "Usage: $0 [command] [args]"
    echo ""
    echo "Commands:"
    echo "  start              Start all services"
    echo "  stop               Stop all services"
    echo "  restart            Restart all services"
    echo "  logs [service]     Show service logs (tail -f)"
    echo "  status             Show services status"
    echo "  pull               Pull latest images from registry"
    echo "  test               Run tests"
    echo "  shell-php          Enter PHP container shell"
    echo "  shell-frontend     Enter Frontend container shell"
    echo "  clean              Remove all containers and volumes"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs frontend"
    echo "  $0 pull"
    exit 1
    ;;
esac
