```bash
#!/bin/bash

echo "===== SETUP TARGET SERVER START ====="

sudo apt update
sudo apt upgrade -y

echo "Installing basic tools..."

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
python3-pip \
openssh-server \
stress-ng \
iperf3

sudo systemctl enable ssh
sudo systemctl start ssh

echo "===== INSTALL NODE EXPORTER ====="

cd /tmp

wget https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-1.8.2.linux-amd64.tar.gz

tar xvf node_exporter-*.tar.gz

sudo useradd --no-create-home --shell /bin/false node_exporter

sudo mv node_exporter-*/node_exporter /usr/local/bin/

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

echo "===== CLEAN SYSTEM FOR GOLDEN IMAGE ====="

sudo apt clean
sudo journalctl --vacuum-time=1d

echo "===== TARGET SERVER READY ====="
```
