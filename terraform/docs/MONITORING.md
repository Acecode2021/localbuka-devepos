cat > ~/localbuka-devops/docs/MONITORING.md <<'EOF'
# LocalBuka Monitoring & Reliability

## Monitoring solution (Task 28)

AWS CloudWatch was chosen because it is natively integrated with the EC2 and RDS infrastructure already provisioned in Part 2. It provides metric storage, dashboards, and alerting without requiring any additional infrastructure or cost beyond the free tier.

## Health checking (Task 29)

A cron job runs on the EC2 instance every minute (`/etc/cron.d/localbuka-healthcheck`), executing `/usr/local/bin/health-check.sh`. The script:
1. Curls `http://localhost/health` on the container.
2. Measures the HTTP status code and round-trip latency.
3. Pushes custom metrics to CloudWatch under the `LocalBuka/API` namespace: `HealthCheck` (HTTP status), `ResponseTime` (ms), and `ServerErrors5xx` (on 5xx).

## Metrics monitored (Tasks 30, 31)

| Metric | Namespace | Unit | Purpose |
|---|---|---|---|
| ResponseTime | LocalBuka/API | Milliseconds | Detect latency degradation |
| HealthCheck | LocalBuka/API | Count (HTTP status) | Confirm API is reachable |
| ServerErrors5xx | LocalBuka/API | Count | Track server-side failures |

## Dashboard (Task 32)

The `LocalBuka-API` CloudWatch dashboard displays ResponseTime, HealthCheck, and HealthCheckFailed widgets in real time, refreshed every minute.

## Alerting (Tasks 33, 34)

A CloudWatch alarm (`localbuka-api-health-failed`) fires when `HealthCheck < 200` over a 5-minute window. It publishes to the `localbuka-alerts` SNS topic, which emails the on-call engineer.

Test conducted: stopping the container put the alarm into the `In alarm` state within 5 minutes and delivered an email. Restarting the container returned the alarm to `OK` and sent a recovery email — proving bidirectional alerting works.

## Most important metrics (Task 36)

1. ResponseTime — direct measure of user experience. Every 100 ms of added latency measurably reduces order completion.
2. HealthCheck — binary signal that the API is reachable. Any drop below 200 in a 5-minute window is page-worthy.
3. ServerErrors5xx — indicates server-side bugs or infrastructure failures. Should stay at 0.
4. EC2 CPUUtilization — predicts capacity issues before they become user-visible.
5. RDS DatabaseConnections — detects connection pool exhaustion before it cascades into API errors.

## Critical vs non-critical alerts (Task 37)

| Severity | Example | Response |
|---|---|---|
| P1 Critical (page) | HealthCheck < 200 for 5 min | Wake on-call, immediate rollback or restart |
| P2 High (page in hours) | ResponseTime > 1000 ms average for 10 min | Investigate during business hours |
| P3 Medium (ticket) | CPU > 80% for 15 min | Queue for next sprint |
| P4 Low (dashboard only) | Single 5xx error | Note and monitor |

## Investigating a 2x response-time spike (Task 38)

1. Scope: is it all endpoints or just one? Check CloudWatch Logs Insights for slow requests.
2. Time correlation: did a deploy happen? Check GitHub Actions runs in the last hour.
3. Resource check: EC2 CPUUtilization, RDS DatabaseConnections, RDS CPUUtilization.
4. External factors: slow RDS queries? Check `FreeableMemory` on RDS.
5. Rollback: if a deploy correlates, roll back via GitHub and confirm the metric recovers.
EOF

cd ~/localbuka-devops
git add docs/MONITORING.md
git commit -m "docs: add monitoring and reliability documentation (Part 3)"
git push