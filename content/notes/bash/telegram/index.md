---
title: Telegram Command
weight: 100
menu:
  notes:
    name: telegram
    identifier: notes-bash-telegram
    parent: notes-bash
    weight: 10
---

{{< note title="getUpdates" >}}

```bash
curl 'https://api.telegram.org/bot1234567890:KE9zNTZ8RGcxJTMlI29EJElKeU9QQExm3%E/getUpdates' | jq .
```

{{< /note >}}

{{< note title="sendMessage" >}}

```bash
# chat
curl 'https://api.telegram.org/bot1234567890:KE9zNTZ8RGcxJTMlI29EJElKeU9QQExm3%E/sendMessage?chat_id=-12345&text=hello'

# thread
curl 'https://api.telegram.org/bot1234567890:KE9zNTZ8RGcxJTMlI29EJElKeU9QQExm3%E/sendMessage?chat_id=-12345&text=hello&message_thread_id=14'
```

{{< /note >}}
