# Proyek Capstone

## Sistem Monitoring Infrastruktur (Simulasi DC–DRC)

---

# Gambaran Umum

Proyek ini mengimplementasikan **sistem monitoring infrastruktur real-time** untuk lingkungan simulasi **Data Center (DC)** dan **Disaster Recovery Center (DRC)**.

Sistem monitoring mengumpulkan metrik sistem seperti:

* Penggunaan CPU
* Penggunaan memori
* Utilisasi disk
* Trafik jaringan

Metrik dikumpulkan menggunakan **Node Exporter**, di-scrape oleh **Prometheus**, dan divisualisasikan melalui **dashboard Grafana**.

Server monitoring terhubung ke **jaringan DC dan DRC secara bersamaan**, sehingga monitoring terpusat dapat dilakukan tanpa membutuhkan komunikasi langsung antara kedua server.

Pengembangan berikutnya mencakup **integrasi router, sistem alerting, notifikasi Telegram, dan dashboard web monitoring kustom yang mirip NOC pemerintah (gaya Diskominfo)**.

---

# Arsitektur Sistem Saat Ini

Implementasi saat ini menggunakan **server monitoring dual-network** yang terhubung ke kedua jaringan.

```text
                 Monitoring Server
           +------------------------------+
           | Prometheus                   |
           | Grafana                      |
           | Alertmanager (planned)       |
           |                              |
           | Adapter 1 → 10.10.1.100      |
           | Adapter 2 → 10.20.2.100      |
           +--------------+---------------+
                          |
           -------------------------------
           |                             |
     10.10.1.0/24                   10.20.2.0/24
           |                             |
     +------------+                +------------+
     | DC Server  |                | DRC Server |
     |------------|                |------------|
     | Node Exporter               | Node Exporter
     | 10.10.1.10                  | 10.20.2.10
     +------------+                +------------+
```

### Catatan Penting

* DC dan DRC **tidak berkomunikasi secara langsung**
* Server monitoring bertindak sebagai **node monitoring terpusat**
* Setiap server mengekspose metrik melalui **Node Exporter**

---

# Komponen Infrastruktur

## Server Monitoring

Layanan yang berjalan:

* Prometheus
* Grafana
* Alertmanager (direncanakan)

Konfigurasi jaringan:

| Interface | IP          |
| --------- | ----------- |
| Adapter 1 | 10.10.1.100 |
| Adapter 2 | 10.20.2.100 |

Tujuan:

* Melakukan scrape metrik dari server DC
* Melakukan scrape metrik dari server DRC
* Memvisualisasikan metrik menggunakan Grafana

---

## Server DC

| Komponen   | Nilai         |
| ---------- | ------------- |
| Hostname   | dc-server     |
| IP Address | 10.10.1.10    |
| Network    | 10.10.1.0/24  |
| Service    | Node Exporter |

Endpoint metrik:

```
http://10.10.1.10:9100/metrics
```

---

## Server DRC

| Komponen   | Nilai         |
| ---------- | ------------- |
| Hostname   | drc-server    |
| IP Address | 10.20.2.10    |
| Network    | 10.20.2.0/24  |
| Service    | Node Exporter |

Endpoint metrik:

```
http://10.20.2.10:9100/metrics
```

---

# Stack Monitoring

## Prometheus

Prometheus melakukan scrape metrik dari Node Exporter setiap **15 detik**.

Contoh konfigurasi:

```
/etc/prometheus/prometheus.yml
```

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node-exporter"

    static_configs:
      - targets: ["10.10.1.10:9100"]
        labels:
          server: "dc-server"
          location: "DC"

      - targets: ["10.20.2.10:9100"]
        labels:
          server: "drc-server"
          location: "DRC"
