// ============================================================
// Laporan.typ — Typst version of Laporan.tex
// Requires Typst >= 0.11.0
// Wide table (spanning both columns) is placed outside #columns() blocks
// ============================================================

#set document(
  title: "Prototype Monitoring and Alert System for Disaster Recovery Center (DRC) of Bogor City Government",
  author: "Faiz Naufal Huda et al.",
)

#set page(
  paper: "a4",
  margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm),
  footer: context [
    #h(1fr)
    #text(size: 9pt)[#counter(page).display()]
    #h(1fr)
  ],
)

#set text(font: "Times New Roman", size: 10pt, lang: "id")
#set par(justify: true, leading: 0.65em, spacing: 0.65em, first-line-indent: 1em)
#set list(spacing: 0.65em, indent: 1em)
#set enum(spacing: 0.65em, indent: 1em)
#show raw.where(block: false): set text(font: "Courier New", size: 9pt)
#show raw.where(block: true): set text(font: "Courier New", size: 8pt)

#set heading(numbering: (..nums) => {
  let n = nums.pos()
  if n.len() == 1 { numbering("I", n.at(0)) + "." }
  else if n.len() == 2 { numbering("A", n.at(1)) + "." }
  else { str(n.at(2)) + ")" }
})

#show heading.where(level: 1): it => block(
  above: 1.5em, below: 0.8em,
  width: 100%,
  align(center, text(size: 10pt, weight: "bold")[#upper(it)]),
)
#show heading.where(level: 2): it => block(
  above: 1.2em, below: 0.65em,
  text(size: 10pt, weight: "bold")[#it],
)
#show heading.where(level: 3): it => block(
  above: 1.0em, below: 0.55em,
  text(size: 10pt, style: "italic")[#it],
)

#set figure(gap: 0.5em)
#set figure.caption(separator: [. ])
#show figure.caption: set text(size: 9pt)
#show figure.where(kind: table): it => block(breakable: false)[
  #align(center)[
    #text(size: 8pt, weight: "bold")[TABEL #context counter(figure.where(kind: table)).display("I")]
    #v(-0.15em)
    #text(size: 8pt)[#it.caption.body]
  ]
  #v(0.3em)
  #it.body
]

// ============================================================
// TITLE BLOCK — full width
// ============================================================

#align(center)[
  #text(size: 20pt, weight: "bold")[
    Prototype Monitoring and Alert System for Disaster Recovery Center (DRC)\
    of Bogor City Government
  ]

  #v(6pt)

  #text(size: 12pt, style: "italic")[
    Prototype Sistem Monitoring dan Alert Disaster Recovery Center (DRC)\
    Pemerintah Kota Bogor
  ]

  #v(10pt)

  Faiz Naufal Huda#text(size: 0.65em, baseline: -0.4em)[1],
  Tsabitha Naylasafa Aurora#text(size: 0.65em, baseline: -0.4em)[2],
  Daffa Kautsar Falih#text(size: 0.65em, baseline: -0.4em)[3],
  Muhammad Naufal Fathurrahman#text(size: 0.65em, baseline: -0.4em)[4],
  Dr. Shelvie Nidya Neyman#text(size: 0.65em, baseline: -0.4em)[5]

  #v(4pt)

  #text(size: 9pt)[
    #text(size: 0.65em, baseline: -0.4em)[1,2,3,4]Program Studi Ilmu Komputer, Sekolah Sains Data, Matematika, dan Informatika,\
    Institut Pertanian Bogor, Indonesia\
    #text(size: 0.65em, baseline: -0.4em)[5]Departemen Ilmu Komputer, Institut Pertanian Bogor, Indonesia\
    corresponding author: faizhuda\@apps.ipb.ac.id
  ]

]

#v(6pt)
#line(length: 100%)
#v(6pt)

#text(size: 9pt)[
  *Abstract*---Digital services of Bogor City Government increasingly depend on reliable information
  technology infrastructure, as mandated by Presidential Regulation No. 95 of 2018 on Electronic-Based
  Government Systems (SPBE). However, to the authors' knowledge, no standardized real-time monitoring
  mechanism has been implemented for government-owned Disaster Recovery Centers (DRC) at the regional
  level. This research designs
  and implements a prototype real-time monitoring and alerting system for a DRC using an open-source
  technology stack: Prometheus 3.8.1, Grafana 12.4.1, Alertmanager 0.31.0, and Node Exporter 1.10.2. The system
  monitors seven critical infrastructure parameters across four virtual machines running Ubuntu Server
  24.04 LTS in a simulated DC-DRC environment, and delivers automatic notifications via Telegram Bot
  API. An inhibit rules mechanism suppresses redundant resource alerts when a NodeDown event is active,
  preventing alert storms. All components run as systemd services with a 15-second scrape interval.
  Testing was conducted through load simulation using iperf3 and stress-ng in a VMware Workstation
  environment. The results show that the system successfully detects and delivers alerts with an
  average latency of 83 seconds, with zero missed incidents and threshold detection accuracy of 97.1%.
]

#v(4pt)
#text(size: 9pt)[_Index Terms_---alert, disaster recovery center, Grafana, inhibit rules, monitoring,
Prometheus, systemd, virtual machine.]

#v(8pt)
#line(length: 100%)
#v(6pt)

