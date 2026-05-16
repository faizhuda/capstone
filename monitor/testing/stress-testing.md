# 🚨 Alert Testing Cheatsheet

Dokumentasi command untuk melakukan simulasi dan testing seluruh alert pada sistem monitoring.

---

# 1. Node Down Alert

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

# 2. High CPU Usage Alert

## Threshold

```text
CPU > 80% selama 1 menit
```

## Command

```bash
stress-ng --cpu 1 --timeout 120s
```

## Monitoring

Grafana:
- CPU Usage naik > 80%

Telegram:
- Alert HighCPUUsage muncul

## Recovery

Tunggu proses selesai otomatis atau:

```bash
pkill stress-ng
```

---

# 3. High Memory Usage Alert

## Threshold

```text
RAM > 80% selama 1 menit
```

## Command

```bash
stress-ng --vm 1 --vm-bytes 80% --vm-keep --timeout 120s
```

## Monitoring

Grafana:
- Memory usage > 80%

Telegram:
- Alert HighMemoryUsage muncul

## Recovery

```bash
pkill stress-ng
```

---

# 4. High Disk Usage Alert

## Threshold

```text
Storage > 80%
```

## Check Available Space

```bash
df -h
```

## Simulasi Disk Full

```bash
fallocate -l 6G largefile.img
```

## Monitoring

Grafana:
- Disk usage meningkat

Telegram:
- Alert HighDiskUsage muncul

## Recovery

```bash
rm largefile.img
```

---

# 5. High Network Traffic Alert

## Threshold

```text
Traffic > 100 Mbps selama 1 menit
```

## Install iperf3

```bash
sudo apt install iperf3 -y
```

## Jalankan Server (DRC)

```bash
iperf3 -s
```

## Jalankan Client (DC)

```bash
iperf3 -c 10.10.1.20 -t 120
```

## Monitoring

Grafana:
- Network traffic meningkat

Telegram:
- Alert HighNetworkTraffic muncul

## Recovery

Tekan:

```text
CTRL + C
```

---

# 📊 Monitoring Dashboard

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

# 🔥 Tips Saat Demo

## Recommended Demo Flow

1. Tampilkan Grafana dashboard
2. Tampilkan Telegram group
3. Jalankan stress test
4. Tunggu alert muncul
5. Jelaskan threshold & dampaknya

---

# ⚠️ Notes

- Semua threshold disesuaikan dengan spesifikasi VM:
  - 1 vCPU
  - 1 GB RAM

- Environment menggunakan VMware virtual network sehingga kemungkinan terdapat sedikit fluktuasi performa selama stress testing.