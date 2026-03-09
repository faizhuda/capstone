# Capstone Project

## Infrastructure Monitoring System (DC–DRC Simulation)

---

# Overview

This project implements a **real-time infrastructure monitoring system** for a simulated **Data Center (DC)** and **Disaster Recovery Center (DRC)** environment.

The monitoring system collects system metrics such as:

* CPU usage
* Memory usage
* Disk utilization
* Network traffic

Metrics are collected using **Node Exporter**, scraped by **Prometheus**, and visualized through **Grafana dashboards**.

The monitoring server connects to **both DC and DRC networks simultaneously**, allowing centralized monitoring without requiring direct communication between the two servers.

Future development includes **router integration, alerting, Telegram notifications, and a custom web monitoring dashboard similar to a government NOC (Diskominfo-style dashboard)**.

---

# Current System Architecture

The current implementation uses a **dual-network monitoring server** that connects to both networks.

```text
                 Monitoring Server
           +------------------------------+
           | Prometheus                   |
           | Grafana                      |
           | Alertmanager (planned)       |
           |                              |
           | Adapter 1 → 10.10.1.100      |
           | Adapter 2 → 10.20.2.100      |
           +--------------+---------------+
                          |
           -------------------------------
           |                             |
     10.10.1.0/24                   10.20.2.0/24
           |                             |
     +------------+                +------------+
     | DC Server  |                | DRC Server |
     |------------|                |------------|
     | Node Exporter               | Node Exporter
     | 10.10.1.10                  | 10.20.2.10
     +------------+                +------------+
```

### Important Notes

* DC and DRC **do not communicate directly**
* Monitoring server acts as a **central monitoring node**
* Each server exposes metrics via **Node Exporter**

---

# Infrastructure Components

## Monitoring Server

Services running:

* Prometheus
* Grafana
* Alertmanager (planned)

Network configuration:

| Interface | IP          |
| --------- | ----------- |
| Adapter 1 | 10.10.1.100 |
| Adapter 2 | 10.20.2.100 |

Purpose:

* Scrape metrics from DC server
* Scrape metrics from DRC server
* Visualize metrics using Grafana

---

## DC Server

| Component  | Value         |
| ---------- | ------------- |
| Hostname   | dc-server     |
| IP Address | 10.10.1.10    |
| Network    | 10.10.1.0/24  |
| Service    | Node Exporter |

Metrics endpoint:

```
http://10.10.1.10:9100/metrics
```

---

## DRC Server

| Component  | Value         |
| ---------- | ------------- |
| Hostname   | drc-server    |
| IP Address | 10.20.2.10    |
| Network    | 10.20.2.0/24  |
| Service    | Node Exporter |

Metrics endpoint:

```
http://10.20.2.10:9100/metrics
```

---

# Monitoring Stack

## Prometheus

Prometheus scrapes metrics from Node Exporter every **15 seconds**.

Example configuration:

```
/etc/prometheus/prometheus.yml
```

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node-exporter"

    static_configs:
      - targets: ["10.10.1.10:9100"]
        labels:
          server: "dc-server"
          location: "DC"

      - targets: ["10.20.2.10:9100"]
        labels:
          server: "drc-server"
          location: "DRC"
```

---

## Node Exporter

Node Exporter collects system-level metrics including:

* CPU usage
* Memory usage
* Disk usage
* Network traffic
* System load
* System uptime

Metrics endpoint format:

```
http://<server-ip>:9100/metrics
```

---

## Grafana

Grafana visualizes Prometheus metrics using dashboards.

Dashboard used:

```
Node Exporter Full
```

Displayed metrics include:

* CPU Usage
* Memory Usage
* Disk Utilization
* Network Traffic
* System Load
* Uptime

---

# Testing & Simulation

## CPU Stress Test

Run on DC or DRC server:

```
stress-ng --cpu 4 --timeout 60s
```

Expected result:

* CPU usage spike visible on Grafana dashboard.

---

## Memory Stress Test

```
stress-ng --vm 2 --vm-bytes 1G --timeout 60s
```

Expected result:

* Increased memory usage.

---

## Disk I/O Test

```
stress-ng --hdd 2 --timeout 60s
```

Expected result:

* Disk activity spike in Grafana.

---

## Network Traffic Test

Because DC and DRC are isolated, network testing is performed **between each server and the monitoring server**.

Start iperf3 server on monitoring server:

```
iperf3 -s
```

Run client from DC server:

```
iperf3 -c 10.10.1.100 -t 60
```

Run client from DRC server:

```
iperf3 -c 10.20.2.100 -t 60
```

Expected result:

* Network traffic spike in Grafana dashboard.

---

# Current Implemented Features

* Multi-server infrastructure monitoring
* Prometheus metrics scraping
* Grafana visualization dashboards
* Resource stress simulation
* Network traffic simulation
* Dual-network monitoring server

---

# TODO / Future Enhancements

## 1 Router Integration (Ideal Architecture)

To simulate a more realistic infrastructure environment, a **router VM will be added** to connect the DC and DRC networks.

Ideal topology:

```
                +-------------------------+
                |     Monitoring Server   |
                |-------------------------|
                | Prometheus              |
                | Grafana                 |
                +-----------+-------------+
                            |
            -----------------------------------
            |                                 |
       10.10.1.0/24                     10.20.2.0/24
            |                                 |
      +------------+                   +------------+
      | DC Server  |                   | DRC Server |
      +------+-----+                   +------+-----+
             \                               /
              \                             /
               \                           /
                +-------------------------+
                |        Router VM        |
                | 10.10.1.1               |
                | 10.20.2.1               |
                +-------------------------+
```

Benefits:

* Enables DC ↔ DRC communication
* Allows **iperf3 cross-network testing**
* Simulates real infrastructure routing

---

## 2 Alerting System

Implement alert rules using **Prometheus Alertmanager**.

Planned alerts:

CPU Alert

```
CPU usage > 80%
```

Memory Alert

```
Memory usage > 85%
```

Disk Alert

```
Disk usage > 90%
```

---

## 3 Telegram Bot Integration

Alerts will be delivered directly to administrators via Telegram.

Example notification:

```
⚠ Infrastructure Alert

Server: dc-server
Metric: CPU Usage
Value: 92%

Status: High Resource Usage
```

---

## 4 Web Monitoring Dashboard (Diskominfo Style)

Develop a custom monitoring interface similar to a **Network Operations Center dashboard**.

Planned features:

* Real-time server health overview
* DC vs DRC comparison
* Infrastructure status indicators
* Embedded Grafana dashboards

Possible technologies:

* React / Next.js
* Simple HTML dashboard
* Grafana embed panels

---

# Technologies Used

| Technology    | Purpose                  |
| ------------- | ------------------------ |
| Prometheus    | Metrics collection       |
| Grafana       | Monitoring visualization |
| Node Exporter | System metrics exporter  |
| Alertmanager  | Alert routing            |
| stress-ng     | Resource stress testing  |
| iperf3        | Network testing          |
| VMware        | Virtual infrastructure   |

---

# Project Objective

The objective of this project is to demonstrate how **modern monitoring systems detect infrastructure issues in real time**, allowing administrators to quickly identify performance problems and system anomalies.

This project simulates a **small-scale monitoring system similar to those used in production data centers and government network operations centers (NOC)**.
