---
title: 在 Ubuntu 上安裝 Caddy 1.0 網頁伺服器
permalink: 在-Ubuntu-上安裝-Caddy-1-0-網頁伺服器
date: 2020-02-04 01:30:53
tags: ["環境部署", "網頁伺服器", "Caddy", "Linux", "Ubuntu"]
categories: ["環境部署", "網頁伺服器"]
---

## 做法

下載 Caddy。

```BASH
curl https://getcaddy.com | bash -s personal
```

查看版本。

```BASH
caddy --version
```

修改 Caddy 執行檔的權限：

```BASH
sudo chown root:root /usr/local/bin/caddy
sudo chmod 755 /usr/local/bin/caddy
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy
```

新增 `/etc/caddy` 資料夾，以放置 `Caddyfile` 檔，並修改資料夾權限：

```BASH
sudo mkdir /etc/caddy
sudo chown -R root:root /etc/caddy
```

新增 `/etc/ssl/caddy` 資料夾，以放置 SSL 證書，並修改資料夾權限：

```BASH
sudo mkdir /etc/ssl/caddy
sudo chown -R root:www-data /etc/ssl/caddy
sudo chmod 0770 /etc/ssl/caddy
```

新增 `/var/log/caddy` 資料夾，以放置日誌，並修改資料夾權限：

```BASH
sudo mkdir /var/log/caddy
sudo chown -R www-data:www-data /var/log/caddy
```

在 `/etc/caddy/` 資料夾新增 `Caddyfile` 檔，例如：

```ENV
example.com {
    root /var/www/example

    log /var/log/caddy/access.log
    errors /var/log/caddy/error.log

    tls email@gmail.com
}
```

修改 `Caddyfile` 檔的權限：

```BASH
sudo chown root:root /etc/caddy/Caddyfile
sudo chmod 644 /etc/caddy/Caddyfile
```

新增 `/var/www` 資料夾，以放置專案，並修改資料夾權限。

```BASH
sudo mkdir /var/www
sudo chown www-data:www-data /var/www
sudo chmod 555 /var/www
```

下載 Caddy 的 systemd 設定檔，並修改檔案權限。

```BASH
wget https://raw.githubusercontent.com/caddyserver/caddy/master/dist/init/linux-systemd/caddy.service
sudo mv caddy.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/caddy.service
```

載入服務設定檔。

```BASH
sudo systemctl daemon-reload
```

啟動 Caddy 服務

```BASH
sudo systemctl start caddy.service
```

將 Caddy 服務設置為自動啟動。

```BASH
sudo systemctl enable caddy.service
```

檢查 Caddy 服務狀態。

```BASH
sudo systemctl status caddy.service
```

## 參考資料

- [Caddy Documentation](https://caddyserver.com/docs/)
- [systemd Service Unit for Caddy](https://github.com/caddyserver/caddy/tree/master/dist/init/linux-systemd)
