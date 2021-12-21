---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十五）：認識 Deployment 資源
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（十五）：認識-Deployment-資源
date: 2021-12-21 14:32:59
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

一個 Deployment 為 Pod 和 ReplicaSet 提供宣告式的更新能力。

只要描述 Deployment 中的目標狀態，Deployment Controller 將會以受控速率更改實際狀態，使其變為期望狀態。此外，可以定義 Deployment 以創建新的 ReplicaSet，或刪除現有 Deployment，並通過新的 Deployment 認養該資源。

也就是說，Deployment 會利用 ReplicaSet 進行 Pod 的版本更新，只需要指定期望的版本，它就會負責變成該版本並維持。Deployment 在實務上較常被使用到。

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/deployment/basic.yaml
```

以下是一個描述 Deployment 的 YAML 範例檔，其中 `template` 的部分其實就是 Pod 的配置檔的格式，並透過標籤綁定在一起。

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/deployment/basic.yaml
```

查看此 Deployment 與其他資源的關係。

```BASH
kubectl tree deployment test
NAMESPACE  NAME                           READY  REASON  AGE
default    Deployment/test                -              7h40m
default    └─ReplicaSet/test-5db5984bbf   -              7h40m
default      ├─Pod/test-5db5984bbf-86kh8  True           7h40m
default      ├─Pod/test-5db5984bbf-dfwm2  True           7h40m
default      └─Pod/test-5db5984bbf-tjrs5  True           7h40m
```

### 滾動升級版本

使用 `kubectl rollout status` 指令，查看 Deployment 的更新狀態。

```BASH
kubectl rollout status deployment test
```

結果如下：

```BASH
deployment "test" successfully rolled out
```

更新 Deployment 配置檔，將 `image` 改為其他的映像檔。

```BASH
image: hwchiu/netutils
```

再套用一次配置檔。

```BASH
kubectl apply -f introduction/deployment/basic.yaml
```

查看 Deployment 的更新狀態。

```BASH
kubectl rollout status deployment test
```

結果如下：

```BASH
Waiting for deployment "test" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "test" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "test" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "test" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "test" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "test" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "test" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "test" rollout to finish: 1 old replicas are pending termination...
deployment "test" successfully rolled out
```

再查看一次此 Deployment 與其他資源的關係。

```BASH
kubectl tree deployment test
NAMESPACE  NAME                           READY  REASON  AGE
default    Deployment/test                -              7h57m
default    ├─ReplicaSet/test-5678b9ddb4   -              4m39s
default    │ ├─Pod/test-5678b9ddb4-4b5f6  True           4m39s
default    │ ├─Pod/test-5678b9ddb4-5dl6p  True           81s
default    │ └─Pod/test-5678b9ddb4-67pv9  True           3m10s
default    └─ReplicaSet/test-5db5984bbf   -              7h57m
```

會有一個新的 ReplicaSet 生成，而所有的 Pod 完成更新。

### 滾動降級版本

使用 `kubectl rollout undo` 指令，把 Pod 從新的 ReplicaSet 轉移回舊的 ReplicaSet。

```BASH
kubectl rollout undo deployment test
```

查看此 Deployment 與其他資源的關係。

```BASH
kubectl tree deployment test
NAMESPACE  NAME                           READY  REASON  AGE
default    Deployment/test                -              8h
default    ├─ReplicaSet/test-5678b9ddb4   -              10m
default    └─ReplicaSet/test-5db5984bbf   -              8h
default      ├─Pod/test-5db5984bbf-f5crq  True           2m3s
default      ├─Pod/test-5db5984bbf-ff4px  True           115s
default      └─Pod/test-5db5984bbf-w8d5q  True           2m11s
```

可以看到，所有的 Pod 轉移回到舊的 ReplicaSet 了。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
