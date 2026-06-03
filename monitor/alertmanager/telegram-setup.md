# Telegram Setup

## 1. Buat Bot

Buka Telegram, cari @BotFather, lalu:

```text
/newbot
```

Ikuti instruksi, salin token yang diberikan.

## 2. Dapatkan Chat ID

Kirim pesan ke bot kamu, lalu jalankan:

```bash
curl https://api.telegram.org/bot<TOKEN>/getUpdates
```

Ambil nilai `chat.id` dari response JSON.

## 3. Isi Config Alertmanager di VM

Edit file di VM (bukan di repo):

```bash
sudo nano /etc/alertmanager/alertmanager.yml
```

Ganti placeholder:

```yaml
bot_token: "ISI_TOKEN_DISINI"
chat_id: ISI_CHAT_ID_DISINI
```

Restart Alertmanager:

```bash
sudo systemctl restart alertmanager
```

## 4. Test Notifikasi

```bash
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d chat_id=<CHAT_ID> \
  -d text="Test alert dari Alertmanager"
```

## Catatan

- Format pesan menggunakan `parse_mode: HTML`
- Alert firing dan resolved keduanya dikirim (`send_resolved: true`)
- Timestamp ditampilkan dalam WIB (sistem harus diset ke timezone Asia/Jakarta)
- Jika NodeDown firing, alert resource (CPU/Memory/Disk/dll) untuk server yang sama
  akan di-suppress otomatis via inhibit_rules