#text(size: 9pt)[
  *Abstrak*---Layanan digital Pemerintah Kota Bogor semakin bergantung pada infrastruktur teknologi
  informasi yang handal, sebagaimana diamanatkan oleh Peraturan Presiden Nomor 95 Tahun 2018 tentang
  Sistem Pemerintahan Berbasis Elektronik (SPBE). Namun, sepengetahuan peneliti, belum terdapat
  mekanisme pemantauan _real-time_ yang terstandarisasi untuk _Disaster Recovery Center_ (DRC) milik
  pemerintah daerah.
  Penelitian ini merancang dan mengimplementasikan _prototype_ sistem _monitoring_ dan _alerting
  real-time_ untuk DRC menggunakan _stack_ teknologi _open-source_: Prometheus 3.8.1, Grafana 12.4.1,
  Alertmanager 0.31.0, dan Node Exporter 1.10.2. Sistem memantau tujuh parameter kritis pada empat _virtual
  machine_ Ubuntu Server 24.04 LTS yang mensimulasikan lingkungan DC-DRC, dan mengirimkan notifikasi
  otomatis melalui Telegram Bot API. Mekanisme _inhibit rules_ menekan _alert_ sumber daya yang
  redundan saat kondisi NodeDown aktif, mencegah _alert storm_. Seluruh komponen berjalan sebagai
  layanan _systemd_ dengan _scrape interval_ 15 detik. Pengujian dilakukan melalui simulasi beban
  menggunakan iperf3 dan stress-ng pada lingkungan VMware Workstation. Hasil pengujian menunjukkan
  sistem berhasil mendeteksi dan mengirimkan _alert_ dengan rata-rata latensi 83 detik, tanpa ada
  gangguan yang terlewat, dengan akurasi deteksi _threshold_ sebesar 97,1%.
]

#v(4pt)
#text(size: 9pt)[*Kata Kunci:* _alert_, _disaster recovery center_, Grafana, _inhibit rules_,
_monitoring_, Prometheus, _systemd_, _virtual machine_.]

#v(8pt)
#line(length: 100%)
#v(10pt)

// ============================================================
// BODY — columns block 1 (Pendahuluan → sebelum tabel lebar)
// ============================================================

#columns(2, gutter: 0.6cm)[

= Pendahuluan

Peraturan Presiden Nomor 95 Tahun 2018 tentang Sistem Pemerintahan Berbasis Elektronik (SPBE)
mewajibkan seluruh instansi pemerintah untuk memastikan ketersediaan layanan digital secara
berkelanjutan @perpres2018. Sebagai implementasi dari mandat tersebut, Diskominfo Kota Bogor sebagai
pengelola infrastruktur teknologi informasi pemerintahan bertanggung jawab menjaga keberlangsungan
layanan melalui mekanisme _Disaster Recovery Center_ (DRC). BSSN (2021) menegaskan bahwa DRC
merupakan komponen wajib dalam rencana keberlangsungan layanan pemerintah, namun pedoman tersebut
tidak menyertakan panduan teknis mengenai mekanisme pemantauan kondisi DRC secara _real-time_
@bssn2021. Kesenjangan antara kewajiban regulasi dan ketersediaan solusi teknis yang terjangkau
inilah yang menjadi permasalahan utama penelitian ini.

Sistem _monitoring_ yang andal sangat dibutuhkan untuk mendeteksi anomali sebelum terjadi kegagalan
layanan. Tanpa pemantauan _real-time_, administrator cenderung baru mengetahui kegagalan setelah dampaknya
dirasakan pengguna. _Stack monitoring open-source_ seperti Prometheus dan Grafana
menawarkan solusi yang fleksibel, skalabel, dan tidak memerlukan biaya lisensi, sehingga sesuai
dengan kendala anggaran pemerintah daerah @pivotto2023. Penelitian ini merancang _prototype_ sistem
_monitoring_ dan _alert_ yang memantau tujuh parameter kritis (ketersediaan _node_, CPU, memori,
_disk_, _load average_, trafik jaringan, dan I/O _disk_) secara _real-time_, serta mengirimkan
notifikasi otomatis kepada administrator melalui Telegram.

Berdasarkan latar belakang tersebut, rumusan masalah penelitian ini adalah:

+ Bagaimana merancang arsitektur sistem _monitoring real-time_ yang sesuai untuk lingkungan DRC
  Diskominfo Kota Bogor dengan _stack open-source_?
+ Parameter kritis apa saja yang perlu dipantau untuk menjamin kontinuitas layanan DRC, dan berapa
  nilai _threshold_ yang tepat untuk tiap parameter?
+ Bagaimana sistem _alerting_ dapat mendeteksi gangguan dan memberikan notifikasi otomatis sambil
  mencegah _alert storm_ akibat kegagalan berantai?
+ Bagaimana merancang _dashboard_ visual yang intuitif dan representatif untuk mendukung pengambilan
  keputusan administrator?

Tujuan penelitian ini adalah:

+ Merancang dan mengimplementasikan _prototype_ sistem _monitoring_ infrastruktur DRC berbasis
  Prometheus dan Grafana sebagai bukti konsep (_proof of concept_) yang dapat diadopsi pemerintah
  daerah.
+ Mendefinisikan dan mengonfigurasi _threshold_ tujuh parameter kritis infrastruktur DRC berdasarkan
  kajian literatur dan _best practice_ industri.
+ Membangun sistem _alerting_ terintegrasi dengan Telegram Bot API beserta mekanisme _inhibit rules_
  untuk mencegah _alert storm_.
+ Merancang _dashboard_ visual _Command Center_ dengan indikator _Business Continuity Status_ yang
  representatif untuk kebutuhan Diskominfo Kota Bogor.

= Tinjauan Pustaka

== Disaster Recovery Center (DRC)

_Disaster Recovery Center_ (DRC) merupakan fasilitas cadangan yang dirancang untuk memulihkan
operasional sistem informasi ketika pusat data utama mengalami kegagalan @bssn2021. DRC memiliki
peran strategis dalam menjamin _Business Continuity Plan_ (BCP) suatu organisasi. Konsep _Recovery
Time Objective_ (RTO) dan _Recovery Point Objective_ (RPO) menjadi tolok ukur utama keberhasilan
implementasi DRC @kominfo2016. Dalam konteks penelitian ini, pemantauan parameter kesehatan DRC
secara _real-time_ merupakan prasyarat teknis untuk meminimalkan RTO: administrator hanya dapat
memutuskan _failover_ ke DRC jika kondisi infrastruktur DRC dipastikan siap, dan keputusan tersebut
membutuhkan data yang akurat dan terkini.

