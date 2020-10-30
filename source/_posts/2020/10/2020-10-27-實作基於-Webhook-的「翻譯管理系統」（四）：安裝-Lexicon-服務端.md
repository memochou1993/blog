---
title: 實作基於 Webhook 的「翻譯管理系統」（四）：安裝 Lexicon 服務端
permalink: 實作基於-Webhook-的「翻譯管理系統」（四）：安裝-Lexicon-服務端
date: 2020-10-27 15:20:30
tags: ["程式設計", "PHP", "Laravel", "Localization", "Lexicon"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

本文介紹如何安裝 Lexicon 服務端，提供使用者線上編輯翻譯內容，並透過 Webhook 主動通知客戶端獲取語系資源，更新專案的語系檔。

## 環境

- Ubuntu 18.04.1 LTS
- PHP 7.4
- Laradock

## 目錄架構

Lexicon 服務端由後端 Laravel 專案以及前端 Vue 專案組成，前端專案以子模組的形式置於 `resources/js` 資料夾中。

```ENV
|- lexicon-server/
    |- resouces/
        |- js/ (lexicon-client)
            |- .env.local
    |- .env
```

## 下載

將專案連同子模組從遠端一起下載下來。

```BASH
git clone --recursive git@github.com:memochou1993/lexicon-server.git
```

## 後端專案

### 安裝相依套件

首先使用 Composer 安裝後端專案的相依套件。

```BASH
composer install
```

### 設置環境變數

複製 `.env.example` 範本。

```BASH
cp .env.example .env
```

修改 `.env` 檔中 MySQL 和 Redis 的連線設定。

```ENV
DB_CONNECTION=mysql
DB_HOST=<YOUR_DB_HOST>
DB_PORT=3306
DB_DATABASE=lexicon
DB_USERNAME=<YOUR_DB_USERNAME>
DB_PASSWORD=<YOUR_DB_PASSWORD>

REDIS_HOST=<YOUR_REDIS_HOST>
REDIS_PASSWORD=null
REDIS_PORT=6379
```

修改 `.env` 檔中的 `CACHE_DRIVER` 參數為 `redis`。

```ENV
CACHE_DRIVER=redis
```

修改 `.env` 檔中的 `LEXICON_DEMO_HOOK_URL` 參數為客戶端的 Webhook 網址。

```ENV
LEXICON_DEMO_HOOK_URL=https://lexicon-demo.epoch.tw/api/lexicon
```

生成 `APP_KEY` 環境變數。

```BASH
php artisan key:gen
```

### 執行指令

執行 Lexicon 初始化指令，建立一個管理者帳號。

```BASH
php artisan lexicon:init
```

執行 Lexicon 展示指令，建立一些示範資料。

```BASH
php artisan lexicon:demo
```

Lexicon 展示指令會生成 2 個令牌：

```BASH
API Token: <API_TOKEN>
Personal Access Token: <PERSONAL_ACCESS_TOKEN>
```

- `API Token` 是客戶端在向服務端獲取語系資源時的金鑰。
- `Personal Access Token` 是前端專案展示用的使用者令牌。

## 前端專案

進到前端專案。

```BASH
cd resources/js
```

### 安裝相依套件

使用 Yarn 安裝前端專案的相依套件。

```BASH
yarn install
```

### 設置環境變數

複製 `.env.local.example` 範本。

```BASH
cp .env.local.example .env.production.local
```

修改 `.env.production.local` 檔。

```ENV
VUE_APP_API_URL=https://lexicon.epoch.tw/api
VUE_APP_API_DEMO_TOKEN=<PERSONAL_ACCESS_TOKEN>
```

- `VUE_APP_API_URL` 參數為後端專案的 API 網址。
- `VUE_APP_API_DEMO_TOKEN` 參數為 Lexicon 展示指令所生成的使用者令牌。

### 執行指令

使用 Yarn 執行編譯。

```BASH
yarn build
```

## 線上演示

前往：[Lexicon](https://lexicon.epoch.tw)

## 程式碼

- [lexicon-server](https://github.com/memochou1993/lexicon-server)
- [lexicon-client](https://github.com/memochou1993/lexicon-client)
