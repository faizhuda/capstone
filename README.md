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
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "dc-server"
    static_configs:
      - targets: ["10.10.1.10:9100"]
        labels:
          server: "DC Server"
          location: "Data Center"

  - job_name: "drc-server"
    static_configs:
      - targets: ["10.10.1.20:9100"]
        labels:
          server: "DRC Server"
          location: "Disaster Recovery Center"

  - job_name: "router"
    static_configs:
      - targets: ["10.10.1.2:9100"]
        labels:
          server: "Router VM"
          role: "gateway"
```

---

## 🔹 Grafana

Digunakan untuk visualisasi monitoring dashboard.

Dashboard menampilkan:

- Business Continuity Status (indikator kegagalan DC dan failover DRC)
- Status konektivitas masing-masing Node (DC, DRC, Router, Monitoring Server)
- Panel performa DC Server, DRC Server, dan Router VM (CPU, RAM, Disk, Traffic Jaringan)
- Metrik System Health (Load Average komparatif dan Uptime masing-masing Node)

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
| HighNetworkTraffic | Traffic > 10 MB/s selama 1 menit |
| HighLoad | Load average per core > 1.5 selama 1 menit |
| HighDiskIOWait | Disk I/O wait > 20% selama 1 menit |
| NodeDown | Server tidak dapat diakses |

---

# Integrasi Telegram

Contoh alert Telegram (format aktual yang diterima):

```text
INFRASTRUCTURE ALERT
────────────────────────
Server    : dc-server
Severity  : warning

Penggunaan CPU Tinggi
Penggunaan CPU pada dc-server melebihi 80% selama 1 menit.

Fired: 03 Jun 2026, 14:30 WIB
────────────────────────
```

Contoh alert resolved:

```text
ALERT RESOLVED
────────────────────────
Server    : dc-server
Severity  : warning

Penggunaan CPU Tinggi
Penggunaan CPU pada dc-server melebihi 80% selama 1 menit.

Resolved: 03 Jun 2026, 14:33 WIB
────────────────────────
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

## ❌ SSH ke Router VM connection refused

### Penyebab
IP `10.10.1.1` diambil oleh VMware Host Virtual Network Adapter di Windows, bukan oleh Router VM. Ping ke `10.10.1.1` menjawab dengan TTL=128 (Windows), bukan TTL=64 (Linux).

### Solusi
Ganti IP Router VM dari `10.10.1.1` ke `10.10.1.2` di `/etc/netplan/50-cloud-init.yaml`, lalu jalankan `sudo netplan apply`.

---

## ❌ Grafana anonymous access tidak berfungsi (Grafana 12)

### Penyebab
Grafana versi 12 menggunakan API baru berbasis Kubernetes (`/apis/dashboard.grafana.app/v1beta1/`) yang tidak mendukung anonymous access dengan benar.

### Solusi
Buat akun viewer khusus dan set folder permissions agar dapat diakses oleh role Viewer:

```bash
curl -X POST http://<admin>:<password>@localhost:3000/api/admin/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Viewer","login":"viewer","password":"viewer123","role":"Viewer"}'
```

Kemudian set folder permissions via Grafana UI: Dashboards -> folder -> Manage permissions -> Add Viewer role.

---

# Teknologi yang Digunakan

| Teknologi | Versi | Fungsi |
|---|---|---|
| Prometheus | latest | Metrics scraping dan alert evaluation |
| Grafana | 12.4.1 | Visualisasi dashboard |
| Alertmanager | latest | Alert routing dan notifikasi |
| Node Exporter | 1.10.2 | Metrics collection per server |
| Telegram Bot | - | Notifikasi alert real-time |
| Cloudflare Tunnel | latest | Public access tanpa port forwarding |
| VMware Workstation | latest | Virtualisasi infrastruktur |
| stress-ng | - | Stress testing resource |
| iperf3 | - | Network traffic testing |
| Ubuntu Server | 24.04 LTS | Operating system semua VM |

---

# Akses Publik

Dashboard Grafana dapat diakses secara publik melalui Cloudflare Tunnel.

## Cara Akses

Buka URL tunnel yang aktif di browser. Dashboard langsung tampil tanpa login.

Untuk akses dengan privileges viewer (read-only):

| Field | Value |
|---|---|
| Username | viewer |
| Password | viewer123 |

## Menjalankan Tunnel

```bash
ssh monitoring
cloudflared tunnel --url http://localhost:3000
```

Salin URL yang muncul, contoh:

```text
https://xxxx-xxxx-xxxx.trycloudflare.com
```

> Catatan: URL trycloudflare.com bersifat sementara dan berubah setiap kali
> cloudflared direstart. Untuk URL permanen, gunakan Named Tunnel dengan domain
> sendiri yang didaftarkan ke Cloudflare.

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
Monitoring System Fully Operational.
Public Access: Active via Cloudflare Tunnel.
Alerting: Active via Telegram Bot.
```