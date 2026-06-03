# Handover Documentation
## Capstone Project - Infrastructure Monitoring System DC-DRC

**Last updated:** 2026-06-03
**Prepared for:** AI successor / next collaborator
**Repo:** https://github.com/faizhuda/capstone
**Local path:** `C:\Users\faizn\projects\capstone`

---

## 1. Project Summary

### Tujuan Utama

Membangun sistem monitoring infrastruktur real-time untuk lingkungan simulasi Data Center (DC) dan Disaster Recovery Center (DRC) menggunakan stack Prometheus + Grafana + Alertmanager + Node Exporter, dengan alerting otomatis ke Telegram. Seluruh infrastruktur berjalan di atas VMware Workstation di mesin lokal.

### Status Progres Saat Ini

**~85% selesai.** Core monitoring sudah fully operational secara lokal. Yang tersisa adalah public deployment (Cloudflare Tunnel) dan re-import Grafana dashboard versi terbaru.

### Keputusan Penting yang Sudah Diambil

| Keputusan | Alasan |
|---|---|
| Pindah ke single subnet `10.10.1.0/24` untuk semua VM | Multi-subnet via VMware menyebabkan latency dan timeout scraping Prometheus yang tidak stabil |
| IP Router VM diubah dari `10.10.1.1` ke `10.10.1.2` | `10.10.1.1` diambil oleh VMware Host Virtual Network Adapter di Windows, menyebabkan SSH connection refused |
| Alertmanager menggunakan `parse_mode: HTML` bukan `Markdown` | HTML lebih stabil di Telegram, tidak rusak saat pesan mengandung karakter spesial |
| Node Exporter dijalankan sebagai systemd service | Agar tetap berjalan saat SSH session ditutup dan auto-start saat boot |
| Tidak ada setup scripts otomatis di repo | Scripts dari commit awal (`e2e6874`) tidak dikembalikan; setup dilakukan manual dengan panduan per-file `.md` |
| Dashboard Grafana dibuat dari scratch (bukan Node Exporter Full) | Lebih fokus ke metric yang relevan, tanpa panel yang tidak dibutuhkan |

### Asumsi dan Batasan

- Seluruh VM berjalan di VMware Workstation di satu mesin Windows (lokal, bukan cloud)
- DC dan DRC tidak perlu berkomunikasi langsung satu sama lain
- Router VM berfungsi sebagai default gateway, bukan inter-subnet router
- Target audience: presentasi capstone/akademik, bukan production deployment
- Semua VM menggunakan Ubuntu Server 24.04 LTS
- Interface jaringan semua VM adalah `ens33` (VMware default)

---

## 2. Konteks yang Sudah Dikerjakan

### Audit dan Perbaikan Konfigurasi (Selesai)

Dilakukan full audit project dengan hasil skor 68/100 (naik dari 47/100 di versi awal). Perbaikan yang sudah diimplementasikan dan di-push ke repo:

**Commit `9955ed9` (Batch perbaikan utama):**
- `monitor/alertmanager/alertmanager.yml`: tambah `inhibit_rules` untuk mencegah alert storm saat NodeDown (resource alerts di-suppress jika server sudah down)
- `monitor/prometheus/prometheus.yml`: tambah label custom (`server`, `location`), scrape target router (`10.10.1.2:9100`), dan self-monitoring Prometheus (`localhost:9090`)
- `monitor/prometheus/alert.rules.yml`: fix `HighDiskIOWait` query (tambah `avg by(instance)`), fix `HighLoad` menjadi relatif per-vCPU, **fix kritis**: `HighDiskUsage` expr multi-line yang YAML-invalid sejak awal (kemungkinan alert disk tidak pernah trigger sebelumnya)
- `monitor/network/netplan.yaml`: ganti `gateway4:` deprecated ke `routes:`, fix dual default-gateway pada monitoring server (ens33 tidak perlu default route, hanya ens37)
- `dc-server/network-config.yaml` dan `drc-server/network-config.yaml`: ganti `gateway4:` ke `routes:`
- `dc-server/node-exporter-setup.md` dan `drc-server/node-exporter-setup.md`: tambah instruksi systemd service
- `drc-server/testing.md`: hapus teks stale "melalui router"
- `README.md`: sinkronkan threshold network (100 Mbps to 80 Mbps), tambah panduan konfigurasi token Telegram
- `monitor/testing/stress-testing.md`: sinkronkan threshold network

