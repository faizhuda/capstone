```bash
#!/bin/bash

echo "===== SETUP MONITORING SERVER START ====="

sudo apt update
sudo apt upgrade -y

echo "Installing base packages..."

sudo apt install -y \
curl \
wget \
vim \
nano \
git \
htop \
net-tools \
dnsutils \
unzip \
tar \
jq \
python3 \
python3-pip

echo "===== INSTALL PROMETHEUS ====="

cd /tmp

wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-2.54.1.linux-amd64.tar.gz

tar xvf prometheus-*.tar.gz

sudo useradd --no-create-home --shell /bin/false prometheus

sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

sudo mv prometheus-*/prometheus /usr/local/bin/
sudo mv prometheus-*/promtool /usr/local/bin/
sudo mv prometheus-*/consoles /etc/prometheus
sudo mv prometheus-*/console_libraries /etc/prometheus

sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s

scrape_configs:

  - job_name: 'node-exporter'
    static_configs:
      - targets:
        - '10.10.1.10:9100'
        - '10.20.2.10:9100'
EOF

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo "===== INSTALL ALERTMANAGER ====="

cd /tmp

wget https://github.com/prometheus/alertmanager/releases/latest/download/alertmanager-0.27.0.linux-amd64.tar.gz

tar xvf alertmanager-*.tar.gz

sudo useradd --no-create-home --shell /bin/false alertmanager

sudo mv alertmanager-*/alertmanager /usr/local/bin/
sudo mv alertmanager-*/amtool /usr/local/bin/

sudo mkdir -p /etc/alertmanager

sudo tee /etc/alertmanager/alertmanager.yml > /dev/null <<EOF
route:
  receiver: 'default'

receivers:
- name: 'default'
EOF

sudo tee /etc/systemd/system/alertmanager.service > /dev/null <<EOF
[Unit]
Description=Alertmanager
After=network.target

[Service]
User=alertmanager
ExecStart=/usr/local/bin/alertmanager \
--config.file=/etc/alertmanager/alertmanager.yml

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

echo "===== INSTALL GRAFANA ====="

sudo apt install -y apt-transport-https software-properties-common

sudo mkdir -p /etc/apt/keyrings

wget -q -O - https://packages.grafana.com/gpg.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg

echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" \
| sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana

sudo systemctl enable grafana-server
sudo systemctl start grafana-server

echo "===== CONFIGURE GRAFANA DATASOURCE ====="

sudo mkdir -p /etc/grafana/provisioning/datasources

sudo tee /etc/grafana/provisioning/datasources/prometheus.yml > /dev/null <<EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
EOF

sudo systemctl restart grafana-server

echo "===== MONITORING SERVER READY ====="
```
