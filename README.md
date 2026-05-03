# Proyek Capstone

## Sistem Monitoring Infrastruktur (Simulasi DC–DRC + Router + Alerting Real-Time)

---

# Gambaran Umum

Proyek ini mengimplementasikan **sistem monitoring infrastruktur real-time** untuk lingkungan simulasi:

* **Data Center (DC)**
* **Disaster Recovery Center (DRC)**

yang dihubungkan melalui **Router VM**, serta dimonitor oleh **Monitoring Server terpusat**.

Sistem ini mampu:

* Mengumpulkan metrik sistem (CPU, Memory, Disk, Network)
* Menampilkan visualisasi real-time (Grafana)
* Mengirim alert otomatis ke Telegram
* Mensimulasikan arsitektur jaringan nyata (DC ↔ DRC via Router)

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
               | ens33 → 10.10.1.100 (DC)    |
               | ens37 → 192.168.163.x (NAT) |
               +-------------+---------------+
                             |
                      10.10.1.0/24
                             |
                      +--------------+
                      |  Router VM   |
                      |--------------|
                      | 10.10.1.1    |
                      | 10.20.2.1    |
                      +------+-------+
                             |
                ------------------------------
                |                            |
        10.10.1.0/24                10.20.2.0/24
                |                            |
        +-------------+              +-------------+
        | DC Server   |              | DRC Server  |
        |-------------|              |-------------|
        | Node Exporter              | Node Exporter
        | 10.10.1.10                | 10.20.2.10
        +-------------+              +-------------+
```

---

# Konsep Arsitektur

## 🔹 Router sebagai Core Network

Router VM berfungsi sebagai:

* Penghubung jaringan DC dan DRC
* Gateway antar subnet
* Simulasi network layer seperti di dunia nyata

👉 Tanpa router:
DC dan DRC tidak bisa saling komunikasi

---

## 🔹 Monitoring Terpusat

Monitoring Server:

* Terhubung ke DC secara langsung
* Mengakses DRC melalui router
* Memiliki akses internet (NAT) untuk alert Telegram

---

## 🔹 Hybrid Network Model

Arsitektur ini mensimulasikan:

* **Internal network (DC & DRC)**
* **Routing layer (Router VM)**
* **External connectivity (Internet via NAT)**

---

# Komponen Infrastruktur

## 🖥 Monitoring Server

| Komponen | Nilai                             |
| -------- | --------------------------------- |
| IP (DC)  | 10.10.1.100                       |
| IP (NAT) | 192.168.163.x                     |
| Services | Prometheus, Grafana, Alertmanager |

Fungsi:

* Scrape metrik DC & DRC
* Visualisasi data
* Mengirim alert ke Telegram

---

## 🌐 Router VM

| Interface   | IP        |
| ----------- | --------- |
| DC Network  | 10.10.1.1 |
| DRC Network | 10.20.2.1 |

Fungsi:

* Routing antar jaringan
* Gateway DC & DRC
* Simulasi infrastruktur real

---

## 🏢 DC Server

| Field    | Value         |
| -------- | ------------- |
| Hostname | dc-server     |
| IP       | 10.10.1.10    |
| Gateway  | 10.10.1.1     |
| Service  | Node Exporter |

---

## 🏭 DRC Server

| Field    | Value         |
| -------- | ------------- |
| Hostname | drc-server    |
| IP       | 10.20.2.10    |
| Gateway  | 10.20.2.1     |
| Service  | Node Exporter |

---

# Monitoring Stack

## 🔹 Prometheus

Scrape interval: **15 detik**

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

## 🔹 Grafana

Dashboard:

* Node Exporter Full

Menampilkan:

* CPU usage
* Memory usage
* Disk usage
* Network traffic
* System load

---

## 🔹 Alertmanager

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

## 🔥 High CPU Usage

```
CPU usage > 80%
```

## 🚨 Node Down

```
up == 0
```

---

# Integrasi Telegram

Contoh notifikasi:

```
🚨 HighCPUUsage
Instance: 10.10.1.10:9100
Severity: warning
CPU usage > 80%
```

---

# Pengujian Sistem

## CPU Stress

```
stress-ng --cpu 4 --timeout 60s
```

## Memory Stress

```
stress-ng --vm 2 --vm-bytes 1G --timeout 60s
```

## Disk Stress

```
stress-ng --hdd 2 --timeout 60s
```

## Network Test (via Router)

```
iperf3 -c 10.20.2.10
```

---

# Fitur yang Sudah Diimplementasikan

* Monitoring DC & DRC secara terpusat
* Routing antar network menggunakan Router VM
* Prometheus scraping
* Grafana dashboard
* Alert otomatis
* Notifikasi Telegram real-time
* NAT internet integration
* Simulasi arsitektur real-world

---

# Masalah & Solusi

## ❌ NAT tidak bekerja

✔ Solusi: samakan subnet dengan VMnet8

## ❌ DNS gagal

✔ Solusi: set DNS manual (8.8.8.8)

## ❌ Telegram tidak mengirim

✔ Solusi: pastikan koneksi internet aktif

---

# Pengembangan Selanjutnya

* Dashboard NOC (React)
* Multi-channel alert (Email, Discord)
* High Availability Prometheus
* Auto recovery (self-healing)
* Failover DC → DRC

---

# Teknologi

| Tools         | Fungsi       |
| ------------- | ------------ |
| Prometheus    | Monitoring   |
| Grafana       | Visualisasi  |
| Node Exporter | Metrics      |
| Alertmanager  | Alert        |
| Telegram Bot  | Notifikasi   |
| VMware        | Virtualisasi |
| stress-ng     | Testing      |
| iperf3        | Network      |

---

# Tujuan

Membangun sistem monitoring modern yang:

* Real-time
* Terpusat
* Berbasis alert
* Mendekati implementasi di dunia nyata

---

# Status Proyek

```
Works Locally, Next Up: Deployment.
```
