---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十七）：認識 DaemonSet 資源
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（十七）：認識-DaemonSet-資源
date: 2021-12-22 22:39:09
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

DaemonSet 確保全部（或者某些）節點上運行某一個 Pod 的副本。當有節點加入叢集時，也會為他們新增一個 Pod。當有節點從叢集移除時，這些 Pod 也會被回收。刪除 DaemonSet 將會刪除它創建的所有 Pod。

使用情境如：

- 在每個節點上運行儲存空間守護行程
- 在每個節點上運行日誌收集守護行程
- 在每個節點上運行監控守護行程

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 DaemonSet 配置檔。

```BASH
cat introduction/ds/basic.yaml
```

以下是一個描述 DaemonSet 的 YAML 範例檔，其中 `template` 的部分其實就是 Pod 的配置檔的格式，並透過標籤綁定在一起。

```YAML
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: test-ds
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: nginx-server
        image: nginx
```

- 設定為容忍主節點的污點。

使用配置檔創建 DaemonSet 資源。

```BASH
kubectl apply -f introduction/ds/basic.yaml
```

查看此 DaemonSet 與其他資源的關係。

```BASH
kubectl tree ds test-ds
NAMESPACE  NAME                                     READY  REASON  AGE
default    DaemonSet/test-ds                        -              2m43s
default    ├─ControllerRevision/test-ds-6d77db79c6  -              2m43s
default    ├─Pod/test-ds-5w6qj                      True           2m43s
default    ├─Pod/test-ds-f7th7                      True           2m43s
default    └─Pod/test-ds-q4g2n                      True           2m43s
```

總結來說，DaemonSet 會使用在每個節點上都剛好只需要運行某一個應用程式時使用。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
