---
title: 在 Kubernetes 容器管理平台部署一個基於 Redis 資料庫 的 PHP 簽到簿
permalink: 在-Kubernetes-容器管理平台部署一個基於-Redis-資料庫-的-PHP-簽到簿
date: 2020-11-05 21:15:15
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- MacOS
- minikube

## 概述

目標為部署一個簡單的多層網頁應用程式，由以下部分組成：

- 單實例 Redis 主節點，用來保存留言條目。
- 多個 Redis 副節點，用來讀取資料。
- 多個網頁前端實例。

## 部署 Redis

### 創建 Redis 主節點 Deployment

新增一個 `redis-master-deployment.yaml` 檔，這是 Redis 的主節點的 Deployment 設定檔：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-master
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
      role: master
      tier: backend
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
        role: master
        tier: backend
    spec:
      containers:
      - name: master
        image: redis
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379
```

建立 Deployment。

```BASH
kubectl apply -f redis-master-deployment.yaml
```

檢查 Redis 主節點的 Pod 是否正在運行。

```BASH
kubectl get pods
```

查看 Redis 主節點的 Pod 的日誌。

```BASH
kubectl logs -f <POD_NAME>
```

### 創建 Redis 主節點 Service

新增一個 `redis-master-service.yaml` 檔，這是 Redis 的主節點的 Service 設定檔：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: redis-master
  labels:
    app: redis
    role: master
    tier: backend
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    app: redis
    role: master
    tier: backend
```

建立 Service。

```BASH
kubectl apply -f redis-master-service.yaml
```

檢查 Redis 主節點的 Service 是否正在運行。

```BASH
kubectl get services
```

### 創建 Redis 副節點 Deployment

新增一個 `redis-slave-deployment.yaml` 檔，這是 Redis 的副節點的 Deployment 設定檔：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-slave
  labels:
    app: redis
spec:
  selector:
    matchLabels:
      app: redis
      role: slave
      tier: backend
  replicas: 2
  template:
    metadata:
      labels:
        app: redis
        role: slave
        tier: backend
    spec:
      containers:
      - name: slave
        image: gcr.io/google_samples/gb-redisslave:v3
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 6379
```

建立 Deployment。

```BASH
kubectl apply -f redis-slave-deployment.yaml
```

檢查 Redis 副節點的 Pod 是否正在運行。

```BASH
kubectl get pods
```

### 創建 Redis 副節點 Service

新增一個 `redis-slave-service.yaml` 檔，這是 Redis 的副節點的 Service 設定檔：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: redis-slave
  labels:
    app: redis
    role: slave
    tier: backend
spec:
  ports:
  - port: 6379
  selector:
    app: redis
    role: slave
    tier: backend
```

建立 Service。

```BASH
kubectl apply -f redis-slave-service.yaml
```

檢查 Redis 副節點的 Service 是否正在運行。

```BASH
kubectl get services
```

## 部署應用程式

### 創建 Deployment

新增一個 `frontend-deployment.yaml` 檔，這是應用程式的 Deployment 設定檔：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: guestbook
spec:
  selector:
    matchLabels:
      app: guestbook
      tier: frontend
  replicas: 3
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google-samples/gb-frontend:v4
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 80
```

建立 Deployment。

```BASH
kubectl apply -f frontend-deployment.yaml
```

檢查應用程式的 Pod 是否正在運行。

```BASH
kubectl get pods -l app=guestbook -l tier=frontend
```

### 創建 Service

新增一個 `frontend-service.yaml` 檔，這是應用程式的 Service 設定檔：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  type: NodePort
  ports:
  - port: 80
  selector:
    app: guestbook
    tier: frontend
```

建立 Service。

```BASH
kubectl apply -f frontend-service.yaml
```

檢查應用程式的 Service 是否正在運行。

```BASH
kubectl get services
```

## 訪問應用程式

訪問應用程式。

```BASH
minikube service frontend
```

## 擴展

擴展應用程式 Pod 的數量：

```BASH
kubectl scale deployment frontend --replicas=5
```

查看應用程式 Pod 的數量：

```BASH
kubectl get pods
```

縮小應用程式 Pod 的數量：

```BASH
kubectl scale deployment frontend --replicas=2
```

查看應用程式 Pod 的數量：

```BASH
kubectl get pods
```

## 清理

刪除所有的 Pods 和 Services。

```BASH
kubectl delete deployment -l app=redis
kubectl delete service -l app=redis
kubectl delete deployment -l app=guestbook
kubectl delete service -l app=guestbook
```

確認沒有 Pod 正在運行。

```BASH
kubectl get pods
```

## 程式碼

- [kubernetes-guestbook-example](https://github.com/memochou1993/kubernetes-guestbook-example)
