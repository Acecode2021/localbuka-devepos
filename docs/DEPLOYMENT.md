# Deployment Guide

## Pipeline stages
1. Test (runs on every push to main)
2. Build Docker image
3. Deploy to Render staging
4. Verify staging health

## Failed deployment handling

### If tests fail
- Pipeline stops.
- No Docker image is built.
- No deployment happens.
- Developer fixes code and pushes again.

### If Docker build fails
- Pipeline stops.
- No Render deploy.
- Check Dockerfile and GitHub Actions build logs.

### If Render deploy fails or health check fails
- Roll back via Render dashboard: Events → previous deploy → Rollback.
- Open incident notes.
- Fix forward only after root cause is understood.

### Known Render-specific issue
- `Exited with status 128` on Docker runtime is caused by Render clearing `/tmp` at startup.
- Fix: switched to Node.js runtime to avoid Docker permission issues.
- See docs/evidence for screenshots of the original failure and resolution.

## Rollback steps
1. Render dashboard → service → Events.
2. Find last known good deploy.
3. Click Rollback.
4. Verify `/health`.
5. Confirm with the team.