**Commit `4286cc7` (IP Router fix):**
- Semua referensi `10.10.1.1` (router) diubah ke `10.10.1.2` di seluruh repo
- File terdampak: `router/network-config.yaml`, `monitor/prometheus/prometheus.yml`, `dc-server/network-config.yaml`, `drc-server/network-config.yaml`, `README.md`, `dc-server/testing.md`, `drc-server/testing.md`

**Commit `b589d00` + `caff093` (Telegram template):**
- Template pesan Telegram custom dengan format profesional (header status, server, severity, summary, description, timestamp)
- Timestamp menggunakan `.Local.Format` agar ikut timezone sistem VM
- **Penting:** monitoring server harus diset ke timezone `Asia/Jakarta` agar timestamp tampil WIB, bukan UTC

**Commit `14ced1d` + `5d2e548` (Grafana dashboard):**
- Dashboard JSON custom dibuat dari scratch di `monitor/grafana/dashboard.json`
- Tanpa emoji, tanpa em dash, tampilan profesional
- Panel: Business Continuity Status (full-width, green/red), Node Status (4 server), DC metrics (CPU/Memory/Disk gauge + Network timeseries), DRC metrics (sama), System Health (Load Average comparison + 4 uptime panels)

### SSH Configuration (Selesai)

File `C:\Users\faizn\.ssh\config` sudah dibuat dengan entri untuk semua VM:

```
Host monitoring  → 10.10.1.100  User: capstone  ServerAliveInterval: 60
Host dc-server   → 10.10.1.10   User: capstone  ServerAliveInterval: 60
Host drc-server  → 10.10.1.20   User: capstone  ServerAliveInterval: 60
Host router      → 10.10.1.2    User: capstone  ServerAliveInterval: 60
```

### Node Exporter Status (Selesai)

- DC Server: Node Exporter running sebagai systemd service (dikonfirmasi)
- DRC Server: Node Exporter running sebagai systemd service (dikonfirmasi)
- Router VM (`10.10.1.2`): Node Exporter running sebagai systemd service (dikonfirmasi)
- Semua 4 target (`dc-server`, `drc-server`, `router`, `prometheus`) menunjukkan `"health": "up"` di Prometheus

### Config Applied di VM (Selesai)

- Prometheus dan Alertmanager config sudah di-`git pull` dan di-apply di Monitoring Server
- Token Telegram sudah diisi di `/etc/alertmanager/alertmanager.yml` di VM (bukan di repo)
- Timezone sistem di VM Monitoring Server telah diatur ke `Asia/Jakarta` (WIB)
- Konfigurasi Netplan dengan gateway baru `10.10.1.2` telah diterapkan secara aktif (`netplan apply`) di VM DC dan DRC

---

## 3. Status Saat Ini

### Kondisi Terakhir

- Semua VM running dan dapat di-SSH dari Windows host
- Prometheus scraping 4 target, semua `up`
- Alertmanager terkonfigurasi dan terhubung ke Telegram
- Grafana dashboard JSON sudah dibuat dan di-push ke repo, **belum di-import ulang** ke Grafana UI (masih menggunakan dashboard lama)
- Dashboard JSON terakhir (`5d2e548`) dimodifikasi user setelah push: warna diubah dari named colors (`"green"`, `"red"`) ke hex codes (`"#10B981"`, `"#EF4444"`), dan `graphMode` diubah dari `"none"` ke `"area"` pada beberapa panel stat

### Sedang Dikerjakan Saat Handover

Proses re-import Grafana dashboard versi terbaru ke Grafana UI belum dilakukan. Handover terjadi setelah dashboard JSON selesai direvisi.

### Kendala yang Masih Terbuka

1. **Public deployment belum dilakukan**: Cloudflare Tunnel belum diinstall di Monitoring Server. Ini adalah requirement tugas.

### Risiko

- Token Telegram di VM (`/etc/alertmanager/alertmanager.yml`) tidak ada di repo: jika VM di-recreate, token harus diisi ulang manual
- `50-cloud-init.yaml` di Router VM mengandung konfigurasi network manual; jika cloud-init berjalan ulang saat reboot, konfigurasi bisa tertimpa (belum dimitigasi)
- Dashboard Grafana tidak auto-provision: jika Grafana di-reinstall, dashboard harus di-import ulang manual dari `monitor/grafana/dashboard.json`

## 4. To-Do List Tersisa

### High Priority

