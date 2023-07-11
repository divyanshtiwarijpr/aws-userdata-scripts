#!/bin/bash
# Update the system
apt-get update -y 
apt-get dist-upgrade -y
apt install unzip -y

mkdir /lokidl
chown ubuntu:ubuntu /lokidl
cd /lokidl

curl -O -L "https://github.com/grafana/loki/releases/download/v2.8.2/loki-linux-amd64.zip"
# Extract the binary
unzip "loki-linux-amd64.zip"
# Make sure it is executable
chmod a+x "loki-linux-amd64"

wget https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml
wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml



# Create systemd service for Grafana Loki
tee /etc/systemd/system/grafana-loki.service<<EOF
[Unit]
Description= Grafana Loki Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/lokidl/loki-linux-amd64 -config.file /lokidl/loki-local-config.yaml

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now grafana-loki.service


curl -O -L "https://github.com/grafana/loki/releases/download/v2.8.2/promtail-linux-amd64.zip"
unzip promtail-linux-amd64.zip

# Create systemd service for Promtail
tee /etc/systemd/system/Promtail.service<<EOF
[Unit]
Description=Promtail Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/lokidl/promtail-linux-amd64 -config.file /lokidl/promtail-local-config.yaml

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now promtail.service



