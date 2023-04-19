---
title: 使用 AWS Amplify 服務部署 Vue 應用程式
date: 2021-10-04 15:33:21
tags: ["環境部署", "AWS", "Amplify", "Vue"]
categories: ["程式設計", "JavaScript", "環境部署"]
---

## 建立專案

建立專案。

```bash
npm install -g @vue/cli
vue create amplifyapp
```

## 部署

1. 進到 [Amplify](https://ap-northeast-2.console.aws.amazon.com/amplify/home) 首頁。
2. 點選 Deliver 的「Get started」按鈕。
3. 選擇儲存庫。
4. 指定要連結的專案和分支。
5. 最後點選「Save and deploy」按鈕。

## 修改配置檔案

點選「Build settings」頁籤，將 `amplify.yml` 檔編輯如下：

```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
    build:
      commands:
        - echo "VUE_APP_API_URL=$VUE_APP_API_URL" >> .env 
        - npm run build
  artifacts:
    baseDirectory: dist
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
```

## 路由

如果使用 History 模式，可以調整重寫和重新引導設定如下：

```bash
來源地址
/<*>

目標地址
/index.html

類型
404 (重新寫入)
```

```bash
來源地址
</^[^.]+$|\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|ttf|map|json)$)([^.]+$)/>

目標地址
/index.html

類型
200 (重新寫入)
```

## 參考資料

- [Amplify Docs - Vue](https://docs.amplify.aws/start/q/integration/vue/)
- [使用 AWS Amplify 建立簡單的 Web 應用程式](https://aws.amazon.com/tw/getting-started/hands-on/build-react-app-amplify-graphql/)
