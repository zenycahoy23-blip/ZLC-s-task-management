# GitHub Actions Secrets Setup

To enable the CI/CD pipeline, you need to add the following secrets to your GitHub repository.

## How to Add Secrets

1. Go to your repository: `https://github.com/zenycahoy23-blip/ZLC-s-task-management`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret below

## Required Secrets

### Docker Registry Credentials

**Secret Name:** `DOCKER_USERNAME`
```
Value: indae2
```

**Secret Name:** `DOCKER_PASSWORD`
```
Value: [Your Docker Hub Personal Access Token]
```

### Slack Webhook

**Secret Name:** `SLACK_WEBHOOK`
```
Value: [Your Slack Webhook URL]
```

Example format:
```
https://hooks.slack.com/services/your/webhook/path
```

## Verification

After adding secrets, you can verify they're set up correctly:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. You should see all secrets listed (values hidden)
3. Trigger a push to main branch to test the pipeline

## Secret Values Reference

### Docker Hub PAT (Personal Access Token)
- Username: `indae2`
- Token: [Stored in GitHub Secrets - DOCKER_PASSWORD]
- Permissions: Read/Write access

### Slack Webhook
- Used for build notifications
- URL: [Stored in GitHub Secrets - SLACK_WEBHOOK]
- Receives: Build start, success, failure, deployment status

## Testing the Pipeline

1. Make a commit and push to `main` or `develop` branch:
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```

2. Go to **Actions** tab in GitHub to see the workflow running

3. Check Slack for notifications

## Troubleshooting

### Images not pushing to Docker Hub
- Verify `DOCKER_USERNAME` and `DOCKER_PASSWORD` are correct
- Check Docker Hub Personal Access Tokens have `write:repos` permission
- Ensure repository `indae2/tms-php` and `indae2/tms-frontend` exist

### Slack notifications not received
- Verify webhook URL is correct in `SLACK_WEBHOOK`
- Check Slack workspace permissions
- Test webhook manually: 
  ```bash
  curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"Test"}' \
    YOUR_WEBHOOK_URL
  ```

### Build fails locally
- Ensure Docker is running
- Run `docker compose build` to test locally first
- Check Dockerfile syntax with `docker build --check`

## Environment Variables

These are also referenced in the workflow but can be modified:

```yaml
REGISTRY: docker.io                    # Docker registry
IMAGE_NAME_PHP: indae2/tms-php        # PHP image repository
IMAGE_NAME_FRONTEND: indae2/tms-frontend  # Frontend image repository
SLACK_WEBHOOK: from secrets            # Slack webhook URL
```

## Additional Setup (Optional)

### Enable Branch Protection Rules

To enforce CI/CD checks before merging:

1. Go to **Settings** → **Branches**
2. Click **Add rule** under Branch protection rules
3. Set Branch name pattern to `main`
4. Enable:
   - ✓ Require a pull request before merging
   - ✓ Require status checks to pass before merging
   - ✓ Select `build`, `test` workflow jobs

### Schedule Nightly Builds

Add to `.github/workflows/ci-cd.yml`:
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM UTC daily
```

## Support

For issues with GitHub Actions:
- Check workflow logs: **Actions** tab → workflow name → job logs
- Validate YAML syntax: Use online YAML validators
- Test Docker commands locally first
