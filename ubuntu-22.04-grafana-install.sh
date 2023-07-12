#!/bin/bash
# Update the system
apt-get update -y
apt-get dist-upgrade -y

# Install required packages
apt-get install -y apt-transport-https
apt-get install -y software-properties-common wget
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key

# Add repo for stable releases
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list

# Insatll Grafana
apt-get update -y
apt-get install grafana -y

# Run Grafana on boot 
systemctl enable --now grafana-server.service

# Take backup of main Grafana config
cp /etc/grafana/grafana.ini /etc/grafana/grafana.ini.dtbak

