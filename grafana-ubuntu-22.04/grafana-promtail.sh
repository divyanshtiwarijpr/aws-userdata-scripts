#!/bin/bash
LOKIVER="2.8.2"


# GENERAL 
# System updates
apt-get update -y
apt-get dist-upgrade -y






# PROMTAIL
# Install the required packages
apt install unzip -y






# Create config folder and assign proper permissions
mkdir /etc/promtail






# Create temporary directories and download essential files and extract them and set proper permissions
mkdir /tmp/promtaildl
cd /tmp/promtaildl

curl -LO "https://github.com/grafana/loki/releases/download/v$LOKIVER/promtail-linux-amd64.zip"
unzip promtail-linux-amd64.zip

wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml

mv promtail-linux-amd64 /usr/local/bin
mv promtail-local-config.yaml /etc/promtail






# Create systemd service for Promtail
tee /etc/systemd/system/promtail.service << EOF
[Unit]
Description=Promtail Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/promtail-linux-amd64 -config.file /etc/promtail/promtail-local-config.yaml

[Install]
WantedBy=multi-user.target
EOF

# Run Promtail on boot
systemctl enable --now promtail.service

# Take backup of main Promtail config
cp /etc/promtail/promtail-local-config.yaml /etc/promtail/promtail-local-config.yaml.dtbak

# Cleanup
rm -rf /tmp/promtaildl

