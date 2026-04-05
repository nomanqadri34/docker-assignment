#!/bin/bash
set -e

# Logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Updating and installing baseline dependencies..."
apt-get update -y
apt-get install -y git curl unzip fontconfig openjdk-17-jre python3-pip python3-venv build-essential

# 1. Create 2GB SWAP File (Crucial for Jenkins on t2.micro)
echo "Setting up 2GB Swap space..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# 2. Install Jenkins
echo "Installing Jenkins..."
wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update -y
apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# 3. Install Node.js 18 & PM2
echo "Installing Node.js and PM2..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
npm install -g pm2

# 4. Prepare permissions for Jenkins user
# Jenkins needs to be able to run pm2 and manage services
usermod -aG sudo jenkins
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create initial directories for apps
mkdir -p /var/www/backend /var/www/frontend
chown -R jenkins:jenkins /var/www/

echo "User Data script finished successfully!"
echo "Initial Admin Password:"
cat /var/lib/jenkins/secrets/initialAdminPassword
