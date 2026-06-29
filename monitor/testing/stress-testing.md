# Alert Testing Cheatsheet

Dokumentasi command untuk simulasi dan testing seluruh 7 alert pada sistem monitoring.
Seluruh perintah dieksekusi pada **DC Server (10.10.1.10)** sebagai node representatif.

---

# 1. NodeDown Alert

## Tujuan
Mensimulasikan server tidak dapat diakses oleh Prometheus.

## Command

```bash
sudo systemctl stop node_exporter
```

## Expected Alert

```text
Server Tidak Dapat Diakses
```

## Recovery

```bash
sudo systemctl start node_exporter
```

---

# 2. HighCPUUsage + HighLoad Alert

> Satu perintah memicu dua alert sekaligus: HighCPUUsage (node_cpu_seconds_total)
> dan HighLoad (node_load1). Keduanya diukur sebagai skenario independen karena
> menggunakan ekspresi PromQL yang berbeda.

## Threshold

```text
CPU > 80% selama 1 menit
Load average per vCPU > 1.5 selama 1 menit
```

## Command

```bash
stress-ng --cpu 4 --timeout 120s
```

## Recovery

Tunggu proses selesai otomatis atau:

```bash
pkill stress-ng
```

---

# 3. HighMemoryUsage Alert

## Threshold

```text
RAM > 80% selama 1 menit
```

## Command

```bash
stress-ng --vm 2 --vm-bytes 90% --timeout 120s
```

## Recovery

```bash
pkill stress-ng
```

---

# 4. HighDiskUsage Alert

## Threshold

```text
Storage > 80% selama 1 menit
```

## Command

```bash
SIZE=$(df --output=avail -B1 / | tail -1 | awk '{print int($1*0.9)}')
fallocate -l $SIZE /tmp/fill.img && rm /tmp/fill.img
```

Ukuran file disesuaikan otomatis agar disk usage melebihi 80%, kemudian
file dihapus setelah selesai.

---

# 5. HighDiskIOWait Alert

## Threshold

```text
Disk I/O wait > 20% selama 1 menit
```

## Command

```bash
stress-ng --hdd 2 --hdd-bytes 1G --timeout 120s
```

## Recovery

```bash
pkill stress-ng
```

---

# 6. HighNetworkTraffic Alert

## Threshold

```text
Traffic > 10 MB/s selama 1 menit
```

## Setup Server (DRC Server — 10.10.1.20)

```bash
iperf3 -s
```

## Command (DC Server)

```bash
iperf3 -c 10.10.1.20 -t 120
```

## Recovery

```bash
# Ctrl+C pada kedua sisi
```

---

# Monitoring Dashboard

## Prometheus

```text
http://10.10.1.100:9090
```

## Grafana

```text
http://10.10.1.100:3000
```

## Alertmanager

```text
http://10.10.1.100:9093
```

---

# Catatan

- Semua threshold menggunakan klausul `for: 1m` — alert hanya firing jika kondisi
  bertahan minimal 1 menit, bukan akibat lonjakan sesaat.
- Jika NodeDown aktif pada suatu instance, alert resource (CPU/Memory/Disk/Load/Network/IOWait)
  untuk instance yang sama akan di-suppress otomatis via inhibit_rules.
- Spesifikasi VM target pengujian: DC Server 1 vCPU, 1 GB RAM (10.10.1.10).
- Monitoring Server memiliki 2 vCPU, 2 GB RAM dan tidak digunakan sebagai target stress test.
