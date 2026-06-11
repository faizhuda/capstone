# Scrape Configuration

Prometheus melakukan scraping metrics setiap:

```text
5 detik
```

Rule evaluation interval:

```text
5 detik
```

Target yang dimonitor:

- DC Server (10.10.1.10:9100)
- DRC Server (10.10.1.20:9100)
- Router VM (10.10.1.2:9100)
- Monitoring Server (localhost:9090)

## Verification

```bash
# Verify DC Server node exporter
curl http://10.10.1.10:9100/metrics

# Verify DRC Server node exporter
curl http://10.10.1.20:9100/metrics

# Verify Router VM node exporter
curl http://10.10.1.2:9100/metrics
```