---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十一）：認識宣告式指令
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（十一）：認識宣告式指令
date: 2021-12-16 23:12:10
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

所謂的宣告式指令（Declarative Commands）指的是，使用者設定期望的狀態，系統執行某些操作來達到期望的狀態。像是：

- kubectl apply：確保一個或多個資源的狀態符合期望。
- kubectl diff：顯示實際資源的狀態與期望的狀態有何不同。

### 指定配置檔

透過 YAML 檔或 JSON 檔來描述要執行操作的資源，並將相關內容直接發送到 API Server。

例如使用 `kubectl apply` 指令，指定一個 YAML 檔，並創建資源。

```BASH
kubectl apply -f introduction/pod/basic.yaml
```

如果配置檔有修改，可以使用 `kubectl diff` 指令，指定一個 YAML 檔，並查看變化。

```BASH
kubectl diff -f introduction/pod/basic.yaml
```

如果修改了配置檔，再執行一次 `kubectl apply` 即可套用變化。

```BASH
kubectl apply -f introduction/pod/basic.yaml
```

宣告式指令的優點是直接對資源進行描述，較容易進行版本控制，較為常用。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
