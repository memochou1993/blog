---
title: 在 Ubuntu 上安裝 Caddy 2.0 網頁伺服器
date: 2020-04-17 13:26:31
tags: ["Deployment", "Web Server", "Caddy", "Linux", "Ubuntu"]
categories: ["Deployment", "Web Server"]
---

## 環境

- Ubuntu 18.04 LTS

## 安裝

下載 Caddy 的[最新版本](https://github.com/caddyserver/caddy/releases)。

```bash
wget https://github.com/caddyserver/caddy/releases/download/v2.0.0-rc.3/caddy_2.0.0-rc.3_linux_amd64.tar.gz
```

解壓縮。

```bash
tar zxvf caddy_2.0.0-rc.3_linux_amd64.tar.gz
```

將執行檔移到 `/usr/bin/` 目錄。

```bash
sudo mv caddy /usr/bin/
```

查看版本。

```bash
caddy version
v2.0.0-rc.3
```

## 權限設定

建立一個 `caddy` 群組。

```bash
groupadd --system caddy
```

建立一個 `caddy` 使用者。

```bash
useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy
```

- `--home-dir` 參數決定 Caddy 存放重要檔案的位置，包括 SSL 憑證等。

## 日誌

新增 `/var/log/caddy` 資料夾，用來存放各個站點的訪問日誌。

```bash
sudo mkdir /var/log/caddy
```

修改資料夾權限。

```bash
sudo chown -R caddy:caddy /var/log/caddy
```

## Caddyfile

新增 `/etc/caddy` 資料夾，在裡面建立一個 `Caddyfile` 檔：

```txt
domain.com {
    respond "Hello, World!"
}
```

## 系統服務

在 `/etc/systemd/system` 資料夾新增一個 `caddy.service` 檔：

```service
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

載入服務設定檔。

```bash
sudo systemctl daemon-reload
```

將 Caddy 服務設置為自動啟動。

```bash
sudo systemctl enable caddy
```

啟用 Caddy 服務。

```bash
sudo systemctl start caddy
```

檢查 Caddy 服務狀態。

```bash
sudo systemctl status caddy
```

如果有修改設定檔，執行以下指令：

```bash
sudo systemctl reload caddy
```

如果要關閉 Caddy 服務，執行以下指令：

```bash
sudo systemctl stop caddy
```

## 常用指標

### root

指定站點的根目錄。

- v1:

```txt
root /var/www
```

- v2:

```txt
root * /var/www
```

### php_fastcgi

代理對 FastCGI 伺服器的請求，用於服務 PHP 站點。

- v1

```txt
fastcgi / localhost:9000 php
```

- v2

```txt
php_fastcgi localhost:9000
```

### encode gzip

啟用 Gzip 壓縮。

- v1

```txt
gzip
```

- v2

```txt
encode gzip
```

### file_server

允許在指定的路徑內進行目錄瀏覽。

- v1

```txt
browse /subfolder/
```

- v2

```txt
file_server /subfolder/* browse
```

### log

啟用站點的訪問日誌。

- v1:

```txt
log access.log
```

- v2:

```txt
log {
    output file         access.log
    format single_field common_log
}
```

### reverse_proxy

用於反向代理和負載平衡。

- v1:

```txt
proxy / localhost:9005
```

- v2:

```txt
reverse_proxy localhost:9005
```

### tls

用來配置 HTTPS 連線。

```txt
tls email
```

## 範例

### PHP 站點

```txt
service.domain.com {
    root * /var/www/service/public

    php_fastcgi 127.0.0.1:9000

    encode gzip
    file_server

    log {
        output file /var/log/caddy/service_access.log
    }

    tls email@gmail.com
}
```

### 反向代理

```txt
service.domain.com {
    reverse_proxy 127.0.0.1:8080

    log {
        output file /var/log/caddy/service_access.log
    }

    tls email@gmail.com
}
```

## 標準輸出

如果要查看 Caddy 標準輸出，執行以下指令：

```bash
journalctl -u caddy
```

## 憑證

Caddy 的根目錄設在 `/var/lib/caddy/`，則 SSL 憑證的存放位置在以下路徑。

```bash
/var/lib/caddy/.local/share/caddy/certificates
```

如果要強制更新 SSL 憑證，可以將憑證刪除後，再重新啟動 Caddy 服務。

```bash
cd /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory
rm -rf example.com
systemctl restart caddy
```

## 參考資料

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Upgrade Guide](https://caddyserver.com/docs/v2-upgrade)
