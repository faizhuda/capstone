# Grafana Dashboard

Dashboard yang digunakan:

- Custom Observability Dashboard (revamped from Node Exporter Full)

Panel utama:

- Business Continuity Status (with reachability sparkline)
- Node Status (individual reachability cards with sparklines for DC, DRC, Router, and Monitoring Server)
- DC Server, DRC Server, and Router VM performance details (minimalist CPU, RAM, Disk Gauges, and opacity-gradient Network Traffic timeseries for each)
- System Health (Load Average comparisons with customized line colors and threshold lines, plus individual system Uptimes)