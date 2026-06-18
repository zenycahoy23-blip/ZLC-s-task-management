#!/usr/bin/env bash

# Create Laravel directories
mkdir -p laravel/{app,config,database/{migrations,seeders,factories},routes,resources/views,storage/{logs,framework/{cache,views,sessions}},bootstrap/cache,public,tests/Feature}

# Create Nuxt directories  
mkdir -p frontend/{pages,components,composables,middleware,layouts,public,server,utils,assets/css}

# Copy env files
cp laravel/.env.example laravel/.env
cp frontend/.env.example frontend/.env

echo "Project scaffolding complete!"
