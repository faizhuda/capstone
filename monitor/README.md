# Monitoring Server

Monitoring Server merupakan pusat observability yang bertugas:

- Mengumpulkan metrics menggunakan Prometheus
- Menampilkan dashboard Grafana
- Mengirim alert melalui Alertmanager & Telegram

## Services

- Prometheus
- Grafana
- Alertmanager

## Network

| Interface | IP |
|----------|----|
| ens33 | 10.10.1.100 |
| ens37 | 192.168.163.x |

## Fungsi

- Monitoring DC & DRC
- Alerting
- Visualization