---
title: 使用 Docker 搭建 Harbor 映像檔儲存庫
date: 2020-04-20 22:08:26
tags: ["環境部署", "Docker", "Harbor", "Linux", "Ubuntu"]
categories: ["環境部署", "Docker", "其他"]
---

## 環境

- Ubuntu 18.04.1 LTS
- Docker 18.09.1
- docker-compose 1.23.2
- Caddy 2

## 下載

下載 Harbor 的[最新版本](https://github.com/caddyserver/caddy/releases)。

```bash
wget https://github.com/goharbor/harbor/releases/download/v1.10.2/harbor-offline-installer-v1.10.2.tgz
```

解壓縮。

```bash
tar zxvf harbor-offline-installer-v1.10.2.tgz
```

進到 Harbor 目錄。

```bash
cd harbor
```

## 憑證設定

建立一個資料夾，提供 Harbor 和 Docker 存取憑證。

```bash
mkdir -p /data/cert/
```

進到 `/data/cert/` 目錄。

```bash
cd /data/cert/
```

建立一個 CA (Certification Authority) 憑證私鑰。

```bash
openssl genrsa -out ca.key 4096
```

建立一個 `.rnd` 亂數種子。

```bash
openssl rand -writerand /root/.rnd
```

建立一個 CA 憑證。

```bash
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=TW/ST=Taiwan/L=Taipei/O=Epoch/OU=Personal/CN=yourdomain.com" \
 -key ca.key \
 -out ca.crt
```

- `-subj` 參數填入個人資訊。

將伺服器憑證（例如 Caddy 產生的憑證和金鑰）複製到指定目錄。

```bash
cp /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/yourdomain.com/yourdomain.com.crt /data/cert/yourdomain.com.crt
cp /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/yourdomain.com/yourdomain.com.key /data/cert/yourdomain.com.key
```

轉換憑證格式以供 Docker 使用。

```bash
openssl x509 -inform PEM -in yourdomain.com.crt -out yourdomain.com.cert
```

建立一個 Docker 的憑證目錄。

```bash
mkdir -p /etc/docker/certs.d/yourdomain.com
```

將 CA 憑證、伺服器憑證和金鑰複製到 Docker 的憑證目錄。

```bash
cp /data/cert/yourdomain.com.cert /etc/docker/certs.d/yourdomain.com/
cp /data/cert/yourdomain.com.key /etc/docker/certs.d/yourdomain.com/
cp /data/cert/ca.crt /etc/docker/certs.d/yourdomain.com/
```

重新啟動 Docker 服務。

```bash
systemctl restart docker
```

以下是 Docker 憑證目錄的資料夾結構：

```bash
/etc/docker/certs.d/
    └── yourdomain.com:port
       ├── yourdomain.com.cert  <-- Server certificate signed by CA
       ├── yourdomain.com.key   <-- Server key signed by CA
       └── ca.crt               <-- Certificate authority that signed the registry certificate
```

## 修改設定

進到 Harbor 目錄。

```bash
cd harbor
```

修改 `harbor.yml` 設定檔：

```yaml
hostname: yourdomain.com
http:
  port: 80 # HTTP 埠號
https:
  port: 443 # HTTPS 埠號
  certificate: /data/cert/yourdomain.com.crt # 伺服器憑證
  private_key: /data/cert/yourdomain.com.key # 伺服器憑證金鑰
database:
  password: secret # 資料庫密碼
```

## 安裝

執行預備腳本，將產生重要檔案在 `/data` 目錄。

```bash
sudo ./prepare
```

執行安裝腳本，啟動 Harbor 服務。

```bash
sudo ./install.sh
```

停止 Harbor 服務。

```bash
docker-compose down
```

啟動 Harbor 服務。

```bash
docker-compose up -d
```

## 認證

初始帳號及密碼如下：

- username: admin
- password: Harbor12345

使用圖形化介面，前往 <https://yourdomain.com> 瀏覽。

使用 `docker` 指令登入：

```bash
docker login yourdomain.com
```

使用 `docker` 指令登出：

```bash
docker logout yourdomain.com
```

## 參考資料

- [Harbor](https://goharbor.io/docs/1.10/install-config/)
