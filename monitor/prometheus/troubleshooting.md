# Troubleshooting

## Problem: context deadline exceeded

### Penyebab
VMware virtual networking menyebabkan latency fluktuatif.

### Solusi

Tambahkan:

```yaml
scrape_timeout: 10s
```

---

## Problem: Target DOWN

### Penyebab
- node_exporter mati
- routing gagal
- firewall

### Solusi

```bash
sudo systemctl start node_exporter
```