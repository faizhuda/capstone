# Quickstart Guide
## Capstone Project - Infrastructure Monitoring System DC-DRC

Panduan ini untuk anggota kelompok yang ingin menjalankan environment monitoring dari file OVA yang sudah disediakan.

---

## Yang Kamu Butuhkan

- VMware Workstation (versi 16 atau lebih baru)
- File OVA (minta ke anggota kelompok yang punya):
  - `DC-Server.ova`
  - `DRC-Server.ova`
  - `Router.ova`
  - `Monitoring-Server.ova`
- RAM minimal 6 GB free (total semua VM: 5 GB)
- Storage minimal 15 GB free

---

## Langkah 1 - Import Semua OVA

Buka VMware Workstation, lalu import satu per satu:

```
File > Open > pilih file .ova
```

Ulangi untuk keempat file OVA. Tidak perlu mengubah settings saat import, klik Next terus sampai selesai.

---

## Langkah 2 - Konfigurasi Network Adapter

Ini langkah paling penting. Semua VM harus berada di network adapter yang sama.

Untuk setiap VM, buka **VM Settings > Network Adapter**, lalu set ke:

```
Custom: VMnet yang sama untuk semua VM (misalnya VMnet2)
```

Lakukan ini untuk keempat VM: DC-Server, DRC-Server, Router, dan Monitoring-Server.

> Jika belum ada VMnet yang sesuai, buka VMware > Edit > Virtual Network Editor,
> buat VMnet baru bertipe Host-Only.

---

## Langkah 3 - Jalankan VM

Nyalakan VM dengan urutan berikut:

1. **Router** (nyalakan pertama)
2. **DC Server** dan **DRC Server** (bisa bersamaan)
3. **Monitoring Server** (nyalakan terakhir)

Tunggu sekitar 30 detik setelah setiap VM menyala sebelum lanjut.

---

## Langkah 4 - Verifikasi Koneksi

Dari Monitoring Server (buka console VMware atau SSH), cek koneksi ke semua VM:

```bash
ping -c 2 10.10.1.2    # Router
ping -c 2 10.10.1.10   # DC Server
ping -c 2 10.10.1.20   # DRC Server
```

Semua harus reply. Jika tidak, cek kembali network adapter di Langkah 2.

---

## Langkah 5 - Akses Grafana Dashboard

Buka browser di komputer kamu, akses:

```
http://10.10.1.100:3000
```

Login dengan:

| Field | Value |
|---|---|
| Username | viewer |
| Password | viewer123 |

Dashboard akan langsung menampilkan status semua VM.

Untuk akses admin (edit dashboard, kelola user):

| Field | Value |
|---|---|
| Username | admin |
| Password | (tanya ke anggota yang setup) |

---

## Langkah 6 - Verifikasi Prometheus

Buka browser, akses:

```
http://10.10.1.100:9090/targets
```

Pastikan keempat target berstatus `UP`:

- `dc-server` (10.10.1.10:9100)
- `drc-server` (10.10.1.20:9100)
- `router` (10.10.1.2:9100)
- `prometheus` (localhost:9090)

Jika ada yang `DOWN`, kemungkinan VM tersebut belum menyala atau network adapter belum dikonfigurasi dengan benar.

---

## Alert Telegram

Alert otomatis sudah dikonfigurasi dan akan dikirim ke grup Telegram kelompok.

Tidak perlu setup apapun. Alert akan terkirim saat:

- Server tidak dapat diakses (NodeDown)
- CPU melebihi 80%
- RAM melebihi 80%
- Disk melebihi 80%
- Load average per core melebihi 1.5
- Network traffic melebihi 80 Mbps
- Disk I/O wait melebihi 20%

---

## SSH ke VM (Opsional)

Dari komputer kamu, bisa SSH langsung ke semua VM:

```bash
ssh capstone@10.10.1.100   # Monitoring Server
ssh capstone@10.10.1.10    # DC Server
ssh capstone@10.10.1.20    # DRC Server
ssh capstone@10.10.1.2     # Router
```

Password: tanya ke anggota yang setup.

---

## Stress Testing

Untuk memicu alert dan menguji sistem, jalankan perintah berikut di DC Server atau DRC Server:

**CPU:**
```bash
stress-ng --cpu 4 --timeout 120s
```

**Memory:**
```bash
stress-ng --vm 2 --vm-bytes 90% --timeout 120s
```

**Disk:**
```bash
fallocate -l 6G bigfile.test
# Hapus setelah selesai:
rm bigfile.test
```

**Simulasi Server Down:**
```bash
sudo systemctl stop node_exporter
# Nyalakan kembali:
sudo systemctl start node_exporter
```

---

## Troubleshooting

### Grafana tidak bisa diakses

Cek apakah Grafana berjalan di Monitoring Server:

```bash
ssh capstone@10.10.1.100
sudo systemctl status grafana-server
```

Jika mati, jalankan:

```bash
sudo systemctl start grafana-server
```

### Prometheus target DOWN

Cek Node Exporter di VM yang bermasalah:

```bash
ssh capstone@10.10.1.10  # atau IP VM lain
sudo systemctl status node_exporter
sudo systemctl start node_exporter
```

### Ping tidak reply antar VM

Cek network adapter semua VM. Semua harus terhubung ke VMnet yang sama. Lihat kembali Langkah 2.

### VM tidak bisa konek ke internet (Monitoring Server)

Monitoring Server punya dua interface. Interface `ens37` digunakan untuk akses internet via VMware NAT. Pastikan VMware NAT service berjalan di Windows:

```
Services > VMware NAT Service > Start
```

---

## IP Addressing

| VM | IP Address | Fungsi |
|---|---|---|
| Monitoring Server | 10.10.1.100 | Prometheus, Grafana, Alertmanager |
| Router VM | 10.10.1.2 | Gateway jaringan |
| DC Server | 10.10.1.10 | Simulasi Data Center |
| DRC Server | 10.10.1.20 | Simulasi Disaster Recovery |

---

## Port yang Digunakan

| Service | URL |
|---|---|
| Grafana Dashboard | http://10.10.1.100:3000 |
| Prometheus | http://10.10.1.100:9090 |
| Alertmanager | http://10.10.1.100:9093 |
| Node Exporter DC | http://10.10.1.10:9100/metrics |
| Node Exporter DRC | http://10.10.1.20:9100/metrics |
| Node Exporter Router | http://10.10.1.2:9100/metrics |
