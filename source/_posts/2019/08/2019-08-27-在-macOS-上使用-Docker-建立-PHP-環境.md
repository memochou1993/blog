---
title: 在 macOS 上使用 Docker 建立 PHP 環境
date: 2019-08-27 21:02:50
tags: ["Deployment", "Docker", "PHP", "Nginx"]
categories: ["Programming", "PHP", "Deployment"]
---

## 步驟

建立專案。

```bash
cd ~/Projects
laravel new laravel
```

拉取 `richarvey/nginx-php-fpm` 映像檔。

```bash
docker pull richarvey/nginx-php-fpm:latest
```

啟動容器。

```bash
docker run -d --name laravel --restart=always -p 8081:80 -v ~/Projects/laravel:/var/www/html richarvey/nginx-php-fpm
```

- 參數 `--name` 為容器名稱。
- 參數 `--restart` 為自動重新啟動容器。
- 參數 `-p` 為對外與對內的埠號。
- 參數 `-v` 為對外與對內的映射目錄。

進入容器。

```bash
docker exec -it laravel bash
```

- 參數 `-i` 會確保 STDIN 持續開啟。
- 參數 `-t` 會分配一個虛擬終端。

在容器中修改 Nginx 設定。

```bash
vi /etc/nginx/sites-available/default.conf
```

修改 `default.conf` 檔的 `root` 參數。

```env
root /var/www/html/public;
```

重新啟動 Nginx 服務。

```bash
nginx -s reload
```

## 瀏覽網頁

前往 <http://localhost:8081> 瀏覽。
