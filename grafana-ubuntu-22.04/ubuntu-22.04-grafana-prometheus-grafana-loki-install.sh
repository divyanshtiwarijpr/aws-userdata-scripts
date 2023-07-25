#!/bin/bash
PROMVER="2.45.0"
LOKIVER="2.8.2"


# GENERAL 
# System updates
apt-get update -y
apt-get dist-upgrade -y






# GRAFANA 
# Install the required packages
apt-get install -y apt-transport-https software-properties-common wget

# Add repo for stable releases
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
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
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus

# Create config folder and assign proper permissions
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Create temporary directories and download essential files and extract them
mkdir /tmp/prometheusdl
cd /tmp/prometheusdl

curl -LO  https://github.com/prometheus/prometheus/releases/download/v$PROMVER/prometheus-$PROMVER.linux-amd64.tar.gz
tar -xvzf prometheus-$PROMVER.linux-amd64.tar.gz

# Copy binary files and config files and set proper permissions
mv prometheus-$PROMVER.linux-amd64/prometheus /usr/local/bin/
mv prometheus-$PROMVER.linux-amd64/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

mv prometheus-$PROMVER.linux-amd64/consoles /etc/prometheus/
mv prometheus-$PROMVER.linux-amd64/console_libraries /etc/prometheus/
mv prometheus-$PROMVER.linux-amd64/prometheus.yml /etc/prometheus/

chown prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown -R prometheus:prometheus /var/lib/prometheus

# Create systemd service file
tee /etc/systemd/system/prometheus.service << EOF
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

# Take backup of main Prometheus config
cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.dtbak

# Run Prometheus on boot 
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

# Cleanup
rm -rf /tmp/prometheusdl






# GRAFANA LOKI
# Install the required packages
apt install unzip -y

# Create temporary directories and download essential files and extract them
mkdir /tmp/lokidl
cd /tmp/lokidl

curl -LO "https://github.com/grafana/loki/releases/download/v$LOKIVER/loki-linux-amd64.zip"
wget https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml

unzip "loki-linux-amd64.zip"

# Copy binary files and config files 
mkdir /etc/grafana-loki

mv loki-linux-amd64 /usr/local/bin
mv loki-local-config.yaml /etc/grafana-loki

# Make sure it is executable
chmod a+x "/usr/local/bin/loki-linux-amd64"

# Create systemd service for Grafana Loki
tee /etc/systemd/system/grafana-loki.service << EOF
[Unit]
Description= Grafana Loki Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/loki-linux-amd64 -config.file /etc/grafana-loki/loki-local-config.yaml

[Install]
WantedBy=multi-user.target
EOF

# Take backup of main Grafana Loki config
cp /etc/grafana-loki/loki-local-config.yaml /etc/grafana-loki/loki-local-config.yaml.dtbak

# Run Grafana Loki on boot 
systemctl enable --now grafana-loki.service

# Cleanup
rm -rf /tmp/lokidl






# PROMTAIL 
# Install the required packages
apt install unzip -y

# Create temporary directories and download essential files and extract them and set proper permissions
mkdir /tmp/promtaildl
cd /tmp/promtaildl

curl -LO "https://github.com/grafana/loki/releases/download/v$LOKIVER/promtail-linux-amd64.zip"
unzip promtail-linux-amd64.zip

wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml

# Copy binary files and config files 
mkdir /etc/promtail
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





# Reboot as system was updated
reboot