== Sistem Monitoring Infrastruktur

Sistem _monitoring_ infrastruktur adalah sekumpulan alat yang mengamati kondisi _server_, jaringan,
dan layanan secara berkelanjutan @turnbull2018. Terdapat dua pendekatan utama: _pull-based monitoring_
di mana _server_ aktif mengambil data dari target, dan _push-based monitoring_ di mana target
mengirimkan data ke _server_. Pendekatan _pull-based_ lebih mudah dikonfigurasi pada lingkungan VM
terisolasi karena tidak memerlukan konfigurasi pengiriman data dari tiap target, melainkan cukup
mengekspos _endpoint_ HTTP yang dapat diakses oleh _server_ Prometheus @pivotto2023.

== Prometheus

Prometheus versi 3.8.1 adalah sistem _monitoring_ dan _time-series database open-source_ yang dikembangkan oleh
SoundCloud dan saat ini dikelola oleh _Cloud Native Computing Foundation_ (CNCF) @cncf2023. Prometheus
menggunakan PromQL (_Prometheus Query Language_) untuk mengekstrak dan menganalisis metrik. Data
dikumpulkan dari _exporter_ pada interval waktu yang dapat dikonfigurasi (_scrape interval_)
@turnbull2018. Prometheus dipilih dalam penelitian ini karena mendukung evaluasi _alert rules_ berbasis
PromQL secara _native_, terintegrasi langsung dengan Alertmanager, dan menyediakan ekspresi yang
fleksibel untuk mendefinisikan _threshold_ kompleks seperti _load average_ relatif per-vCPU
@pivotto2023 @cncf2023.

== Grafana

Grafana adalah platform visualisasi data _open-source_ yang mendukung Prometheus sebagai _data source_
secara _native_ @grafana2024. Grafana menyediakan berbagai jenis panel (_time series_, _gauge_,
_stat_) serta manajemen pengguna berbasis peran yang memungkinkan pembedaan akses antara administrator
dan _viewer_ @grafana2024. Grafana dipilih karena kemampuan panel _gauge_ dan _stat_-nya cocok untuk
visualisasi kondisi infrastruktur secara sekilas (_at-a-glance_), dan panel _stat_ mendukung
konfigurasi _value mapping_ sehingga indikator _Business Continuity Status_ dapat dikonfigurasi
sebagai panel biner (Hijau/Merah) tanpa pengembangan _custom plugin_.

== Alertmanager

Alertmanager versi 0.31.0 adalah komponen Prometheus yang bertanggung jawab menangani _alert_ @cncf2023.
Alertmanager menyediakan _routing_, pengelompokan (_grouping_), _deduplication_, dan _inhibit rules_.
Mekanisme _inhibit rules_ memungkinkan penekanan _alert_ yang redundan: apabila _alert_ sumber
(NodeDown) aktif, _alert_ target yang berkaitan pada _instance_ yang sama ditekan secara otomatis.
Alertmanager dipilih dibandingkan alternatif seperti Grafana Alerting karena _inhibit rules_-nya
beroperasi di level _routing_ sehingga lebih presisi dan dapat dikonfigurasi tanpa bergantung pada
antarmuka grafis @cncf2023.

== Node Exporter

_Node Exporter_ versi 1.10.2 adalah agen Prometheus untuk sistem Linux yang mengekspos metrik
_hardware_ dan sistem operasi melalui _endpoint_ `/metrics` pada port 9100 @cncf2023. Metrik yang
tersedia meliputi CPU _usage_, _memory usage_, _disk_ I/O, _filesystem usage_, dan _network
statistics_. Node Exporter dipilih karena mengekspos seluruh metrik sistem yang relevan untuk
pemantauan DRC tanpa memerlukan konfigurasi tambahan, serta dijalankan sebagai layanan _systemd_
agar tetap aktif secara otomatis saat VM _reboot_ @turnbull2018.

== Systemd Service

_Systemd_ adalah sistem inisialisasi dan manajer layanan standar pada distribusi Linux modern,
termasuk Ubuntu Server 24.04 LTS @linux2023. Dengan mendefinisikan berkas unit `.service`, proses
dapat dikelola secara konsisten: dijalankan otomatis saat _boot_, di-_restart_ saat gagal
(`Restart=on-failure`), dan dipantau melalui `systemctl status`. Pendekatan _systemd_ dipilih sebagai
alternatif kontainerisasi (Docker) karena secara signifikan lebih ringan pada VM dengan alokasi RAM
1 GB, tidak memerlukan _daemon_ tambahan, dan terintegrasi langsung dengan sistem operasi sehingga
mengurangi kompleksitas _deployment_ @linux2023.

== Telegram Bot API

Telegram Bot API adalah antarmuka pemrograman yang memungkinkan pembuatan bot otomatis pada platform
Telegram @telegram2023. Alertmanager dikonfigurasi untuk mengirimkan pesan berformat HTML ke grup
Telegram melalui Telegram Bot API, memungkinkan administrator menerima peringatan secara instan di perangkat
_mobile_. Telegram dipilih sebagai saluran notifikasi karena tidak memerlukan konfigurasi server email
atau berlangganan layanan berbayar, mendukung format HTML untuk penyajian informasi terstruktur, dan
telah terbukti efektif pada penelitian serupa @Rahman2020.

== Traffic Generator (iperf3 dan stress-ng)

`iperf3` adalah alat _benchmark_ jaringan yang menghasilkan trafik TCP/UDP sintetis untuk mengukur
_throughput_. `stress-ng` adalah utilitas pengujian beban sistem yang mensimulasikan
penggunaan CPU, memori, dan I/O secara terprogram. Kedua alat ini dipilih karena dapat menghasilkan
beban yang terkontrol dan terulang (_reproducible_), sehingga memungkinkan pengukuran latensi _alert_
yang konsisten antar iterasi pengujian.

== Penelitian Terdahulu

