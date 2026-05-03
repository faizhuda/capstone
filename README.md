# Proyek Capstone

## Sistem Monitoring Infrastruktur (Simulasi DC–DRC + Alerting Real-Time)

---

# Gambaran Umum

Proyek ini mengimplementasikan **sistem monitoring infrastruktur real-time** untuk lingkungan simulasi **Data Center (DC)** dan **Disaster Recovery Center (DRC)**.

Sistem ini mampu:

* Mengumpulkan metrik sistem (CPU, memory, disk, network)
* Menampilkan visualisasi real-time
* Mengirim alert otomatis ke Telegram
* Memonitor multi-network secara terpusat

Stack utama:

* **Node Exporter** → pengambil metrik
* **Prometheus** → pengumpul data
* **Grafana** → visualisasi
* **Alertmanager** → sistem alerting
* **Telegram Bot** → notifikasi

---

# Arsitektur Sistem (UPDATED)

```text
                     INTERNET
                         |
                   (VMware NAT)
                  192.168.163.0/24
                         |
               +----------------------+
               |  Monitoring Server   |
               |----------------------|
               | Prometheus           |
               | Grafana              |
               | Alertmanager         |
               |                      |
               | ens33 → 10.10.1.100  |
               | ens34 → 192.168.163.x|
               +----------+-----------+
                          |
        ----------------------------------------
        |                                      |
   10.10.1.0/24                         10.20.2.0/24
        |                                      |
  +-------------+                      +-------------+
  | DC Server   |                      | DRC Server  |
  |-------------|                      |-------------|
  | Node Exporter                     | Node Exporter
  | 10.10.1.10                        | 10.20.2.10
  +-------------+                      +-------------+
```

---

# Konsep Penting

* Monitoring server memiliki **2 network + 1 NAT**
* DC & DRC **tidak saling terhubung langsung**
* Semua komunikasi melalui monitoring server
* Internet digunakan untuk **alert Telegram**

---

# Komponen Infrastruktur

## Monitoring Server

Layanan:

* Prometheus
* Grafana
* Alertmanager

Network:

| Interface | IP                           |
| --------- | ---------------------------- |
| ens33     | 10.10.1.100                  |
| ens37     | 192.168.163.x (NAT Internet) |

Fungsi:

* Scrape metrik dari DC & DRC
* Visualisasi data
* Kirim alert ke Telegram

---

## DC Server

| Field    | Value         |
| -------- | ------------- |
| Hostname | dc-server     |
| IP       | 10.10.1.10    |
| Service  | Node Exporter |

---

## DRC Server

| Field    | Value         |
| -------- | ------------- |
| Hostname | drc-server    |
| IP       | 10.20.2.10    |
| Service  | Node Exporter |

---

# Monitoring Stack

## Prometheus

Scrape setiap 15 detik

```yaml
scrape_configs:
  - job_name: "node-exporter"
    static_configs:
      - targets: ["10.10.1.10:9100"]
        labels:
          job: "dc-server"

      - targets: ["10.20.2.10:9100"]
        labels:
          job: "drc-server"
```

---

## Grafana

Dashboard:

* Node Exporter Full

Menampilkan:

* CPU usage
* Memory usage
* Disk usage
* Network traffic
* System load

---

## Alertmanager (AKTIF)

```yaml
route:
  receiver: telegram
  group_by: ['alertname', 'instance']
  group_wait: 10s
  group_interval: 30s
  repeat_interval: 5m

receivers:
  - name: telegram
    telegram_configs:
      - bot_token: "YOUR_TOKEN"
        chat_id: YOUR_CHAT_ID
        parse_mode: Markdown
        send_resolved: true
```

---

# Alert yang Diimplementasikan

## High CPU Usage

```yaml
CPU usage > 80%
```

## Node Down

```yaml
up == 0
```

---

# Integrasi Telegram (SUDAH BERJALAN)

Contoh notifikasi:

```
🚨 HighCPUUsage

Instance: 10.10.1.10:9100
Severity: warning

CPU usage > 80%
```

---

# Pengujian

## CPU Stress

```
stress-ng --cpu 4 --timeout 60s
```

---

## Memory Stress

```
stress-ng --vm 2 --vm-bytes 1G --timeout 60s
```

---

## Disk Stress

```
stress-ng --hdd 2 --timeout 60s
```

---

## Network Test

```
iperf3 -c 10.10.1.100
```

---

# Fitur yang Sudah Diimplementasikan

* Monitoring multi-server (DC & DRC)
* Prometheus scraping
* Dashboard Grafana
* Alert otomatis (CPU & Node Down)
* Notifikasi Telegram real-time
* Dual network monitoring server
* NAT internet integration
* Routing antar network

---

# Masalah yang Ditemui & Solusi

## ❌ Tidak bisa akses internet

Penyebab:

* Subnet VM tidak sesuai NAT

Solusi:

* Samakan subnet dengan VMnet8 (192.168.163.0/24)

---

## ❌ DNS gagal

Penyebab:

* resolv.conf default stub

Solusi:

* set DNS ke 8.8.8.8

---

## ❌ Telegram tidak mengirim

Penyebab:

* Tidak ada koneksi internet

Solusi:

* Tambah adapter NAT

---

# Pengembangan Selanjutnya

* Dashboard NOC custom (React)
* Multi Alert Channel (Email + Telegram)
* High Availability Prometheus
* Auto-recovery system (self healing)
* Failover DC → DRC

---

# Teknologi

| Tools         | Fungsi       |
| ------------- | ------------ |
| Prometheus    | Monitoring   |
| Grafana       | Dashboard    |
| Node Exporter | Metrics      |
| Alertmanager  | Alert        |
| Telegram Bot  | Notifikasi   |
| VMware        | Virtualisasi |
| stress-ng     | Testing      |
| iperf3        | Network test |

---

# Tujuan

Membangun sistem monitoring modern yang:

* Real-time
* Terpusat
* Otomatis
* Siap digunakan di environment production kecil

---

# Status Proyek

```
Works Locally, Next Up: Deployment
```