---
title: 使用 Docker 搭建 GitLab 程式碼管理平台
date: 2019-02-08 20:43:53
tags: ["Deployment", "Docker", "Linux", "Ubuntu", "GitLab"]
categories: ["Deployment", "Docker", "Others"]
---

## 環境

- Ubuntu 18.04.1 LTS
- Docker 18.09.1
- docker-compose 1.23.2

## 安裝

在 `/home/gitlab` 資料夾新增 `docker-compose.yml` 檔：

```yaml
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.xxx.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://gitlab.example.com:9090'
      gitlab_rails['gitlab_shell_ssh_port'] = 2224
  ports:
    - '9090:9090'
    - '2224:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```

- 將參數 `hostname` 改為主機的網域名稱。

## 設定 DNS

新增子網域：gitlab.xxx.com，並指向主機的 IP。

## 設定 Nginx 反向代理

在 `/etc/nginx/sites-available` 資料夾新增 `gitlab.xxx.com.conf` 檔：

```conf
server {
  listen       80;
  server_name  gitlab.xxx.com;
  error_log /var/log/nginx/gitlab.access.log;
  location / {
    proxy_pass http://127.0.0.1:9090;
  }
}
```

建立軟連結。

```bash
sudo ln -s /etc/nginx/sites-available/gitlab.xxx.com.conf /etc/nginx/sites-enabled/gitlab.xxx.com.conf
```

重啟 Nginx 服務。

```bash
sudo nginx -s reload
```

## 啟動

啟動 GitLab 服務。

```bash
docker-compose up -d gitlab
```

## 瀏覽網頁

前往 <http://gitlab.xxx.com> 瀏覽。

## 補充

使用 GitLab 服務，主機至少要有 2GB 的記憶體空間。

## 參考資料

- [Install GitLab using docker-compose](https://docs.gitlab.com/omnibus/docker/#install-gitlab-using-docker-compose)
