---
title: 學習 Kubernetes 容器管理平台（六）：使用 ConfigMap 配置 Redis 資料庫
permalink: 學習-Kubernetes-容器管理平台（六）：使用-ConfigMap-配置-Redis-資料庫
date: 2020-11-04 20:46:36
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- MacOS
- minikube

## 概述

本文使用 ConfigMap 来配置一個 Redis 服務。

## 做法

首先，建立一個 `redis-config` 設定檔：

```ENV
cat <<EOF >./redis-config
maxmemory 2mb
maxmemory-policy allkeys-lru
EOF
```

建立一個 `kustomization.yaml` 檔：

```BASH
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: example-redis-config
  files:
  - redis-config
EOF
```

建立名為 `redis-pod` 的 Pod 定義檔：

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: redis
spec:
  containers:
  - name: redis
    image: redis:5.0.4
    command:
      - redis-server
      - "/redis-master/redis.conf"
    env:
    - name: MASTER
      value: "true"
    ports:
    - containerPort: 6379
    resources:
      limits:
        cpu: "0.1"
    volumeMounts:
    - mountPath: /redis-master-data
      name: data
    - mountPath: /redis-master
      name: config
  volumes:
    - name: data
      emptyDir: {}
    - name: config
      configMap:
        name: example-redis-config
        items:
        - key: redis-config
          path: redis.conf
```

將 Pod 定義檔添加到 `kustomization.yaml` 檔中：

```BASH
cat <<EOF >./kustomization.yaml
resources:
- redis-pod.yaml
EOF
```

現在 `kustomization.yaml` 檔如下：

```YAML
configMapGenerator:
- name: example-redis-config
  files:
  - redis-config
resources:
- redis-pod.yaml
```

創建 Pod 和 ConfigMap 物件：

```BASH
kubectl apply -k .
```

檢查創建的物件：

```BASH
kubectl get -k .
```

輸出如下：

```BASH
NAME                                        DATA   AGE
configmap/example-redis-config-dgh9dg555m   1      9s

NAME        READY   STATUS    RESTARTS   AGE
pod/redis   1/1     Running   0          9s
```

在此範例中，設定卷掛載在 `/redis-master` 資料夾下，它使用 `path` 字段將 `redis-config` 的內容添加到名為 `redis.conf` 檔中。因此，Redis 的配置檔路徑為 `/redis-master/redis.conf`。這是鏡像將在其中查找 `redis-master` 的配置檔的位置。

使用 `kubectl exec` 指令進入 Pod，並運行 `redis-cli` 工具，來驗證配置已正確應用：

```BASH
kubectl exec -it redis -- redis-cli
127.0.0.1:6379> CONFIG GET maxmemory
1) "maxmemory"
2) "2097152"
127.0.0.1:6379> CONFIG GET maxmemory-policy
1) "maxmemory-policy"
2) "allkeys-lru"
```

最後，刪除創建的 Pod。

```BASH
kubectl delete pod redis
```
