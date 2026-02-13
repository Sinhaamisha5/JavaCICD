#!/bin/bash

# CI/CD Jenkins Setup Script for Ubuntu EC2
# Run this on a fresh Ubuntu 22.04 EC2 instance

set -e

echo "=================================="
echo "Jenkins CI/CD Setup for EC2"
echo "=================================="

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Java 17
echo "☕ Installing Java 17..."
sudo apt install -y openjdk-17-jdk

# Verify Java installation
java -version

# Install Jenkins
echo "🔧 Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins

# Start Jenkins
echo "🚀 Starting Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Maven
echo "📚 Installing Maven..."
sudo apt install -y maven
mvn -version

# Install Docker
echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add jenkins user to docker group
echo "🔑 Configuring Jenkins Docker access..."
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

# Install Git
echo "📝 Installing Git..."
sudo apt install -y git

# Install additional tools
echo "🛠️ Installing additional tools..."
sudo apt install -y curl wget unzip

# Restart Jenkins to apply group changes
echo "🔄 Restarting Jenkins..."
sudo systemctl restart jenkins

# Wait for Jenkins to start
echo "⏳ Waiting for Jenkins to start (30 seconds)..."
sleep 30

# Get Jenkins initial password
echo ""
echo "=================================="
echo "✅ Installation Complete!"
echo "=================================="
echo ""
echo "Jenkins URL: http://$(curl -s ifconfig.me):8080"
echo ""
echo "Initial Admin Password:"
echo "-----------------------------------"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "-----------------------------------"
echo ""
echo "Security Group Requirements:"
echo "  - Port 8080 (Jenkins web UI)"
echo "  - Port 22 (SSH)"
echo ""
echo "Next Steps:"
echo "1. Open Jenkins at http://YOUR_EC2_IP:8080"
echo "2. Enter the admin password shown above"
echo "3. Install suggested plugins"
echo "4. Create your admin user"
echo ""
echo "After Jenkins setup:"
echo "  - Configure Java 17 in Global Tool Configuration"
echo "  - Configure Maven in Global Tool Configuration"
echo "  - Install plugins: Maven Integration, JaCoCo, Docker Pipeline"
echo ""
echo "=================================="