```

---

## Node Exporter

Node Exporter mengumpulkan metrik tingkat sistem, termasuk:

* Penggunaan CPU
* Penggunaan memori
* Penggunaan disk
* Trafik jaringan
* Beban sistem
* Uptime sistem

Format endpoint metrik:

```
http://<server-ip>:9100/metrics
```

---

## Grafana

Grafana memvisualisasikan metrik Prometheus menggunakan dashboard.

Dashboard yang digunakan:

```
Node Exporter Full
```

Metrik yang ditampilkan mencakup:

* Penggunaan CPU
* Penggunaan memori
* Utilisasi disk
* Trafik jaringan
* Beban sistem
* Uptime

---

# Pengujian & Simulasi

## Uji Stress CPU

Jalankan di server DC atau DRC:

```
stress-ng --cpu 4 --timeout 60s
```

Hasil yang diharapkan:

* Lonjakan penggunaan CPU terlihat pada dashboard Grafana.

---

## Uji Stress Memori

```
stress-ng --vm 2 --vm-bytes 1G --timeout 60s
```

Hasil yang diharapkan:

* Penggunaan memori meningkat.

---

## Uji Disk I/O

```
stress-ng --hdd 2 --timeout 60s
```

Hasil yang diharapkan:

* Lonjakan aktivitas disk terlihat di Grafana.

---

## Uji Trafik Jaringan

Karena DC dan DRC terisolasi, pengujian jaringan dilakukan **antara masing-masing server dan server monitoring**.

Jalankan server iperf3 di server monitoring:

```
iperf3 -s
```

Jalankan client dari server DC:

```
iperf3 -c 10.10.1.100 -t 60
```

Jalankan client dari server DRC:

```
iperf3 -c 10.20.2.100 -t 60
```

Hasil yang diharapkan:

* Lonjakan trafik jaringan terlihat pada dashboard Grafana.

---

# Fitur yang Sudah Diimplementasikan

* Monitoring infrastruktur multi-server
* Scrape metrik dengan Prometheus
* Dashboard visualisasi Grafana
* Simulasi stress resource
* Simulasi trafik jaringan
* Server monitoring dual-network

---

# TODO / Pengembangan Selanjutnya

## 1 Integrasi Router (Arsitektur Ideal)

Untuk mensimulasikan lingkungan infrastruktur yang lebih realistis, akan ditambahkan **VM router** untuk menghubungkan jaringan DC dan DRC.

Topologi ideal:

```text
                +-------------------------+
                |     Monitoring Server   |
                |-------------------------|
                | Prometheus              |
                | Grafana                 |
                +-----------+-------------+
                            |
            -----------------------------------
            |                                 |
       10.10.1.0/24                     10.20.2.0/24
            |                                 |
      +------------+                   +------------+
      | DC Server  |                   | DRC Server |
      +------+-----+                   +------+-----+
             \                               /
              \                             /
               \                           /
                +-------------------------+
                |        Router VM        |
                | 10.10.1.1               |
                | 10.20.2.1               |
                +-------------------------+
```

Manfaat:

* Memungkinkan komunikasi DC ↔ DRC
* Mendukung **pengujian iperf3 lintas jaringan**
* Mensimulasikan routing infrastruktur nyata

---

## 2 Sistem Alerting

Mengimplementasikan aturan alert menggunakan **Prometheus Alertmanager**.

Rencana alert:

Alert CPU

```
CPU usage > 80%
```

Alert Memori

```
Memory usage > 85%
```

Alert Disk

```
Disk usage > 90%
```

---

## 3 Integrasi Bot Telegram

Alert akan dikirim langsung kepada administrator melalui Telegram.

Contoh notifikasi:

```
⚠ Infrastructure Alert

Server: dc-server
Metric: CPU Usage
Value: 92%

Status: High Resource Usage
```

---

## 4 Dashboard Web Monitoring (Gaya Diskominfo)

Mengembangkan antarmuka monitoring kustom yang mirip dengan **dashboard Network Operations Center**.

Fitur yang direncanakan:

* Gambaran kesehatan server secara real-time
* Perbandingan DC vs DRC
* Indikator status infrastruktur
* Panel Grafana yang di-embed

Teknologi yang memungkinkan:

* React / Next.js
* Dashboard HTML sederhana
* Panel embed Grafana

---

# Teknologi yang Digunakan

| Teknologi     | Kegunaan                 |
| ------------- | ------------------------ |
| Prometheus    | Pengumpulan metrik       |
| Grafana       | Visualisasi monitoring   |
| Node Exporter | Exporter metrik sistem   |
| Alertmanager  | Routing alert            |
| stress-ng     | Pengujian stress resource|
| iperf3        | Pengujian jaringan       |
| VMware        | Infrastruktur virtual    |

---

# Tujuan Proyek

Tujuan proyek ini adalah menunjukkan bagaimana **sistem monitoring modern mendeteksi masalah infrastruktur secara real-time**, sehingga administrator dapat dengan cepat mengidentifikasi masalah performa dan anomali sistem.

Proyek ini mensimulasikan **sistem monitoring skala kecil yang mirip dengan yang digunakan di data center produksi dan network operations center (NOC) pemerintah**.
