# Testing

## Ping Router

```bash
ping 10.20.2.1
```

## Ping Monitoring Server

```bash
ping 10.10.1.100
```

## Test Node Exporter

```bash
curl localhost:9100/metrics
```

## Test Inter-Subnet Routing

```bash
ping 10.10.1.10
```

## Result

- Routing antar subnet berjalan
- Node Exporter dapat discrape oleh Prometheus
- Monitoring server dapat mengakses DRC melalui router