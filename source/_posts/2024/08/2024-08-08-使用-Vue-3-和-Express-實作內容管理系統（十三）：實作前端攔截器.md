---
title: 使用 Vue 3 和 Express 實作內容管理系統（十三）：實作前端攔截器
date: 2024-08-08 20:36:34
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node.js", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 開啟專案

開啟前端專案。

```bash
cd simple-cms-ui
code .
```

## 實作攔截器

修改 `src/firebase/auth.js` 檔，添加取得 ID Token 的方法。

```js
// ...

export const getIdToken = () => auth.currentUser.getIdToken();
```

修改 `src/api/customer.js` 檔，添加請求和響應攔截器。

```js
import { getIdToken } from '@/firebase/auth';
import { Customer } from '@/models';
import router from '@/router';
import axios from 'axios';

const { VITE_API_URL } = import.meta.env;

const client = axios.create({
  baseURL: VITE_API_URL,
});

client.interceptors.request.use(async (config) => {
  const token = await getIdToken();
  config.headers.Authorization = `Bearer ${token}`;
  return config;
});

client.interceptors.response.use((response) => {
  return response;
}, (error) => {
  if (error.response.status === 401) {
    router.push({ name: 'sign-out' });
  }
  return Promise.reject(error);
});
```

提交修改。

```bash
git add .
git commit -m "Add interceptors"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