| Tugas | Dependensi | Langkah |
|---|---|---|
| Re-import Grafana dashboard versi terbaru | Repo sudah up-to-date | Login Grafana -> Dashboards -> New -> Import -> upload `monitor/grafana/dashboard.json` |
| Setup Cloudflare Tunnel untuk public access | Monitoring server harus punya akses internet (via ens37) | SSH ke monitoring -> install cloudflared -> `cloudflared tunnel --url http://localhost:3000` |

### Medium Priority

| Tugas | Dependensi | Langkah |
|---|---|---|
| Test end-to-end alert Telegram | Token sudah diisi | Jalankan `stress-ng --cpu 1 --timeout 120s` di dc-server -> tunggu alert muncul di Telegram |

### Low Priority

| Tugas | Dependensi | Langkah |
|---|---|---|
| Setup SSH key (passwordless login) | - | `ssh-keygen -t ed25519` di Windows -> `ssh-copy-id capstone@10.10.1.x` ke setiap VM |
| Mitigasi cloud-init overwrite di Router VM | - | Buat file `/etc/cloud/cloud.cfg.d/99-disable-network.cfg` dengan `network: {config: disabled}` |

---

## 5. Catatan Teknis Penting

### Struktur Repo

```
capstone/
├── README.md                          # Dokumentasi utama proyek
├── HANDOVER.md                        # File ini
├── LICENSE                            # MIT License
├── .gitignore                         # Covers VMware files, secrets, .env
│
├── dc-server/
│   ├── network-config.yaml            # Netplan: 10.10.1.10/24, gateway 10.10.1.2
│   ├── node-exporter-setup.md         # Panduan install Node Exporter + systemd
│   └── testing.md                     # Ping dan curl test
│
├── drc-server/
│   ├── network-config.yaml            # Netplan: 10.10.1.20/24, gateway 10.10.1.2
│   ├── node-exporter-setup.md         # Sama seperti dc-server
│   └── testing.md
│
├── router/
│   ├── network-config.yaml            # Netplan: ens33 = 10.10.1.2/24 (single interface)
│   ├── sysctl.conf                    # net.ipv4.ip_forward=1
│   └── ip-forwarding.md              # Panduan enable IP forwarding
│
└── monitor/
    ├── alertmanager/
    │   ├── alertmanager.yml           # Config Alertmanager + Telegram + inhibit_rules
    │   └── telegram-setup.md         # Panduan get bot token dan chat ID
    ├── grafana/
    │   ├── dashboard.json             # Custom dashboard JSON (import ke Grafana UI)
    │   ├── dashboard-notes.md
    │   └── datasource-setup.md
    ├── network/
    │   ├── netplan.yaml               # Monitoring server: ens33=10.10.1.100, ens37=192.168.163.10
    │   └── dns.md
    ├── prometheus/
    │   ├── prometheus.yml             # Scrape config: dc, drc, router, prometheus self
    │   ├── alert.rules.yml            # 7 alert rules: NodeDown, HighCPU, HighMem, HighDisk, HighLoad, HighNetwork, HighDiskIOWait
    │   └── scrape-config.md
    └── testing/
        └── stress-testing.md          # Cheatsheet testing semua alert
```

### IP Addressing

| VM | IP | Interface | Gateway |
|---|---|---|---|
| Monitoring Server (LAN) | 10.10.1.100 | ens33 | - (directly connected) |
| Monitoring Server (NAT) | 192.168.163.10 | ens37 | 192.168.163.2 |
| Router VM | 10.10.1.2 | ens33 | - |
| DC Server | 10.10.1.10 | ens33 | 10.10.1.2 |
| DRC Server | 10.10.1.20 | ens33 | 10.10.1.2 |

### Services dan Port

| Service | Host | Port | Keterangan |
|---|---|---|---|
| Prometheus | monitoring | 9090 | Scrape interval 15s, timeout 10s |
| Grafana | monitoring | 3000 | Default login: admin/admin |
| Alertmanager | monitoring | 9093 | Terhubung ke Telegram |
| Node Exporter | dc, drc, router | 9100 | Systemd service, user: node_exporter |

### Konfigurasi Kritis

**`monitor/prometheus/prometheus.yml`** — 4 scrape targets:
- `dc-server` → `10.10.1.10:9100`
- `drc-server` → `10.10.1.20:9100`
- `router` → `10.10.1.2:9100`
- `prometheus` → `localhost:9090`

**`monitor/prometheus/alert.rules.yml`** — 7 alert rules dengan threshold:
- `NodeDown`: `up == 0` for 1m → critical
- `HighCPUUsage`: CPU > 80% for 1m → warning
- `HighMemoryUsage`: RAM > 80% for 1m → warning
- `HighDiskUsage`: Disk > 80% for 1m → critical
- `HighLoad`: load/vCPU > 1.5 for 1m → warning
- `HighNetworkTraffic`: > 10MB/s (80 Mbps) for 1m → warning
- `HighDiskIOWait`: iowait > 20% for 1m → warning

