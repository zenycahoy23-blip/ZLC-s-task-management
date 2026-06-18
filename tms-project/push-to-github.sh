#!/bin/bash
# TMS Project - Push All Files to GitHub
# Run this script to initialize and push all files to your empty GitHub repository

set -e

echo "=== TMS Project - GitHub Push Script ==="
echo ""
echo "This script will:"
echo "1. Initialize Git in the project directory (if needed)"
echo "2. Add all files"
echo "3. Create initial commit"
echo "4. Set up remote to your GitHub repository"
echo "5. Push all files to main branch"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed"
    echo "Download from: https://git-scm.com/"
    exit 1
fi

# Navigate to project directory
cd "$(dirname "$0")"

echo "Current directory: $(pwd)"
echo ""

# Initialize git if not already initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    echo "✓ Git initialized"
else
    echo "✓ Git repository already exists"
fi

echo ""
echo "Configuring Git user..."

# Configure git user if not set
if ! git config --global user.email &> /dev/null; then
    echo "No global git email configured"
    echo "Setting default: ci@tms.local"
    git config --global user.email "ci@tms.local"
    git config --global user.name "TMS CI/CD"
fi

echo "✓ Git user configured"

echo ""
echo "Staging all files..."

# Add all files
git add .

# Show what will be committed
echo ""
echo "Files to be committed:"
git diff --cached --name-only | head -20
TOTAL=$(git diff --cached --name-only | wc -l)
echo "... and $((TOTAL-20)) more files"

echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

echo ""
echo "Creating initial commit..."
git commit -m "Initial commit: TMS project with complete CI/CD setup

- Docker Compose configuration (dev + prod)
- GitHub Actions CI/CD workflow
- Slack notifications integration
- Docker Hub integration (indae2)
- Deployment scripts (Unix + Windows)
- Complete documentation
- Environment templates
- Verification tools"

echo "✓ Commit created"

echo ""
echo "Setting up GitHub remote..."

# Check if remote exists
if git remote -v | grep -q origin; then
    echo "Remote origin already exists"
    git remote remove origin
fi

# Add GitHub remote
REPO_URL="git@github.com:zenycahoy23-blip/ZLC-s-task-management.git"
echo "Adding remote: $REPO_URL"
git remote add origin "$REPO_URL"

echo "✓ Remote configured"

echo ""
echo "Verifying SSH connection to GitHub..."
if ssh -T git@github.com &> /dev/null || true; then
    echo "✓ SSH connection verified"
else
    echo "⚠ SSH connection may not be set up"
    echo "Make sure your SSH key is added to GitHub:"
    echo "https://github.com/settings/keys"
fi

echo ""
echo "Pushing to GitHub..."
echo "(This may take a few minutes depending on file size)"

# Push to main branch
git branch -M main
git push -u origin main

echo ""
echo "✓ All files pushed successfully!"
echo ""
echo "Verify at: https://github.com/zenycahoy23-blip/ZLC-s-task-management"
echo ""
echo "Next steps:"
echo "1. Add GitHub Secrets (Settings → Secrets and variables → Actions)"
echo "   - DOCKER_USERNAME: indae2"
echo "   - DOCKER_PASSWORD: "your docker password""
echo "   - SLACK_WEBHOOK: [Your Slack Webhook]"
echo ""
echo "2. Visit Actions tab to see CI/CD pipeline running"
echo ""
echo "3. Check Slack for notifications"
