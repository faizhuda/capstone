# Testing

## Ping Router

```bash
ping 10.10.1.2
```

## Ping Monitoring Server

```bash
ping 10.10.1.200
```

## Test Node Exporter

```bash
curl localhost:9100/metrics
```

## Test Intra-Subnet Routing

```bash
ping 10.10.1.20
```

## Result

- Routing dalam subnet berjalan
- Node Exporter dapat discrape oleh Prometheus
- Monitoring server mengakses DRC langsung dalam subnet yang sama (10.10.1.0/24)