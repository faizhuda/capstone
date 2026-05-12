# Known Limitations

## VMware Virtual Networking

Lingkungan VMware memiliki keterbatasan pada virtual networking dan packet forwarding, sehingga scraping metrics dari subnet DRC terkadang mengalami latency fluktuatif.

Dampak:
- Scraping delay
- Timeout Prometheus
- Intermittent packet loss

---

## No High Availability

Saat ini monitoring stack masih menggunakan single monitoring server.

---

## No Persistent Storage

Prometheus belum menggunakan external persistent storage.