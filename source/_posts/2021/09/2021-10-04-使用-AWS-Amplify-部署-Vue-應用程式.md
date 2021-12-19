---
title: 使用 AWS Amplify 部署 Vue 應用程式
permalink: 使用-AWS-Amplify-部署-Vue-應用程式
date: 2021-10-04 15:33:21
tags: ["環境部署", "AWS", "Amplify", "Vue"]
categories: ["程式設計", "JavaScript", "環境部署"]
---

## 建立專案

建立專案。

```BASH
npm install -g @vue/cli
vue create amplifyapp
```

啟動專案。

```BASH
cd amplifyapp
npm run serve
```

## 部署

1. 進到 [Amplify](https://ap-northeast-2.console.aws.amazon.com/amplify/home) 首頁。
2. 點選 Deliver 的「Get started」按鈕。
3. 選擇儲存庫。
4. 指定要連結的專案和分支。
5. 最後點選「Save and deploy」按鈕。

## 環境變數

如果要配置環境變數，可以點選「Environment variables」頁籤，點選「Manage variables」按鈕，並新增環境變數。

為了讓環境變數生效，需要點選「Build settings」頁籤，將 `amplify.yml` 檔編輯如下：

```YAML
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
    build:
      commands:
        - echo "VUE_APP_API_HOST=$VUE_APP_API_HOST" >> .env 
        - npm run build
  artifacts:
    baseDirectory: dist
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
```

## 參考資料

- [Amplify Docs - Vue](https://docs.amplify.aws/start/q/integration/vue/)
- [使用 AWS Amplify 建立簡單的 Web 應用程式](https://aws.amazon.com/tw/getting-started/hands-on/build-react-app-amplify-graphql/)
