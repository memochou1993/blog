---
title: 使用 Laravel Jetstream 搭建認證系統
date: 2023-01-18 00:32:02
tags: ["Programming", "PHP", "Laravel"]
categories: ["Programming", "PHP", "Laravel"]
---

## 建立專案

建立專案。

```bash
laravel new example
cd example
```

## 安裝套件

安裝套件。

```bash
composer require laravel/jetstream
```

選擇前端框架。

```bash
php artisan jetstream:install inertia --teams --dark
```

執行遷移。

```bash
php artisan migrate
```

安裝前端依賴套件。

```bash
npm install
```

編譯前端資源。

```bash
npm run dev
```

啟動本地伺服器。

```bash
artisan serve
```

前往 <http://localhost:8000> 瀏覽。

## 參考資料

- [Laravel Jetstream](https://jetstream.laravel.com/)
