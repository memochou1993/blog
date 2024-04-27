---
title: 將映像檔部署至 Amazon ECR 私有儲存庫
date: 2022-03-18 15:42:05
tags: ["Deployment", "AWS", "ECR"]
categories: ["Cloud Computing Service", "AWS"]
---

## 前置作業

進到 [Amazon ECR](https://ap-northeast-1.console.aws.amazon.com/ecr) 創建一個儲存庫，以下使用 `example` 儲存庫為例。

## 做法

使用 `aws-vault` 執行命令，登入指定叢集，以 `playground` 叢集為例。

```bash
aws-vault exec --backend=file playground -- aws sso login
```

使用 `aws-vault` 執行命令，並使用 `aws ecr` 命令，將 Docker 登入至指定的私有儲存庫。

```bash
aws-vault exec your-profile -- aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com
```

為專案建立 `example` 映像檔。

```bash
docker build -t example .
```

為映像檔建立標記。

```bash
docker tag example:latest xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/example:latest
```

將 `example` 映像檔推送至 `example` 私有儲存庫。

```bash
docker push xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/example:latest
```
