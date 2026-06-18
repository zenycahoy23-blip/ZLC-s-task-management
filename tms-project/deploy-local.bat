@echo off
REM TMS Deployment Script for Local Environment (Windows)
REM Usage: deploy-local.bat [start|stop|restart|logs|status|pull]

setlocal enabledelayedexpansion
set COMMAND=%1
if "!COMMAND!"=="" set COMMAND=start

set DOCKER_USERNAME=indae2
set IMAGE_TAG=latest
set REGISTRY=docker.io

if "!COMMAND!"=="start" (
  echo [INFO] Starting TMS services...
  docker compose -f docker-compose.yml up -d
  echo [OK] Services started
  docker compose ps
  echo.
  echo Access points:
  echo   - Frontend: http://localhost:3000
  echo   - API: http://localhost:8000
  echo   - Jenkins: http://localhost:8080
  echo   - Database: localhost:3307
) else if "!COMMAND!"=="stop" (
  echo [INFO] Stopping TMS services...
  docker compose -f docker-compose.yml down
  echo [OK] Services stopped
) else if "!COMMAND!"=="restart" (
  echo [INFO] Restarting TMS services...
  docker compose -f docker-compose.yml restart
  echo [OK] Services restarted
) else if "!COMMAND!"=="logs" (
  set SERVICE=%2
  if "!SERVICE!"=="" (
    docker compose logs -f
  ) else (
    docker compose logs -f !SERVICE!
  )
) else if "!COMMAND!"=="status" (
  echo [INFO] TMS Services Status:
  docker compose ps
) else if "!COMMAND!"=="pull" (
  echo [INFO] Pulling latest images from registry...
  docker pull !REGISTRY!/!DOCKER_USERNAME!/tms-php:!IMAGE_TAG!
  echo [OK] PHP image pulled
  docker pull !REGISTRY!/!DOCKER_USERNAME!/tms-frontend:!IMAGE_TAG!
  echo [OK] Frontend image pulled
  echo [INFO] Restarting services...
  docker compose restart php frontend
  echo [OK] Services restarted with latest images
) else if "!COMMAND!"=="clean" (
  echo [WARNING] Removing all containers and volumes...
  docker compose down -v
  echo [OK] Cleanup complete
) else (
  echo TMS Deployment Script - Windows
  echo.
  echo Usage: %0 [command]
  echo.
  echo Commands:
  echo   start              Start all services
  echo   stop               Stop all services
  echo   restart            Restart all services
  echo   logs [service]     Show service logs
  echo   status             Show services status
  echo   pull               Pull latest images from registry
  echo   clean              Remove all containers and volumes
  echo.
  echo Examples:
  echo   %0 start
  echo   %0 logs frontend
  echo   %0 pull
)
endlocal
