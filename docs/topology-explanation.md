# Topology Explanation

## Monitoring Server

Monitoring server bertugas melakukan scraping metrics dari seluruh node.

## Router VM

Router VM menghubungkan subnet:

- 10.10.1.0/24
- 10.20.2.0/24

## DC Server

Node utama yang dimonitor.

## DRC Server

Node cadangan untuk simulasi disaster recovery.

## Communication Flow

```text
DC ↔ Router ↔ DRC
```

```text
Monitoring → Router → DRC
```