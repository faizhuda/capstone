# Proyek Capstone

## Sistem Monitoring Infrastruktur (Simulasi DC–DRC + Router + Alerting Real-Time)

---

# Gambaran Umum

Proyek ini mengimplementasikan sistem monitoring infrastruktur real-time untuk lingkungan simulasi:

- Data Center (DC)
- Disaster Recovery Center (DRC)

yang dimonitor secara terpusat menggunakan Monitoring Server berbasis:

- Prometheus
- Grafana
- Alertmanager

Sistem monitoring ini mampu:

- Mengumpulkan metrik sistem secara real-time
- Menampilkan visualisasi monitoring dashboard
- Mengirim alert otomatis ke Telegram
- Melakukan simulasi stress testing server
- Mensimulasikan arsitektur infrastruktur data center sederhana

---

# Arsitektur Sistem (FINAL)

```text
                         INTERNET
                             |
                       (VMware NAT)
                      192.168.163.0/24
                             |
               +------------------------------+
               |     Monitoring Server        |
               |------------------------------|
               | Prometheus                  |
               | Grafana                     |
               | Alertmanager                |
               |                             |
               | ens33 → 10.10.1.100         |
               | ens37 → 192.168.163.x       |
               +-------------+---------------+
                             |
                      10.10.1.0/24
                             |
                    +----------------+
                    |   Router VM    |
                    |----------------|
                    | 10.10.1.2      |
                    +--------+-------+
                             |
         ------------------------------------------------
         |                                              |
 +---------------+                             +---------------+
 |   DC Server   |                             |  DRC Server   |
 |---------------|                             |---------------|
 | 10.10.1.10    |                             | 10.10.1.20    |
 | Node Exporter |                             | Node Exporter |
 +---------------+                             +---------------+
```

---

# Konsep Arsitektur

## 🔹 Router sebagai Core Network

Router VM berfungsi sebagai:

- Simulasi core network infrastructure
- Gateway utama seluruh VM
- Simulasi environment enterprise/data center
- Penghubung trafik monitoring dan testing

---

## 🔹 Monitoring Terpusat

Monitoring Server bertugas untuk:

- Melakukan scraping metrics dari DC & DRC
- Menampilkan visualisasi monitoring
- Mengirim alert otomatis ke Telegram
- Menjadi pusat observability seluruh infrastruktur

---

## 🔹 Single Subnet Optimization

Seluruh VM ditempatkan dalam satu subnet:

```text
10.10.1.0/24
```

Tujuan:

- Mengurangi latency VMware virtual network
- Menghindari timeout scraping Prometheus
- Meningkatkan stabilitas monitoring
- Menyederhanakan troubleshooting

---

# Infrastruktur VM

| VM | CPU | RAM | Fungsi |
|---|---|---|---|
| Monitoring Server | 2 vCPU | 2 GB | Monitoring Stack |
| Router VM | 1 vCPU | 1 GB | Core Network |
| DC Server | 1 vCPU | 1 GB | Simulasi Data Center |
| DRC Server | 1 vCPU | 1 GB | Simulasi Disaster Recovery |

---

# IP Addressing

| Device | IP Address |
|---|---|
| Monitoring Server | 10.10.1.100 |
| Router VM | 10.10.1.2 |
| DC Server | 10.10.1.10 |
| DRC Server | 10.10.1.20 |

---

# Monitoring Stack

## 🔹 Prometheus

Digunakan untuk:

- Metrics scraping
- Time-series database
- Alert rule evaluation

Scrape interval:

```yaml
15s
```

Contoh target:

```yaml
scrape_configs:
  - job_name: "node-exporter"
    static_configs:
      - targets: ["10.10.1.10:9100"]
        labels:
          job: "dc-server"

      - targets: ["10.10.1.20:9100"]
        labels:
          job: "drc-server"
```

---

## 🔹 Grafana

Digunakan untuk visualisasi monitoring dashboard.

Dashboard menampilkan:

- CPU Usage
- Memory Usage
- Disk Usage
- Network Traffic

---

## 🔹 Alertmanager

Digunakan untuk:

- Mengelola alert Prometheus
- Mengirim notifikasi Telegram
- Grouping alert
- Real-time notification

