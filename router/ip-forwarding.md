# IP Forwarding

Agar Router VM dapat meneruskan paket trafik monitoring/testing dalam topologi simulasi, IP forwarding harus diaktifkan.

## Enable Temporarily

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

## Enable Permanently

Edit:

```bash
sudo nano /etc/sysctl.conf
```

Tambahkan:

```text
net.ipv4.ip_forward=1
```

Apply:

```bash
sudo sysctl -p
```

## Verification

```bash
cat /proc/sys/net/ipv4/ip_forward
```

Expected output:

```text
1
```