---
title: 使用 Uberduck 服務生成 AI 音樂內容
date: 2023-11-13 15:28:05
tags: ["Generative AI", "AI"]
categories: ["Generative AI"]
---

## 前置作業

首先到 [Uberduck](https://app.uberduck.ai/) 註冊一個帳號，並生成一個 API Key。

將 API Key 編碼，用來當作 token 使用。

```bash
echo -n "pub_...:pk_..." | base64
```

將 token 寫入環境變數。

```bash
export UBERDUCK_TOKEN=...
```

## 使用

取得聲音列表。

```bash
curl --request GET \
  --url 'https://api.uberduck.ai/voices' \
  --header "Authorization: Basic $UBERDUCK_TOKEN"
```

取得聲音詳細資訊。

```bash
curl --request GET \
  --url https://api.uberduck.ai/voices/92022a27-75fb-4e15-90ca-95095a82f5ee/detail \
  --header "Authorization: Basic $UBERDUCK_TOKEN"
```

將文字轉成聲音。

```bash
curl --request POST \
  --url https://api.uberduck.ai/speak \
  --header "Authorization: Basic $UBERDUCK_TOKEN" \
  --header 'Content-Type: application/json' \
  --data '{
  "speech": "War is cruelty",
  "voicemodel_uuid": "92022a27-75fb-4e15-90ca-95095a82f5ee"
}'
```

查看將文字轉成聲音的執行狀態。

```bash
curl --request GET \
  --url 'https://api.uberduck.ai/speak-status?uuid=9bea9232-44ea-4d9e-b7d6-6e733144c848' \
  --header "Authorization: Basic $UBERDUCK_TOKEN"
```

生成一段歌詞。

```bash
curl --request POST \
  --url 'https://api.uberduck.ai/tts/lyrics' \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Authorization: Basic $UBERDUCK_TOKEN" \
  --data '{
  "subject": "hello world",
  "backing_track": "1e4c6e5a-2782-4a7c-aa98-2a6c48904de5",
  "lines": null
}'
```

生成一段即興饒舌。

```bash
curl --request POST \
  --url 'https://api.uberduck.ai/tts/freestyle' \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header "Authorization: Basic $UBERDUCK_TOKEN" \
  --data '{
  "bpm": 90,
  "backing_track": "5fff1ec6-8736-4992-a842-8b78d37b8a8a",
  "lyrics": [
    [
      "Hello world, Im the rap king, the one and only",
      "My rhymes so complex, theyll leave you feeling lonely",
      "Im like a surgeon with a scalpel, precise and deadly",
      "My metaphors and similes, they hit hard and steady"
    ]
  ],
  "voicemodel_uuid": "c8a916b4-4574-4042-82a1-3cead35331c9"
}'
```
