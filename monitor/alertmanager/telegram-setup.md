# Telegram Setup

## Create Bot

Gunakan:

```text
@BotFather
```

## Get Chat ID

```bash
curl https://api.telegram.org/bot<TOKEN>/getUpdates
```

## Test Notification

```bash
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
-d chat_id=<CHAT_ID> \
-d text="TEST ALERT"
```