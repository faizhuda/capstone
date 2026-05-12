# Static Routing

## DC Server

Tambahkan gateway:

```text
10.10.1.1
```

## DRC Server

Tambahkan gateway:

```text
10.20.2.1
```

## Monitoring Server

Tambahkan route menuju subnet DRC:

```bash
sudo ip route add 10.20.2.0/24 via 10.10.1.1
```

## Verification

```bash
ip route
```