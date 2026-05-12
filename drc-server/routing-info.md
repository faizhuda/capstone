# Routing Information

## Network Topology

DRC Server berada pada subnet:

```text
10.20.2.0/24
```

Gateway utama:

```text
10.20.2.1
```

Gateway tersebut merupakan Router VM yang menghubungkan jaringan DRC dengan jaringan DC.

## Route Verification

```bash
ip route
```

Expected route:

```text
default via 10.20.2.1
```