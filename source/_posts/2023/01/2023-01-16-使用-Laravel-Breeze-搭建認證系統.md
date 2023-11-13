---
title: 使用 Laravel Breeze 搭建認證系統
date: 2023-01-16 20:15:21
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
composer require laravel/breeze --dev
```

選擇前端框架。

```bash
php artisan breeze:install react --dark
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

前往 <http://localhost:8000/> 瀏覽。

## 參考資料

- [Laravel - Starter Kits](https://laravel.com/docs/9.x/starter-kits)
