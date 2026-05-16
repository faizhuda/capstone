# Scrape Configuration

Prometheus melakukan scraping metrics setiap:

```text
15 detik
```

Target yang dimonitor:

- DC Server
- DRC Server

## Verification

```bash
curl http://10.10.1.10:9100/metrics
```