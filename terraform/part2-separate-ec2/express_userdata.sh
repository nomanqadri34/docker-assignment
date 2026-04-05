#!/bin/bash
##############################################################
# Express Frontend — User Data Script (Part 2)
# Template variables: flask_private_ip, flask_port
##############################################################
set -e
exec > /var/log/express-userdata.log 2>&1

echo "=== Express Frontend User Data ==="
apt-get update -y
apt-get install -y curl git

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Clone repo
cd /home/ubuntu
git clone https://github.com/nomanqadri34/docker-assignment.git app
chown -R ubuntu:ubuntu app

# Install npm deps
cd /home/ubuntu/app/frontend
npm install --production

# Create systemd service for Express
cat > /etc/systemd/system/express-frontend.service <<EOF
[Unit]
Description=Express Frontend Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/app/frontend
Environment="FLASK_URL=http://${flask_private_ip}:${flask_port}"
Environment="NODE_ENV=production"
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable express-frontend
systemctl start express-frontend

echo "=== Express Frontend Started on port 3000 ==="
echo "=== Connecting to Flask at http://${flask_private_ip}:${flask_port} ==="
