---
title: 在 Ubuntu 上安裝 Caddy 2.0 網頁伺服器
permalink: 在-Ubuntu-上安裝-Caddy-2-0-網頁伺服器
date: 2020-04-17 13:26:31
tags: ["環境部署", "Caddy", "Linux", "Ubuntu"]
categories: ["環境部署", "Caddy"]
---

## 環境

- Ubuntu 18.04 LTS

## 安裝

到 Caddy 的 [GitHub](https://github.com/caddyserver/caddy/releases) 查看最新版本，下載 Caddy。

```BASH
wget https://github.com/caddyserver/caddy/releases/download/v2.0.0-rc.3/caddy_2.0.0-rc.3_linux_amd64.tar.gz
```

解壓縮。

```BASH
tar zxvf caddy_2.0.0-rc.3_linux_amd64.tar.gz
```

將執行檔移到 `/usr/bin/` 路徑：

```BASH
sudo mv caddy /usr/bin/
```

查看版本。

```BASH
caddy --version
v2.0.0-rc.3
```

## 設定權限

建立一個 `caddy` 群組。

```BASH
groupadd --system caddy
```

建立一個 `caddy` 使用者。

```BASH
useradd --system \
	--gid caddy \
	--create-home \
	--home-dir /var/lib/caddy \
	--shell /usr/sbin/nologin \
	--comment "Caddy web server" \
	caddy
```

- `--home-dir` 參數決定 Caddy 存放重要檔案的位置，包括 SSL 憑證。

## Caddyfile

在 `/etc/caddy` 資料夾新增 `Caddyfile` 檔：

```BASH
laravel.epoch.tw {
    root * /var/www/laravel/public

    php_fastcgi 127.0.0.1:9000

    encode gzip
    file_server

    log {
        output file /var/log/caddy/laravel_access.log
    }

    tls email@gmail.com
}
```

- 注意 Caddy 2 的指標已有許多更新。

## 設定系統服務

在 `/etc/systemd/system` 資料夾新增一個 `caddy.service` 檔：

```SERVICE
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target

[Service]
User=caddy
Group=caddy
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

重新載入服務設定檔。

```BASH
sudo systemctl daemon-reload
```

將 Caddy 服務設置為自動啟動。

```BASH
sudo systemctl enable caddy
```

啟用 Caddy 服務。

```BASH
sudo systemctl start caddy
```

檢查 Caddy 服務狀態。

```BASH
sudo systemctl status caddy
```

如果修改設定檔，執行以下指令重新啟動 Caddy 服務：

```BASH
sudo systemctl reload caddy
```

如果要關閉 Caddy 服務，執行以下指令：

```BASH
sudo systemctl stop caddy
```

## 參考資料

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Upgrade Guide](https://caddyserver.com/docs/v2-upgrade)
