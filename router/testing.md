# Testing

## Ping DC → DRC

Dari DC Server:

```bash
ping 10.20.2.10
```

## Ping DRC → DC

Dari DRC Server:

```bash
ping 10.10.1.10
```

## Test Routing

```bash
traceroute 10.20.2.10
```

## Test Monitoring Access

Dari Monitoring Server:

```bash
curl http://10.20.2.10:9100/metrics
```

## Result

- Routing antar subnet berhasil
- Router dapat meneruskan paket
- Monitoring server dapat scraping DRC melalui router