# Troubleshooting

## Problem: DRC tidak dapat discrape

### Cause

- IP forwarding belum aktif
- Static route belum ditambahkan
- VMware virtual networking tidak stabil

### Solution

- Enable IP forwarding
- Tambahkan static route
- Tambahkan scrape timeout

---

## Problem: Telegram Alert tidak terkirim

### Cause

Monitoring server tidak memiliki akses internet.

### Solution

- Tambahkan NAT adapter
- Konfigurasi DNS

---

## Problem: DNS gagal resolve

### Cause

DNS default VMware tidak stabil.

### Solution

Gunakan:

```text
8.8.8.8
1.1.1.1
```