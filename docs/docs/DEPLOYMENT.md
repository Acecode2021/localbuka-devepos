## Staging → Production with senior approval

Every push to `main` triggers:
1. Automated tests.
2. Docker image build.
3. Automatic deployment to Render.

Production is protected by a GitHub Environment called `production`.

Setup:
- GitHub repo → Settings → Environments → New environment → `production`.
- Add required reviewers (senior engineer).

After approval:
1. Deploy hook triggers.
2. Production health check runs.
3. If health check fails, rollback using Render dashboard.