Rahman et al. @Rahman2020 mengimplementasikan Prometheus dan Grafana untuk _monitoring server_
universitas dengan notifikasi Telegram, mencapai latensi deteksi di bawah 30 detik. Rahayu et al.
@Rahayu2025 mengembangkan sistem _monitoring real-time_ berbasis Zabbix dengan notifikasi _alert_
Telegram pada lingkungan jaringan kampus.

Penelitian ini membedakan diri dari kedua studi tersebut dalam tiga aspek mendasar. Pertama, konteks
permasalahan: kedua studi sebelumnya berfokus pada _monitoring_ infrastruktur umum, sedangkan
penelitian ini secara spesifik menyasar DRC pemerintah daerah dengan parameter yang relevan untuk
_Business Continuity Plan_ dan keputusan _failover_. Kedua, manajemen _alert storm_: Rahman et al.
tidak membahas mekanisme penekanan _alert_ redundan, dan Rahayu et al. menggunakan Zabbix yang
memiliki pendekatan berbeda; penelitian ini mengimplementasikan _inhibit rules_ Alertmanager sebagai
kontribusi teknis eksplisit. Ketiga, indikator keberlangsungan: penelitian ini merancang panel
_Business Continuity Status_ sebagai indikator tunggal ketersediaan DC Server untuk keputusan
_failover_, yang tidak ditemukan pada penelitian sebelumnya dan secara langsung mendukung keputusan
operasional administrator DRC.

= Kerangka Pemikiran

Penelitian ini dibangun di atas tiga premis yang saling terhubung. _Premis pertama_: regulasi SPBE
mewajibkan ketersediaan layanan digital, namun tidak menyertakan panduan teknis pemantauan DRC secara
_real-time_, sehingga terdapat kesenjangan antara kewajiban regulasi dan kapabilitas teknis yang
tersedia. _Premis kedua_: _stack_ teknologi _open-source_ (Prometheus + Grafana + Alertmanager) telah
menunjukkan keandalannya pada lingkungan serupa @Rahman2020 @Rahayu2025, tidak memerlukan biaya lisensi, dan
dapat dikustomisasi sesuai kebutuhan spesifik DRC. _Premis ketiga_: simulasi berbasis _virtual
machine_ memungkinkan pengembangan dan pengujian _prototype_ secara terkontrol tanpa harus mengakses
infrastruktur produksi Diskominfo yang tidak dapat diinterupsi.

Dari ketiga premis tersebut diturunkan kerangka solusi sebagai berikut. Kesenjangan yang
diidentifikasi pada premis pertama dapat dijembatani oleh _stack open-source_ yang diidentifikasi pada
premis kedua. Sementara itu, risiko pengembangan dapat dikendalikan melalui pendekatan simulasi pada
premis ketiga. Kerangka solusi ini mengarah pada perancangan _prototype_ dengan empat komponen utama:
(1) pengumpulan metrik melalui Node Exporter, (2) evaluasi kondisi dan _alerting_ melalui Prometheus
dan Alertmanager, (3) visualisasi melalui Grafana, dan (4) notifikasi melalui Telegram Bot API.

Alur pikir penelitian dimulai dari identifikasi dan justifikasi tujuh parameter kritis DRC, kemudian
perancangan arsitektur _monitoring_ berbasis _single subnet_ untuk stabilitas optimal, implementasi
seluruh komponen sebagai layanan _systemd_, pengujian fungsional melalui simulasi gangguan yang
terkontrol, hingga evaluasi akurasi dan latensi _alert_. Keluaran akhir adalah _prototype_ yang dapat
direkomendasikan kepada Diskominfo Kota Bogor sebagai dasar pengembangan sistem nyata pada
infrastruktur produksi. Kerangka pemikiran ini dirangkum secara visual pada @fig-kerangka.

#figure(
  image("images/Kerangka Berpikir.png", width: 100%),
  caption: [Kerangka Pemikiran Penelitian.],
) <fig-kerangka>

= Metode

== Waktu dan Tempat Penelitian

Penelitian dilaksanakan selama empat bulan (Maret--Juni 2026) bertempat di Laboratorium Ilmu Komputer,
Institut Pertanian Bogor. Seluruh implementasi dan pengujian dilakukan pada lingkungan _virtual
machine_ lokal menggunakan VMware Workstation tanpa memerlukan koneksi ke infrastruktur Diskominfo
Kota Bogor.

== Alat dan Bahan

=== Perangkat Keras

- _Laptop_/PC: prosesor minimum 4 _core_, RAM 16 GB, _storage_ 256 GB SSD.
- Koneksi jaringan lokal untuk simulasi komunikasi antar-VM.

=== Perangkat Lunak

- _Hypervisor_: VMware Workstation.
- Sistem Operasi VM: Ubuntu Server 24.04 LTS.
- _Stack Monitoring_: Prometheus 3.8.1, Grafana 12.4.1, Alertmanager 0.31.0 --- dijalankan sebagai layanan
  _systemd_.
- Agen _Monitoring_: Node Exporter 1.10.2 --- layanan _systemd_ pada seluruh empat VM, masing-masing berjalan pada port 9100.
- _Traffic Generator_: `iperf3`, `stress-ng`.
- Notifikasi: Telegram Bot API.
- Akses Publik: Cloudflare Tunnel (`cloudflared`).

== Prosedur Penelitian

=== Maret 2026 --- Studi Parameter dan Setup Lingkungan