**`monitor/alertmanager/alertmanager.yml`** — inhibit_rules aktif: jika `NodeDown` firing, semua alert resource untuk instance yang sama di-suppress.

### Environment Variables / Secrets

| Variable | Lokasi di VM | Keterangan |
|---|---|---|
| `bot_token` | `/etc/alertmanager/alertmanager.yml` baris `bot_token:` | Token dari @BotFather Telegram |
| `chat_id` | `/etc/alertmanager/alertmanager.yml` baris `chat_id:` | Chat ID tujuan alert |

> Nilai asli tidak ada di repo. Placeholder `"YOUR_TOKEN"` dan `YOUR_CHAT_ID` ada di repo sebagai referensi.

### SSH Config (Windows Host)

File: `C:\Users\faizn\.ssh\config`

```
Host monitoring  HostName 10.10.1.100  User capstone  ServerAliveInterval 60  ServerAliveCountMax 10
Host dc-server   HostName 10.10.1.10   User capstone  ServerAliveInterval 60  ServerAliveCountMax 10
Host drc-server  HostName 10.10.1.20   User capstone  ServerAliveInterval 60  ServerAliveCountMax 10
Host router      HostName 10.10.1.2    User capstone  ServerAliveInterval 60  ServerAliveCountMax 10
```

---

## 6. Next Recommended Actions

Lakukan secara berurutan:

**1. Re-import Grafana dashboard**
```
Buka http://10.10.1.100:3000 di browser
Login: admin / admin
Dashboards → New → Import → Upload JSON file
Pilih: monitor/grafana/dashboard.json (dari repo lokal)
Pilih datasource: Prometheus → Import
```

**2. Set timezone monitoring server ke WIB**
```bash
ssh monitoring
sudo timedatectl set-timezone Asia/Jakarta
timedatectl   # verify: Time zone: Asia/Jakarta (WIB, +0700)
sudo systemctl restart alertmanager
```

**3. Install Cloudflare Tunnel untuk public access**
```bash
ssh monitoring
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb
cloudflared tunnel --url http://localhost:3000
# Catat URL yang muncul, contoh: https://xxxx.trycloudflare.com
```

**4. Test end-to-end alert**
```bash
ssh dc-server
stress-ng --cpu 1 --timeout 120s
# Tunggu ~1 menit → cek Telegram apakah alert HighCPUUsage masuk
```

**5. Update gateway DC dan DRC server (opsional, kalau ada masalah routing)**
```bash
ssh dc-server
sudo nano /etc/netplan/50-cloud-init.yaml
# Ubah gateway4: 10.10.1.1 → routes: [{to: default, via: 10.10.1.2}]
sudo netplan apply
# Ulangi untuk drc-server
```

---

## 7. Open Questions

| # | Pertanyaan | Konteks |
|---|---|---|
| 1 | Apakah alert Telegram sudah pernah berhasil dikirim? | Token sudah diisi tapi belum dikonfirmasi end-to-end test |
| 2 | Apakah `HighDiskUsage` alert sekarang sudah berfungsi? | Sebelumnya YAML-invalid sehingga kemungkinan tidak pernah trigger; sudah diperbaiki di commit `9955ed9` tapi belum ditest |
| 3 | Apakah deployment requirement (public access) cukup dengan Cloudflare Tunnel sementara, atau perlu VPS permanen? | README menyebut "VPS deployment" sebagai next phase, tapi untuk presentasi Cloudflare Tunnel seharusnya cukup |
| 4 | Apakah Router VM perlu dimonitor (Node Exporter sudah dipasang)? | Saat ini sudah di-scrape oleh Prometheus, tapi tidak ada alert rules khusus untuk router. Perlu ditambahkan? |
| 5 | Apakah `cloud-init` di Router VM akan menimpa konfigurasi network saat reboot? | Belum ditest; jika `10.10.1.2` hilang setelah reboot, perlu disable cloud-init network config |
| 6 | Grafana default credentials `admin/admin`: apakah sudah diganti? | Tidak ada catatan bahwa password sudah diubah; perlu dikonfirmasi sebelum public deployment |

---

*Dokumen ini dibuat berdasarkan seluruh sesi kerja pada 2026-06-03. Commit terakhir sebelum handover: `5d2e548`.*
