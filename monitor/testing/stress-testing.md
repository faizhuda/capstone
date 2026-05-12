# Stress & Failure Testing

Dokumentasi pengujian performa dan simulasi failure pada sistem monitoring DC–DRC.

---

# 1. CPU Stress Test

## Command

```bash
stress-ng --cpu 4 --timeout 60s
```

## Tujuan

Mensimulasikan penggunaan CPU tinggi pada server.

## Expected Result

- CPU usage meningkat di Grafana
- Alert `HighCPUUsage` muncul
- Notifikasi Telegram terkirim

---

# 2. Memory Stress Test

## Command

```bash
stress-ng --vm 2 --vm-bytes 1G --timeout 60s
```

## Tujuan

Mensimulasikan penggunaan memori tinggi.

## Expected Result

- Penggunaan RAM meningkat
- Grafik memory usage berubah secara real-time

---

# 3. Disk Stress Test

## Command

```bash
stress-ng --hdd 2 --timeout 60s
```

## Tujuan

Mensimulasikan aktivitas disk tinggi.

## Expected Result

- Disk I/O meningkat
- Grafana menunjukkan lonjakan disk activity

---

# 4. Network Test

## Command

Jalankan iperf3 server:

```bash
iperf3 -s
```

Jalankan client:

```bash
iperf3 -c 10.20.2.10
```

## Tujuan

Mengukur performa jaringan antar subnet melalui Router VM.

## Expected Result

- Trafik jaringan meningkat
- Routing DC ↔ DRC berjalan normal

---

# 5. Node Down Test

## Command

```bash
sudo systemctl stop node_exporter
```

## Tujuan

Mensimulasikan service monitoring mati.

## Expected Result

- Target menjadi DOWN di Prometheus
- Alert `NodeDown` aktif
- Telegram mengirim notifikasi

---

# 6. Full Server Shutdown Test

## Command

```bash
sudo poweroff
```

## Tujuan

Mensimulasikan server failure.

## Expected Result

- Prometheus gagal scraping
- Alert critical muncul
- Monitoring menunjukkan server offline

---

# 7. Routing Test

## Command

```bash
ping 10.20.2.10
```

## Tujuan

Memastikan Router VM dapat meneruskan paket antar subnet.

## Expected Result

- Ping berhasil
- Latency stabil
- Inter-subnet communication berjalan

---

# 8. Scraping Latency Test

## Command

```bash
curl -w "\nTIME: %{time_total}\n" http://10.20.2.10:9100/metrics -o /dev/null
```

## Tujuan

Mengukur waktu scraping Prometheus ke DRC.

## Expected Result

- Metrics dapat diakses
- Response time stabil

---

# Kendala yang Ditemui

Meskipun router telah berhasil diimplementasikan sehingga komunikasi antara DC dan DRC dapat berjalan dengan baik, masih ditemukan kendala pada proses scraping metrik dari DRC oleh monitoring server.

Keterbatasan virtual network VMware, khususnya pada IP forwarding dan packet forwarding antar virtual interface, menyebabkan latensi dan koneksi menjadi fluktuatif.

Dampaknya, proses scraping Prometheus terkadang lambat atau mengalami timeout (`context deadline exceeded`).

## Solusi Sementara

Meningkatkan timeout Prometheus:

```yaml
scrape_timeout: 10s
```

---