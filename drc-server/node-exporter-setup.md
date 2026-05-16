# Install Node Exporter

## Download Node Exporter

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
```

## Extract

```bash
tar xvf node_exporter-1.10.2.linux-amd64.tar.gz
```

## Move Binary

```bash
sudo cp node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/
```

## Run Node Exporter

```bash
node_exporter
```

## Verify Metrics

```bash
curl localhost:9100/metrics
```