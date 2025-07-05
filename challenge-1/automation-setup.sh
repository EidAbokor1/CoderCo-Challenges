#!/bin/bash

apt-get update
apt-get install -y python3

# User & Permissions
 
useradd "appuser"

mkdir -p "/opt/coderco-app" 
  
touch /opt/coderco-app/server.py
touch /opt/coderco-app/.env
  
cat <<EOF > /opt/coderco-app/server.py
#!/usr/bin/env python3

import http.server, socketserver, os

PORT = int(os.getenv("PORT", 8080))
LOGFILE = os.getenv("LOG_PATH", "/var/log/coderco-app.log")

Handler = http.server.SimpleHTTPRequestHandler

with open(LOGFILE, "a") as log:
    log.write(f"Starting app on port {PORT}\n")

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving on port {PORT}")
    httpd.serve_forever()
EOF
  
cat <<EOF > /opt/coderco-app/.env
PORT=8080
LOG_PATH=/var/log/coderco-app.log
EOF
  
chown -R appuser:appuser /opt/coderco-app
chmod 750 /opt/coderco-app
chmod 640 /opt/coderco-app/.env
chmod 750 /opt/coderco-app/server.py

# Systemd service

touch /etc/systemd/system/coderco-app.service

cat <<EOF > /etc/systemd/system/coderco-app.service
[Unit]
Description=CoderCo Python App
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/coderco-app
ExecStart=/usr/bin/python3 /opt/coderco-app/server.py
EnvironmentFile=/opt/coderco-app/.env
Restart=always
RestartSec=1
StandardOutput=append:/var/log/coderco-app.log
StandardError=append:/var/log/coderco-app.log

[Install]
WantedBy=multi-user.target
EOF

# Logging

touch /var/log/coderco-app.log

chown appuser:appuser /var/log/coderco-app.log
chmod 640 /var/log/coderco-app.log

cat <<EOF > /etc/logrotate.d/coderco-app
/var/log/coderco-app.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
    create 640 appuser appuser
}
EOF

systemctl daemon-reload
systemctl enable coderco-app
systemctl start coderco-app

sleep 1

curl -I http://localhost:8080
systemctl status coderco-app --no-pager

# Firewall setup
sudo ufw enable
sudo ufw deny 8080
sudo ufw allow from 127.0.0.1 to any port 8080

# Healthcheck script
cat <<'EOF' | sudo tee /usr/local/bin/coderco-healthcheck.sh
#!/bin/bash
source /opt/coderco-app/.env
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT})
if [[ "$HTTP_STATUS" == "200" ]]; then
    echo "$(date): Healthcheck OK - status $HTTP_STATUS" >> $LOG_PATH
    exit 0
else
    echo "$(date): Healthcheck FAILED - status $HTTP_STATUS" >> $LOG_PATH
    exit 1
fi
EOF

sudo chmod +x /usr/local/bin/coderco-healthcheck.sh

# Add cronjob
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/coderco-healthcheck.sh") | sudo crontab -
