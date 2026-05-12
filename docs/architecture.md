# Architecture Overview

Proyek ini menggunakan arsitektur monitoring terpusat untuk memonitor lingkungan simulasi Data Center (DC) dan Disaster Recovery Center (DRC).

## Components

- Monitoring Server
- Router VM
- DC Server
- DRC Server

## Monitoring Stack

- Prometheus
- Grafana
- Alertmanager
- Node Exporter

## Network Design

- DC subnet:
  ```text
  10.10.1.0/24
  ```

- DRC subnet:
  ```text
  10.20.2.0/24
  ```

- Router VM:
  ```text
  10.10.1.1
  10.20.2.1
  ```

## Monitoring Flow

```text
Node Exporter → Prometheus → Alertmanager → Telegram
```