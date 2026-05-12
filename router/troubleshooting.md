# Troubleshooting

## Problem: DRC tidak dapat discrape

### Penyebab
- IP forwarding belum aktif
- Route belum ditambahkan
- VMware virtual network fluktuatif

### Solusi
- Enable IP forwarding
- Tambahkan static route
- Sesuaikan subnet dengan VMnet VMware

---

## Problem: Scraping timeout

### Penyebab
Keterbatasan VMware virtual networking menyebabkan latensi fluktuatif.

### Dampak
Prometheus terkadang mengalami:

```text
context deadline exceeded
```

### Solusi
Meningkatkan:

```yaml
scrape_timeout: 10s
```