# Install Node Exporter

## Download Node Exporter

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
```

## Extract

```bash
tar xvf node_exporter-1.10.2.linux-amd64.tar.gz
```

## Move Binary

```bash
sudo cp node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/
```

## Buat User & Systemd Service

Agar Node Exporter tetap berjalan walau SSH session ditutup dan
otomatis start saat boot, jalankan sebagai systemd service:

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter

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
```

## Verify Service

```bash
sudo systemctl status node_exporter
```

## Verify Metrics

```bash
curl localhost:9100/metrics
```