---
title: 使用 AWS Amplify 服務部署 Nuxt 應用程式
permalink: 使用-AWS-Amplify-服務部署-Nuxt-應用程式
date: 2022-07-14 00:45:38
tags: ["環境部署", "AWS", "Amplify", "Vue", "Nuxt"]
categories: ["程式設計", "JavaScript", "環境部署"]
---

## 建立專案

建立專案。

```BASH
npx create-nuxt-app amplifyapp
```

## 部署

1. 進到 [Amplify](https://ap-northeast-2.console.aws.amazon.com/amplify/home) 首頁。
2. 點選 Deliver 的「Get started」按鈕。
3. 選擇儲存庫。
4. 指定要連結的專案和分支。
5. 最後點選「Save and deploy」按鈕。

## 修改配置檔案

點選「Build settings」頁籤，將 `amplify.yml` 檔編輯如下：

```YAML
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
    build:
      commands:
        - echo "API_URL=$API_URL" >> .env 
        - npm run generate
  artifacts:
    baseDirectory: dist
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
```

## 參考資料

- [Amplify Docs - Nuxt](https://docs.amplify.aws/guides/hosting/nuxt/q/platform/js/)
