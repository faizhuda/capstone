# Scrape Configuration

Prometheus melakukan scraping metrics setiap:

```text
15 detik (scrape_interval: 15s, scrape_timeout: 10s)
```

Lima target yang dimonitor:

- Prometheus self-monitoring (localhost:9090)
- DC Server — Node Exporter (10.10.1.10:9100)
- DRC Server — Node Exporter (10.10.1.20:9100)
- Router VM — Node Exporter (10.10.1.2:9100)
- Monitoring Server — Node Exporter (localhost:9100)

## Verification

```bash
# Verify Prometheus self-monitoring
curl http://localhost:9090/metrics

# Verify DC Server node exporter
curl http://10.10.1.10:9100/metrics

# Verify DRC Server node exporter
curl http://10.10.1.20:9100/metrics

# Verify Router VM node exporter
curl http://10.10.1.2:9100/metrics

# Verify Monitoring Server node exporter
curl http://localhost:9100/metrics
```
