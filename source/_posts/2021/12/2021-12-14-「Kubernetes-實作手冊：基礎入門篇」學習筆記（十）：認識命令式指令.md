---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十）：認識命令式指令
date: 2021-12-14 16:15:23
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

所謂的命令式指令（Imperative Commands）指的是，kubectl 選定一個動作並執行，像是：

- kubectl run：運行一個資源。
- kubectl create：創建一個資源。
- kubectl delete：刪除一個資源。
- kubectl label：幫節點或 Pod 新增標籤。
- kubectl scale：擴縮 Pod 數量。

命令式指令的優點是簡單且易學，缺點是操作沒有紀錄、沒有樣板可以參考。

### 指定配置檔

也可以透過 YAML 檔或 JSON 檔來描述要執行操作的資源，並將相關內容直接發送到 API Server。

例如使用 `kubectl create` 指令，指定一個 YAML 檔，並創建資源。

```bash
kubectl create -f introduction/pod/basic.yaml
```

例如使用 `kubectl delete` 指令，指定一個 YAML 檔，並刪除資源。

```bash
kubectl delete -f introduction/pod/basic.yaml
```

以下是一個描述 Pod 的 YAML 範例檔，詳細的欄位需要參考官方文件。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
```

以下透過指定配置檔的方式，創建一個 Pod。

```bash
kubectl create -f introduction/pod/basic.yaml
```

使用 `kubectl edit` 指令，可以編輯一個 Pod。但是能修改的欄位有限，例如 image 名稱可以被修改。

```bash
kubectl edit pod myapp-pod
```

使用 `kubectl replace` 指令，可以進行覆蓋。但是使用上並不方便，因為需要先輸出由 Kubernetes 補齊的完整欄位的 YAML 檔，修改後才能再進行覆蓋，否則會缺少一些重要欄位而覆蓋失敗。例如：

```bash
kubectl get pod myapp-pod -o yaml > new.yaml
vim new.yaml
kubectl replace -f new.yaml
```

最後，指定配置檔並刪除此 Pod。

```bash
kubectl delete -f introduction/pod/basic.yaml
```

搭配配置檔的優點是，配置檔可以被加進版本控制，可以有樣板參考，例如 YAML 檔；缺點是配置檔的欄位相當繁雜，而且修改困難。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
