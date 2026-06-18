#!/bin/bash
# Clean Git History - Remove All Secret Commits
# This completely rewrites history to remove secrets

echo "⚠️  WARNING: This will rewrite all git history!"
echo "Run this ONLY if you haven't shared the repo with others yet"
echo ""
read -p "Continue? (type 'YES' to proceed): " confirm

if [ "$confirm" != "YES" ]; then
    echo "Cancelled"
    exit 0
fi

echo "Removing all commits and starting fresh..."

# Remove all history
rm -rf .git

# Reinitialize
git init

# Set remote
git remote add origin git@github.com:zenycahoy23-blip/ZLC-s-task-management.git

# Add all current files (without history)
git add .

# Create fresh commit
git commit -m "Initial commit: TMS with CI/CD setup (secrets removed from history)

- Complete GitHub Actions workflow
- Docker Compose configuration (dev + prod)
- Deployment automation scripts
- Comprehensive documentation
- All credentials stored in GitHub Secrets only
- No secrets in repository history"

# Set main branch
git branch -M main

# Force push (ONLY safe if repo is brand new)
git push -u --force origin main

echo ""
echo "✅ Clean history pushed!"
echo "All commits with exposed secrets have been removed"
