#!/bin/bash

# User & permissions
apt-get update
apt-get install -y python3

useradd "appuser"

mkdir -p /opt/coderco-app

cp ./server.py /opt/coderco-app/
cp ./.env /opt/coderco-app/

chown -R appuser:appuser /opt/coderco-app
chmod 750 /opt/coderco-app
chmod 640 /opt/coderco-app/.env
chmod 750 /opt/coderco-app/server.py

#Logging

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

# Start & testing service

cp ./coderco-app.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable coderco-app
systemctl start coderco-app

sleep 1
curl -I http://localhost:8080
systemctl status coderco-app --no-pager