Studi literatur mengenai DRC, Prometheus, Grafana, dan Alertmanager dilakukan pada tahap ini.
Pemilihan tujuh parameter _threshold_ didasarkan pada rekomendasi _best practice_ industri
@turnbull2018 @pivotto2023. Nilai CPU dan memori sebesar 80% ditetapkan untuk menyisakan _headroom_
20% bagi operasi sistem operasi dan proses latar belakang, sesuai dengan yang diterapkan Rahman et al.
@Rahman2020 pada sistem serupa. Nilai _load average_ 1,5 per vCPU mengindikasikan antrean proses yang
mulai melebihi kapasitas pemrosesan, sehingga _response time_ layanan dapat terdegradasi @turnbull2018.
_Threshold disk usage_ 80% memberikan jendela waktu yang cukup bagi administrator untuk mengosongkan
_storage_ sebelum sistem mengalami kegagalan penulisan log. Nilai _disk I/O wait_ 20% menandakan
bahwa prosesor menghabiskan seperlima waktunya menunggu operasi _disk_, yang mengindikasikan
_bottleneck_ I/O pada sistem @turnbull2018. Nilai _threshold_ trafik jaringan 10 MB/s ditetapkan sebagai indikator _congestion_ yang berpotensi
mengganggu alur replikasi data antara DC dan DRC; nilai ini juga dikalibrasi terhadap kapasitas
antarmuka jaringan virtual VMware pada lingkungan pengujian agar skenario dapat diverifikasi secara
konsisten.

Empat _virtual machine_ disiapkan dalam satu subnet `10.10.1.0/24`: Monitoring Server (10.10.1.100),
DC Server (10.10.1.10), DRC Server (10.10.1.20), dan Router VM (10.10.1.2), seperti ditunjukkan pada
@fig-arsitektur-jaringan.

#figure(
  image("images/topology new.png", width: 100%),
  caption: [Arsitektur Jaringan Virtual dan Topologi VM (subnet 10.10.1.0/24).],
) <fig-arsitektur-jaringan>

=== April 2026 --- Deployment Stack Monitoring

Prometheus, Grafana, dan Alertmanager diinstalasi sebagai layanan _systemd_ pada VM Monitoring
Server. Node Exporter 1.10.2 diinstalasi dan didaftarkan sebagai layanan _systemd_ pada DC Server,
DRC Server, Router VM, dan Monitoring Server. _Scrape target_ Prometheus dikonfigurasi dengan _scrape interval_ 15 detik
dan _scrape timeout_ 10 detik. Verifikasi aliran data metrik dilakukan menggunakan antarmuka Prometheus
Expression Browser dan kueri PromQL dasar.

=== Mei 2026 --- Pengembangan Sistem Alerting dan Pengujian

Tujuh aturan _alerting_ ditulis dalam berkas `alert.rules.yml`. Konfigurasi Alertmanager mencakup
_routing_, _grouping_ (`group_wait`: 10 detik), _inhibit rules_, dan integrasi Telegram Bot API
dengan format pesan HTML. Simulasi gangguan dilakukan secara terpisah untuk setiap _alert rule_, dengan enam perintah yang
meng-_cover_ tujuh skenario. Perintah `stress-ng --cpu` pada VM 1 vCPU secara simultan memicu
HighCPUUsage dan HighLoad; keduanya tetap diukur sebagai skenario independen karena menggunakan
ekspresi PromQL yang berbeda (`node_cpu_seconds_total` untuk utilisasi CPU vs `node_load1` untuk
_load average_). Seluruh skenario beban dieksekusi pada DC Server (10.10.1.10) sebagai _node_
representatif; skenario HighNetworkTraffic menggunakan DC Server sebagai _client_ iperf3 dan DRC
Server (10.10.1.20) sebagai _server_. Perintah-perintah yang dieksekusi:

#raw(block: true, lang: "sh",
"# HighCPUUsage + HighLoad (dua alert dari satu stimulus)
stress-ng --cpu 4 --timeout 120s

# HighMemoryUsage
stress-ng --vm 2 --vm-bytes 90% --timeout 120s

# HighDiskUsage (ukuran file disesuaikan agar disk usage > 80%)
SIZE=$(df --output=avail -B1 / | tail -1 | awk '{print int($1*0.9)}')
fallocate -l $SIZE /tmp/fill.img && rm /tmp/fill.img

# HighDiskIOWait
stress-ng --hdd 2 --hdd-bytes 1G --timeout 120s

# HighNetworkTraffic (DC Server -> DRC Server)
iperf3 -c 10.10.1.20 -t 120

# NodeDown
sudo systemctl stop node_exporter")

=== Juni 2026 --- Dashboarding dan Finalisasi

_Dashboard_ Grafana bertema _Command Center_ dirancang dengan enam seksi panel yang dikelompokkan
dalam empat area visualisasi: _Business Continuity Status_, _Node Status_, performa per-_node_
(DC Server, DRC Server, Router VM), dan _System Health_. Akses publik ke _dashboard_ selama fase
pengembangan dikonfigurasi melalui Cloudflare Tunnel (`cloudflared`), yang meneruskan port 3000
Grafana ke URL sementara `*.trycloudflare.com` tanpa memerlukan konfigurasi _port forwarding_ atau
IP publik. Evaluasi akurasi dan latensi _alert_ dilakukan, disertai penyusunan dokumentasi teknis
lengkap.

== Perancangan Sistem

=== Arsitektur Sistem Monitoring

Arsitektur sistem terdiri dari tiga lapisan utama:

+ _Lapisan Target_ --- empat VM dengan Node Exporter berjalan sebagai layanan _systemd_ pada port
  9100;
+ _Lapisan Pengumpulan Data_ --- Prometheus yang melakukan _scraping_ setiap 15 detik, menyimpan data
  dalam _time-series database_, dan mengevaluasi tujuh _alert rules_; dan
+ _Lapisan Visualisasi dan Notifikasi_ --- Grafana 12.4.1 (port 3000) untuk _dashboard_ dan
  Alertmanager (port 9093) untuk pengiriman notifikasi Telegram.

=== Desain Skenario Alert

Tujuh aturan _alert_ yang diimplementasikan:

- `NodeDown`: `up == 0` selama 1 menit (level: _critical_).
- `HighCPUUsage`: utilisasi CPU > 80% selama 1 menit (level: _warning_).
- `HighMemoryUsage`: penggunaan memori > 80% selama 1 menit (level: _warning_).
- `HighDiskUsage`: penggunaan _disk_ > 80% selama 1 menit (level: _critical_).
- `HighLoad`: _load average_ per vCPU > 1,5 selama 1 menit (level: _warning_).
- `HighNetworkTraffic`: trafik jaringan > 10 MB/s (SI: 1 MB = 10#super[6] bytes) selama 1 menit (level: _warning_).
- `HighDiskIOWait`: _disk I/O wait_ > 20% selama 1 menit (level: _warning_).

Klausul `for: 1m` diterapkan pada seluruh aturan untuk menghindari _false positive_ akibat lonjakan
metrik sesaat. _Inhibit rules_ dikonfigurasi sehingga apabila NodeDown aktif pada suatu _instance_,
seluruh _alert_ sumber daya untuk _instance_ yang sama ditekan secara otomatis, mencegah _alert
storm_ akibat kegagalan total _node_.

== Metode Pengujian

Pengujian dilakukan dengan metode _Negative Testing_, yaitu dengan sengaja menciptakan kondisi
gangguan untuk memverifikasi kemampuan sistem. Parameter yang diukur:

+ _Alert Latency_ --- waktu (detik) dari eksekusi perintah simulasi gangguan hingga notifikasi
  diterima di Telegram;
+ _Alert Accuracy_ --- rasio _true positive_ terhadap total kejadian gangguan yang disimulasikan;
  dan
+ _Dashboard Refresh Rate_ --- interval pembaruan data pada panel Grafana (dikonfirmasi dari nilai
  `scrape_interval` Prometheus).

Setiap skenario diulang sebanyak lima kali guna memperoleh nilai rata-rata dan standar deviasi yang
valid secara statistik. Seluruh skenario beban dieksekusi pada DC Server (10.10.1.10) sebagai _node_
representatif; skenario NodeDown menghentikan layanan `node_exporter` pada DC Server yang sama.
Pengukuran latensi dilakukan dengan mencatat _timestamp_ eksekusi perintah di terminal dan _timestamp_
notifikasi yang diterima di Telegram.

= Hasil dan Pembahasan

== Spesifikasi Lingkungan Pengujian

Lingkungan pengujian terdiri dari empat _virtual machine_ pada satu _host_ fisik dengan konfigurasi
_single subnet_ `10.10.1.0/24`. Seluruh VM menggunakan Ubuntu Server 24.04 LTS dengan antarmuka
jaringan `ens33`. Pendekatan _single subnet_ dipilih berdasarkan hasil percobaan awal: konfigurasi
_multi-subnet_ di lingkungan VMware menghasilkan latensi jaringan virtual yang tidak konsisten dan
menyebabkan _scrape timeout_ pada Prometheus, sehingga menurunkan keandalan data metrik. Dengan
menyatukan seluruh VM dalam satu subnet, latensi antar-VM dapat diminimalkan dan kestabilan
_scraping_ meningkat secara signifikan. Spesifikasi lengkap setiap VM disajikan pada
@tab-spesifikasi-vm.

] // end columns block 1

// ============================================================
// WIDE TABLE — full page width (like LaTeX table*)
// ============================================================

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr, 1fr),
    align: (left, left, left, left, left),
    stroke: none,
    inset: 6pt,
    table.hline(stroke: 1pt),
    table.header(
      [*Parameter*], [*Monitoring Server*], [*DC Server*], [*DRC Server*], [*Router VM*],
    ),
    table.hline(stroke: 0.5pt),
    [Peran],      [Monitoring Stack],  [Data Center],     [Disaster Recovery], [Gateway],
    [OS],         [Ubuntu 24.04 LTS],  [Ubuntu 24.04 LTS],[Ubuntu 24.04 LTS],  [Ubuntu 24.04 LTS],
    [vCPU],       [2],                 [1],               [1],                 [1],
    [RAM],        [2 GB],              [1 GB],            [1 GB],              [1 GB],
    [IP Address], [10.10.1.100],       [10.10.1.10],      [10.10.1.20],        [10.10.1.2],
    [Port Utama], [3000, 9090, 9093, 9100],  [9100],            [9100],              [9100],
    table.hline(stroke: 1pt),
  ),
  caption: [Spesifikasi Virtual Machine Lingkungan Pengujian.],
) <tab-spesifikasi-vm>

// ============================================================
// BODY — columns block 2 (sisa Hasil dan Pembahasan → akhir)
// ============================================================

#columns(2, gutter: 0.6cm)[

== Implementasi Stack Monitoring

_Stack monitoring_ berhasil diimplementasikan sebagai layanan _systemd_ pada VM Monitoring Server.
Prometheus melakukan _scraping_ ke lima target: empat Node Exporter (DC Server `10.10.1.10:9100`,
DRC Server `10.10.1.20:9100`, Router VM `10.10.1.2:9100`, Monitoring Server `localhost:9100`) dan
Prometheus sendiri (`localhost:9090`). Seluruh target berhasil terhubung dan
menampilkan status _UP_ pada halaman Prometheus Targets (@fig-prometheus-targets), mengkonfirmasi
bahwa aliran data metrik dari keempat VM berjalan dengan baik.

#figure(
  image("images/Prometheus Target Health.png", width: 100%),
  caption: [_Screenshot_ halaman Prometheus Targets: seluruh target berstatus UP.],
) <fig-prometheus-targets>

== Hasil Konfigurasi Threshold

Tujuh _threshold_ ditetapkan berdasarkan kajian literatur dan _best practice_ industri @turnbull2018
@pivotto2023. Seluruh aturan menggunakan klausul `for: 1m` sehingga _alert_ hanya terpicu apabila
kondisi anomali bertahan selama minimal satu menit, bukan akibat lonjakan sesaat. Hal ini
meminimalkan _false positive_ tanpa mengorbankan kecepatan deteksi. Daftar lengkap disajikan pada
@tab-threshold.

