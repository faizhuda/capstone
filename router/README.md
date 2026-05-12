# Router VM

Router VM digunakan untuk menghubungkan subnet DC dan DRC sehingga komunikasi antar jaringan dapat berjalan.

Router bertindak sebagai gateway utama untuk:

- DC Network (10.10.1.0/24)
- DRC Network (10.20.2.0/24)

## Interface

| Interface | IP |
|----------|----|
| ens33 | 10.10.1.1 |
| ens37 | 10.20.2.1 |

## Fungsi

- Routing antar subnet
- Gateway DC & DRC
- Simulasi routing layer dunia nyata