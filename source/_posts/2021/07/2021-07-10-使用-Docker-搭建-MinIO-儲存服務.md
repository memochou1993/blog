---
title: 使用 Docker 搭建 MinIO 儲存服務
date: 2021-07-10 23:54:20
tags: ["Deployment", "Docker", "MinIO", "Storage Service"]
categories: ["Deployment", "Docker", "Others"]
---

## 建立服務

下載 MinIO 的 `docker-compose.yml` 檔。

```bash
git clone https://github.com/memochou1993/minio-docker-compose
```

複製 `.env.example` 範本到 `.env` 檔：

```bash
cd minio-docker-compose
cp .env.example .env
```

修改預設的帳號及密碼。

```bash
MINIO_ROOT_USER=root
MINIO_ROOT_PASSWORD=password
```

啟動服務。

```bash
docker-compose up -d
```

前往 <http://127.0.0.1:9001> 瀏覽。

## 建立服務帳戶

登入後，在 MinIO 建立一個程式用的服務帳戶，並賦予 `readwrite` 權限。

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
```

建立後，將 `Access Key` 和 `Secret Key` 複製下來提供給應用程式使用。
