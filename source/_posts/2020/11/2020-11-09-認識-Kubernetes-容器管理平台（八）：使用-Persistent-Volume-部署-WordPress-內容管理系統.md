---
title: 認識 Kubernetes 容器管理平台（八）：使用 Persistent Volume 部署 WordPress 內容管理系統
permalink: 認識-Kubernetes-容器管理平台（八）：使用-Persistent-Volume-部署-WordPress-內容管理系統
date: 2020-11-09 22:32:20
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- macOS
- minikube

## 概述

目標為創建 `PersistentVolumes`（叢集中的一塊儲存區）和 `PersistentVolumeClaims`（使用者對儲存區的請求），以及創建 Secret 生成器、MySQL 資源配置和 WordPress 資源配置。

## 創建資源

建立 `mysql-deployment.yaml` 檔，這是 MySQL 的 Deployment 設定檔：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: mysql
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

- MySQL 容器將 `PersistentVolume` 掛載在 `/var/lib/mysql` 資料夾。

建立 `wordpress-deployment.yaml` 檔，這是 WordPress 的 Deployment 設定檔：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  selector:
    matchLabels:
      app: wordpress
      tier: frontend
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: wordpress:4.8-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: password
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pv-claim
```

- WordPress 容器將 `PersistentVolume` 掛載在 `/var/www/html` 資料夾。

新建 `kustomization.yaml` 檔，添加一個 Secret 生成器，以及 MySQL 和 WordPress 資源配置。

```YAML
secretGenerator:
- name: mysql-pass
  literals:
  - password=MY_PASSWORD
resources:
  - mysql-deployment.yaml
  - wordpress-deployment.yaml
```

- `secretGenerator` 中的 `mysql-pass` 會被 MySQL 容器所使用。

創建所有資源。

```BASH
kubectl apply -k .
```

查看所有 Secrets。

```BASH
kubectl get secrets
```

查看所有 PersistentVolumeClaims。

```BASH
kubectl get pvc
```

查看所有 Pods。

```BASH
kubectl get pods
```

查看所有 Services。

```BASH
kubectl get services
```

## 訪問應用程式

訪問應用程式。

```BASH
minikube service wordpress
```

## 清除資源

清除所有資源。

```BASH
kubectl delete -k .
```
