---
title: 認識 Kubernetes 容器管理平台（五）：使用 Ingress 公開應用程式
permalink: 認識-Kubernetes-容器管理平台（五）：使用-Ingress-公開應用程式
date: 2020-11-03 16:53:06
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes", "其他"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- macOS
- minikube

## 概述

Ingress 是一種 Kubernetes 服務，可以提供負載平衡，並將多個應用程式服務公開給外部使用。

以下是一個將所有流量都發送到同一服務的簡單 Ingress 示意圖：

```BASH
客戶端 -> Ingress-managed 負載平衡器 -> Ingress -> 路由规则 -> Service
```

## 設置

一個最簡單的 Ingress 設定檔如下：

```YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```

## 實作

Ingress 不支援以 `docker` 做為 VM 驅動的網路環境，因此使用 `hyperkit` 做為 minikube 的 VM 驅動。

```BASH
minikube start --vm=true --driver=hyperkit
```

啟用 Ingress 外掛。

```BASH
minikube addons enable ingress
```

確認 Ingress 控制器處於運行狀態。

```BASH
kubectl get pods -n kube-system
```

部署一個名為 `web` 的 Deployment。

```BASH
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
```

將 Deployment 公開。

```BASH
kubectl expose deployment web --type=NodePort --port=8080
```

建立一個 `example-ingress.yaml` 檔，是 Ingress 的設定檔，負責通過 `hellow-world.info` 網域，將服務請求轉發到 `web` 服務。

```YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - host: hello-world.info
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 8080
```

創建 Ingress 資源。

```BASH
kubectl apply -f example-ingress.yaml
```

查看 Ingress 物件的詳細資訊。

```BASH
kubectl get ingress
```

查看 minikube 的 IP 位址。

```BASH
minikube ip
```

修改 `/etc/hosts` 檔，新增一個對應 minikube 的 IP 位址的網域名稱：

```BASH
192.168.64.9 hello-world.info
```

嘗試將請求發送給 `web` 服務。

```BASH
curl hello-world.info
```

輸出：

```BASH
Hello, world!
Version: 1.0.0
Hostname: web-79d88c97d6-bqxgw
```
