#!/bin/bash
PROMVER="2.45.0"
LOKIVER="2.8.2"
# Update the system
apt-get update -y
apt-get dist-upgrade -y




# GRAFANA 
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




# PROMETHEUS
# Create a service user for Prometheus 
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

# Create config folder and assign proper permissions
sudo mkdir /etc/prometheus 
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Create temp directory and download files
mkdir /tmp/prom
cd /tmp/prom

# Download essential files
curl -LO  https://github.com/prometheus/prometheus/releases/download/v$PROMVER/prometheus-$PROMVER.linux-amd64.tar.gz
tar -xvzf prometheus-$PROMVER.linux-amd64.tar.gz

# Copy binary files and config file
sudo mv prometheus-$PROMVER.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-$PROMVER.linux-amd64/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo mv prometheus-$PROMVER.linux-amd64/consoles /etc/prometheus/
sudo mv prometheus-$PROMVER.linux-amd64/console_libraries /etc/prometheus/
sudo mv prometheus-$PROMVER.linux-amd64/prometheus.yml /etc/prometheus/

sudo chown prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Create systemd service file
sudo tee /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable --now prometheus




# GRAFANA LOKI
