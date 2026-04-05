#!/bin/bash
##############################################################
# Cloud-Init / User-Data script
# Installs: Python 3, Node.js 18, Git, PM2
# Clones the repo and starts both apps
##############################################################
set -e
exec > /var/log/user-data.log 2>&1

echo "=== Starting User Data Script ==="
apt-get update -y
apt-get install -y git curl python3 python3-pip python3-venv

# ── Install Node.js 18 via NodeSource ───────────────────────
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# ── Install PM2 globally ─────────────────────────────────────
npm install -g pm2

# ── Clone the application repo ───────────────────────────────
cd /home/ubuntu
git clone https://github.com/nomanqadri34/docker-assignment.git app
chown -R ubuntu:ubuntu app

# ── Set up Flask backend ─────────────────────────────────────
cd /home/ubuntu/app/backend
python3 -m venv venv
source venv/bin/activate
pip install --no-cache-dir -r requirements.txt
deactivate

# Start Flask with PM2
pm2 start --name flask-backend --interpreter /home/ubuntu/app/backend/venv/bin/python app.py
pm2 save

# ── Set up Express frontend ──────────────────────────────────
cd /home/ubuntu/app/frontend
npm install --production

# Set Flask URL to localhost (same machine)
export FLASK_URL="http://localhost:${flask_port}"

# Start Express with PM2
FLASK_URL="http://localhost:${flask_port}" pm2 start server.js --name express-frontend
pm2 save

# ── Enable PM2 on reboot ─────────────────────────────────────
pm2 startup systemd -u ubuntu --hp /home/ubuntu
env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu

echo "=== Deployment Complete ==="
echo "Flask  : http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${flask_port}"
echo "Express: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${express_port}"
