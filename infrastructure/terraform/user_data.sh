#!/bin/bash

set -e
set -x

exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================="
echo "Starting Jenkins Installation"
echo "========================================="

echo "Updating system packages..."
apt-get update
apt-get upgrade -y

echo "Installing dependencies..."
apt-get install -y \
    wget \
    curl \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    openjdk-17-jdk \
    apt-transport-https

echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl start docker
systemctl enable docker

echo "Adding Jenkins repository..."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | apt-key add -

echo "deb https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list

echo "Installing Jenkins..."
apt-get update
apt-get install -y jenkins

usermod -aG docker jenkins

systemctl enable jenkins

systemctl start jenkins

echo "Waiting for Jenkins to start..."
sleep 30

if systemctl is-active --quiet jenkins; then
    echo "✅ Jenkins is running"
else
    echo "❌ Jenkins failed to start"
    systemctl status jenkins
    exit 1
fi

echo "Installing Python..."
apt-get install -y python3 python3-pip

echo "Configuring firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 8080/tcp
ufw allow 50000/tcp
ufw allow 5555/tcp
ufw reload

echo "========================================="
echo "✅ Jenkins Installation Complete!"
echo "========================================="
echo ""
echo "Jenkins is running on port 8080"
echo ""
echo "To get the initial admin password, run:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "Or check systemd journal:"
echo "sudo journalctl -u jenkins -f"
echo ""
echo "========================================="

touch /var/lib/jenkins/installation-complete

echo "System Information:"
echo "  - OS: $(lsb_release -d | cut -f2)"
echo "  - Java: $(java -version 2>&1 | head -n 1)"
echo "  - Docker: $(docker --version)"
echo "  - Python: $(python3 --version)"
echo "  - Jenkins: Installed"
echo ""
echo "Installation log: /var/log/user-data.log"
echo "========================================="
