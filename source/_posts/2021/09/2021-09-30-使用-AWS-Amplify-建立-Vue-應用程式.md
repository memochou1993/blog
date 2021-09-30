---
title: 使用 AWS Amplify 建立 Vue 應用程式
permalink: 使用-AWS-Amplify-建立-Vue-應用程式
date: 2021-09-30 15:33:21
tags: ["環境部署", "AWS", "Amplify", "Vue"]
categories: ["雲端運算服務", "AWS"]
---

## 建立前端專案

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

## 建立後端專案

安裝 Amplify CLI 指令列工具。

```BASH
npm install -g @aws-amplify/cli
```

使用 AWS Vault 做認證時，需要新增一個 profile 提供 amplify CLI 使用。

```ENV
[profile amplify-Example-PowerUser]
output = json
region = eu-west-1
credential_process = aws-vault exec Example-PowerUser --json
```

在專案根目錄使用 `amplify` 指令建立一個後端應用。

```BASH
aws-vault exec --backend=file Example-PowerUser -- amplify init

? Please choose the profile you want to use
- amplify-Example-PowerUser
```

(TODO)

## 參考資料

- [Amplify Docs - Vue](https://docs.amplify.aws/start/q/integration/vue/)
- [使用 AWS Amplify 建立簡單的 Web 應用程式](https://aws.amazon.com/tw/getting-started/hands-on/build-react-app-amplify-graphql/)