#figure(
  {
    set text(size: 8pt)
    table(
      columns: (auto, auto, auto, auto),
      align: (left, center, center, center),
      stroke: none,
      inset: 5pt,
      table.hline(stroke: 1pt),
      table.header(
        [*Alert*], [*Threshold*], [*Durasi*], [*Level*],
      ),
      table.hline(stroke: 0.5pt),
      [NodeDown],           [`up == 0`],  [1 menit], [_Critical_],
      [HighCPUUsage],       [> 80%],      [1 menit], [_Warning_],
      [HighMemoryUsage],    [> 80%],      [1 menit], [_Warning_],
      [HighDiskUsage],      [> 80%],      [1 menit], [_Critical_],
      [HighLoad],           [> 1,5/vCPU], [1 menit], [_Warning_],
      [HighNetworkTraffic], [> 10 MB/s],  [1 menit], [_Warning_],
      [HighDiskIOWait],     [> 20%],      [1 menit], [_Warning_],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Daftar _Threshold_ dan Aturan _Alert_ yang Diimplementasikan.],
) <tab-threshold>

== Kinerja Sistem Alerting

=== Hasil Pengujian Alert Latency

Rata-rata _alert latency_ yang dicapai adalah 83 detik ($"SD" = 6$ detik). Berdasarkan
konfigurasi sistem (`scrape_interval` 15 detik, klausul `for` 1 menit, `group_wait` 10 detik),
latensi teoritis minimum adalah 75--90 detik sejak ambang batas pertama kali terlampaui hingga
notifikasi diterima. Hasil per skenario disajikan pada @tab-alert-latency.

#figure(
  {
    set text(size: 8pt)
    table(
      columns: (auto, auto, auto),
      align: (left, center, center),
      stroke: none,
      inset: 5pt,
      table.hline(stroke: 1pt),
      table.header(
        [*Skenario*], [*Rata-rata (s)*], [*SD (s)*],
      ),
      table.hline(stroke: 0.5pt),
      [NodeDown],           [79], [4],
      [HighCPUUsage],       [83], [5],
      [HighMemoryUsage],    [81], [4],
      [HighDiskUsage],      [87], [7],
      [HighLoad],           [84], [5],
      [HighNetworkTraffic], [81], [4],
      [HighDiskIOWait],     [86], [7],
      table.hline(stroke: 1pt),
    )
  },
  caption: [Hasil Pengukuran _Alert Latency_ per Skenario.],
) <tab-alert-latency>

=== Hasil Pengujian Alert Accuracy

Dari total 35 skenario gangguan yang disimulasikan, sistem berhasil mendeteksi 34 gangguan
dengan benar (_true positive_), 1 _false positive_, dan 0 _false negative_, sehingga akurasi
keseluruhan mencapai 97,1%. Satu _false positive_ yang tercatat terjadi pada salah satu iterasi
skenario HighNetworkTraffic: trafik latar belakang hypervisor VMware sesaat melebihi _threshold_
10 MB/s sebelum stimulus iperf3 dieksekusi, sehingga _alert_ terpicu bukan oleh beban uji yang
disengaja melainkan oleh _noise_ jaringan virtual.

=== Hasil Pengujian Dashboard Refresh Rate

_Dashboard refresh rate_ dikonfirmasi sebesar 15 detik, sesuai dengan nilai `scrape_interval`
yang dikonfigurasi pada Prometheus. Pembaruan panel Grafana terjadi secara otomatis mengikuti
siklus _scraping_ metrik setiap 15 detik.

== Tampilan Dashboard Grafana

_Dashboard_ Grafana 12.4.1 yang dikembangkan dapat diakses pada `10.10.1.100:3000` dan memuat enam
seksi panel yang dikelompokkan dalam empat area visualisasi (@fig-dashboard):

- _Business Continuity Status_: panel penuh lebar menampilkan status operasional keseluruhan (Hijau =
  NORMAL --- DC OPERATIONAL; Merah = DISASTER --- DRC ACTIVE). Panel ini menggunakan ekspresi PromQL
  `up{job="dc-server"}` yang secara langsung mencerminkan ketersediaan DC Server sebagai penentu
  keputusan _failover_.
- _Node Status_: empat kartu konektivitas individual untuk DC Server, DRC Server, Router VM, dan
  Monitoring Server.
- _Performa DC Server, DRC Server, dan Router VM_: tiga panel _gauge_ (CPU, memori, _disk_) dan satu
  panel _time series_ trafik jaringan per _node_. Monitoring Server dikecualikan dari area ini karena
  berperan sebagai infrastruktur pengamat, bukan sebagai _node_ DRC yang relevan untuk keputusan
  _failover_.
- _System Health_: grafik _load average_ komparatif keempat _node_ dan empat panel _uptime_
  individual.

#figure(
  image("images/Grafana Dashboard.png", width: 100%),
  caption: [_Dashboard_ Grafana 12.4.1 bertema _Command Center_: panel _Business Continuity Status_ (atas) dan _Node Status_ (bawah).],
) <fig-dashboard>

Setiap kondisi _alert_ menghasilkan notifikasi Telegram berformat HTML yang dikirim ke grup
administrator (@fig-telegram-alert). Pesan _firing_ memuat nama _alert_, level (_critical_/_warning_),
deskripsi kondisi anomali yang mencakup _threshold_ yang terlampaui, dan _instance_ yang terdampak. Pesan _resolved_ dikirim secara
otomatis oleh Alertmanager saat kondisi kembali normal, memberikan konfirmasi pemulihan tanpa
intervensi manual.

#figure(
  image("images/Telegram Alert.png", width: 100%),
  caption: [Notifikasi _alert_ Telegram format HTML: kondisi _firing_ dan _resolved_.],
) <fig-telegram-alert>

== Evaluasi dan Analisis

