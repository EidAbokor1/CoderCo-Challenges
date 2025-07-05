# CoderCo Python App - Linux Service Setup

## Overview

This project automates deploying a simple Python HTTP server as a systemd service on Linux.

## Files

- `setup.sh` — Automates setup: user, permissions, service, and logging  
- `server.py` — Python HTTP server reading config from `.env`  
- `.env` — Environment variables (`PORT`, `LOG_PATH`)  
- `coderco-app.service` — systemd service unit

## Usage

1. Place all files in the same folder.  
2. Run:

```bash
   sudo chmod +x setup.sh
   sudo ./setup.sh
```

```bash
systemctl status coderco-app
curl http://localhost:8080
tail /var/log/coderco-app.log
```

## Features

- Creates `appuser` and app directory `/opt/coderco-app`  
- Runs Python app as `appuser` with systemd  
- Logs to `/var/log/coderco-app.log` with proper permissions  
- Enables and starts service on boot

## Optional in automation-setup.sh

- Firewall to restrict port 8080 to localhost  
- Healthcheck script with cronjob