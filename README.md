# CoderCo Challenges

This repository contains various DevOps and Linux challenges completed as part of CoderCo training.

## Challenge 1: Python App as a Systemd Service

- Creates a non-root user `appuser`
- Sets up app directory `/opt/coderco-app` with Python server and environment files
- Configures and runs the app as a systemd service under `appuser`
- Logs output to `/var/log/coderco-app.log` with proper permissions
- Enables and starts the service on boot
- Bonus: firewall restricting port 8080 to localhost, healthcheck script with cronjob

See [`challenge-1/README.md`](challenge-1/README.md) for detailed steps and files.

---

More challenges coming soon!