Secara keseluruhan, _prototype_ sistem _monitoring_ berhasil memenuhi seluruh target fungsional yang
ditetapkan pada rumusan masalah. Untuk menjawab rumusan masalah pertama, arsitektur _single subnet_
`10.10.1.0/24` dengan empat VM menunjukkan stabilitas dan dapat direproduksi dalam lingkungan pengujian ini. Untuk rumusan masalah kedua,
tujuh parameter dengan justifikasi _threshold_ berbasis literatur berhasil dipantau secara konsisten.
Untuk rumusan masalah ketiga, _alert latency_ berada di bawah 120 detik dan mekanisme _inhibit rules_
berhasil mencegah _alert storm_ pada pengujian skenario NodeDown. Untuk rumusan masalah keempat,
panel _Business Continuity Status_ memberikan indikator biner yang dapat dibaca secara langsung oleh administrator.

Dua kendala utama yang dihadapi adalah: (1) keterbatasan RAM 1 GB pada VM target memengaruhi kinerja
saat beban penuh, yang secara tidak langsung mempercepat tercapainya _threshold_ dan dapat
mempersingkat latensi deteksi; dan (2) Grafana versi 12 menggunakan API berbasis Kubernetes
(`/apis/dashboard.grafana.app/v1beta1/`) yang pada konfigurasi _default_ tidak mengaktifkan
_anonymous access_; kendala ini diatasi dengan mengaktifkan opsi `[auth.anonymous]` pada berkas
`grafana.ini` dan menetapkan peran _viewer_ sebagai peran _default_ organisasi, sehingga
_dashboard_ dapat diakses tanpa autentikasi.

Dibandingkan dengan Rahman et al. @Rahman2020 yang mencapai latensi di bawah 30 detik, latensi
penelitian ini lebih panjang karena adanya klausul `for: 1m` yang sengaja diterapkan untuk
meminimalkan _false positive_. Menurut penilaian peneliti, pertukaran ini (_trade-off_) antara kecepatan deteksi dan akurasi
lebih tepat untuk konteks DRC pemerintah daerah, di mana notifikasi yang salah dapat
menyebabkan tindakan _failover_ yang tidak perlu dan berdampak pada layanan publik.

Dibandingkan dengan Rahayu et al. @Rahayu2025 yang menggunakan Zabbix, Alertmanager dalam penelitian
ini menyediakan mekanisme _inhibit rules_ yang beroperasi di level _routing_ sehingga pencegahan
_alert storm_ pada kondisi NodeDown berjalan otomatis tanpa perlu mengonfigurasi dependensi
antar-_trigger_ secara manual seperti pada Zabbix.

= Simpulan dan Saran

== Simpulan

+ _Prototype_ sistem _monitoring_ dan _alert_ DRC berhasil dibangun menggunakan _stack open-source_
  (Prometheus 3.8.1, Grafana 12.4.1, Alertmanager 0.31.0, Node Exporter 1.10.2) sebagai layanan _systemd_ pada
  empat _virtual machine_ Ubuntu Server 24.04 LTS dalam subnet `10.10.1.0/24`, mendemonstrasikan
  kelayakan solusi _open-source_ sebagai alternatif sistem _monitoring_ komersial untuk pemerintah daerah.
+ Tujuh parameter kritis DRC berhasil dipantau secara _real-time_ dengan _threshold_ yang
  terjustifikasi secara literatur: dari 35 skenario gangguan, 34 terdeteksi benar (_true positive_),
  0 gangguan terlewat (_false negative_), dengan akurasi keseluruhan 97,1% dan rata-rata _alert
  latency_ 83 detik.
+ Integrasi Telegram Bot API dengan format pesan HTML dan mekanisme _inhibit rules_ berfungsi efektif:
  notifikasi gangguan diterima secara otomatis dalam rata-rata 83 detik, dan _alert storm_ akibat kondisi NodeDown berhasil
  ditekan tanpa intervensi manual saat _runtime_.
+ _Dashboard_ Grafana bertema _Command Center_ dengan panel _Business Continuity Status_ berhasil
  menyediakan indikator operasional tunggal yang dapat dibaca secara langsung, membantu administrator mengambil keputusan
  _failover_ berdasarkan data _real-time_.

== Saran

+ Penelitian lanjutan disarankan melibatkan integrasi langsung dengan infrastruktur Diskominfo untuk
  validasi pada lingkungan produksi nyata.
+ Penambahan _exporter_ khusus (MySQL Exporter, PostgreSQL Exporter) dapat meningkatkan cakupan
  pemantauan replikasi _database_ sebagai parameter DRC yang kritis dalam konteks RPO.
+ Sistem saat ini menggunakan Cloudflare Quick Tunnel yang menghasilkan URL sementara
  (_trycloudflare.com_); disarankan beralih ke Named Tunnel dengan domain khusus untuk
  akses publik yang stabil dan permanen di lingkungan produksi.
+ Eksplorasi _machine learning_ untuk _anomaly detection_ dapat mengurangi _false positive_ dan
  memungkinkan prediksi kegagalan sebelum _threshold_ statis terlampaui.
+ Penguatan keamanan sistem _monitoring_ (autentikasi mutual TLS pada Prometheus, enkripsi komunikasi
  Alertmanager) perlu dilakukan sebelum _deployment_ ke lingkungan produksi.
+ Penerapan _high availability_ pada Monitoring Server, misalnya melalui Prometheus Federation atau
  replikasi Grafana, perlu dipertimbangkan untuk mengeliminasi _single point of failure_ pada
  infrastruktur _monitoring_ itu sendiri.

#heading(numbering: none)[Ucapan Terima Kasih]

Terima kasih kepada Dinas Komunikasi dan Informatika (Diskominfo) Kota Bogor atas kerja sama,
bimbingan, dan penyediaan informasi yang sangat membantu dalam penyusunan penelitian ini. Terima
kasih juga disampaikan kepada Program Studi Ilmu Komputer, Sekolah Sains Data, Matematika, dan
Informatika, Institut Pertanian Bogor (SSMI, IPB University) atas dukungan fasilitas dan akademik
yang telah diberikan.

#bibliography("docs/refs.bib", style: "ieee", title: "Daftar Pustaka")

] // end columns block 2
