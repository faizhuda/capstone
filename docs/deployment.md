# Deployment Plan

## Current Environment

Saat ini seluruh infrastruktur berjalan di VMware menggunakan Ubuntu Server VM.

## Planned Production Deployment

Monitoring stack akan dipindahkan ke VPS/cloud environment:

- Prometheus
- Grafana
- Alertmanager

Sedangkan:

- DC Server
- DRC Server
- Router VM

tetap berjalan di local VM environment.

## Planned Connectivity

- Tailscale / WireGuard VPN
- Public VPS monitoring
- Hybrid monitoring architecture