---

# Alert yang Diimplementasikan

| Alert | Threshold |
|---|---|
| HighCPUUsage | CPU > 80% selama 1 menit |
| HighMemoryUsage | RAM > 80% selama 1 menit |
| HighDiskUsage | Storage > 80% |
| HighNetworkTraffic | Traffic > 80 Mbps selama 1 menit |
| NodeDown | Server tidak dapat diakses |

---

# Integrasi Telegram

Contoh alert Telegram:

```text
🚨 HighCPUUsage

🖥️ Server: dc-server
⚠️ Severity: warning

📝 Summary:
Penggunaan CPU Tinggi

📖 Description:
Penggunaan CPU pada dc-server melebihi 80% selama 1 menit.
```

## Konfigurasi Token Telegram

Edit file `monitor/alertmanager/alertmanager.yml` dan isi placeholder berikut:

| Field | Cara Mendapatkan |
|---|---|
| `bot_token` | Buat bot baru via [@BotFather](https://t.me/BotFather), salin token yang diberikan |
| `chat_id` | Kirim pesan ke bot, lalu buka `https://api.telegram.org/bot<TOKEN>/getUpdates` dan ambil nilai `chat.id` |

Setelah diisi, restart Alertmanager:

```bash
sudo cp monitor/alertmanager/alertmanager.yml /etc/alertmanager/
sudo systemctl restart alertmanager
```

> ⚠️ Jangan commit token asli ke Git. File `.gitignore` sudah mengabaikan
> `token.txt`, `secrets.yml`, dan `.env`. Biarkan placeholder `YOUR_TOKEN`
> di repo, isi nilai asli hanya di file `/etc/alertmanager/` pada VM.

---

# Pengujian Sistem

## 🔥 CPU Stress Test

```bash
stress-ng --cpu 4 --timeout 120s
```

---

## 🧠 Memory Stress Test

```bash
stress-ng --vm 2 --vm-bytes 90% --timeout 120s
```

---

## 💽 Disk Usage Stress Test

```bash
fallocate -l 6G bigfile.test
```

Hapus file setelah testing:

```bash
rm bigfile.test
```

---

## 🌐 Network Stress Test

### DRC Server

```bash
iperf3 -s
```

### DC Server

```bash
iperf3 -c 10.10.1.20 -t 120
```

---

## 🚨 Node Down Test

```bash
sudo systemctl stop node_exporter
```

Menyalakan kembali:

```bash
sudo systemctl start node_exporter
```

---

# Fitur yang Sudah Diimplementasikan

- Centralized monitoring DC & DRC
- Real-time Grafana dashboard
- Prometheus metrics scraping
- Telegram alert notification
- Stress testing simulation
- Single subnet infrastructure optimization
- VMware virtual infrastructure simulation
- Core router simulation
- Real-time observability system

---

# Masalah & Solusi

## ❌ Scraping DRC tidak stabil

### Penyebab
VMware virtual networking menyebabkan latency dan timeout ketika menggunakan multi-subnet routing.

### Solusi
Seluruh VM dipindahkan ke subnet yang sama untuk meningkatkan stabilitas scraping Prometheus.

---

## ❌ Telegram alert tidak terkirim

### Solusi

- Pastikan Monitoring Server memiliki akses internet
- Pastikan bot token dan chat ID benar
- Pastikan Alertmanager aktif

---

# Teknologi yang Digunakan

| Teknologi | Fungsi |
|---|---|
| Prometheus | Monitoring |
| Grafana | Visualisasi |
| Alertmanager | Alert System |
| Node Exporter | Metrics Collection |
| Telegram Bot | Notifikasi |
| VMware Workstation | Virtualisasi |
| stress-ng | Stress Testing |
| iperf3 | Network Testing |
| Ubuntu Server | Operating System |

---

# Pengembangan Selanjutnya

- VPS deployment
- Public monitoring access

---

# Tujuan Proyek

Membangun sistem monitoring infrastruktur modern yang:

- Real-time
- Terpusat
- Berbasis observability
- Mendukung alert otomatis

---

# Status Proyek

```text
Monitoring System Fully Operational Locally.
Next Phase: VPS Deployment & Public Hosting.
```