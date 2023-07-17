---
title: 在 Ubuntu 上安裝 Caddy 2.6 網頁伺服器
date: 2023-07-18 01:09:50
tags: ["環境部署", "網頁伺服器", "Caddy", "Linux", "Ubuntu"]
categories: ["環境部署", "網頁伺服器"]
---

## 安裝

安裝 caddy 執行檔。

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

啟動網頁。

```bash
caddy run
```

## 設定

修改 `etc/caddy/Caddyfile` 檔。

```txt
:80 {
    root * /usr/share/caddy

    file_server
}

example.com {
    reverse_proxy 127.0.0.1:8000
}
```

## 使用

啟動 caddy 服務，並啟動在背景。

```bash
caddy start
```

停止 caddy 服務。

```bash
caddy stop
```

重新讀取 Caddyfile 設定檔。

```bash
caddy reload
```

## 參考資料

- [Caddy - Documentation](https://caddyserver.com/docs/)
