#!/bin/bash
##############################################################
# Flask Backend — User Data Script (Part 2)
##############################################################
set -e
exec > /var/log/flask-userdata.log 2>&1

echo "=== Flask Backend User Data ==="
apt-get update -y
apt-get install -y python3 python3-pip python3-venv git curl

# Clone repo
cd /home/ubuntu
git clone https://github.com/nomanqadri34/docker-assignment.git app
chown -R ubuntu:ubuntu app

# Set up virtual environment
cd /home/ubuntu/app/backend
python3 -m venv venv
source venv/bin/activate
pip install --no-cache-dir -r requirements.txt
deactivate

# Create systemd service for Flask
cat > /etc/systemd/system/flask-backend.service <<'EOF'
[Unit]
Description=Flask Backend Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/app/backend
Environment="PATH=/home/ubuntu/app/backend/venv/bin"
ExecStart=/home/ubuntu/app/backend/venv/bin/python app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flask-backend
systemctl start flask-backend

echo "=== Flask Backend Started on port 5000 ==="
