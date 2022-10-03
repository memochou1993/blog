---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十七）：認識 StatefulSet 資源
date: 2021-12-22 23:05:04
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

StatefulSet 是用來管理有狀態應用的資源。StatefulSet 用來管理某 Pod 集合的部署和擴縮， 並為這些 Pod 提供持久存儲和持久標識符。

和 Deployment 類似，StatefulSet 管理基於相同容器規格的一組 Pod。但和 Deployment 不同的是，StatefulSet 為他們的每個 Pod 維護了一個「有黏性」的 ID。這些 Pod 是基於相同的規格來創建的，但是不能相互替換；無論怎麼調度，每個 Pod 都有一個永久不變的 ID。

如果希望使用存儲捲為工作負載提供持久存儲，可以使用 StatefulSet 作為解決方案的一部分。

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 StatefulSet 配置檔。

```BASH
cat introduction/sts/basic.yaml
```

以下是一個描述 StatefulSet 的 YAML 範例檔，其中 `template` 的部分其實就是 Pod 的配置檔的格式，並透過標籤綁定在一起。

```YAML
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: test-sts
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  serviceName: "nginx"
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-server
        image: nginx
```

使用配置檔創建 StatefulSet 資源。

```BASH
kubectl apply -f introduction/sts/basic.yaml
```

查看此 StatefulSet 與其他資源的關係。

```BASH
kubectl tree sts test-sts
NAMESPACE  NAME                                      READY  REASON  AGE
default    StatefulSet/test-sts                      -              4m40s
default    ├─ControllerRevision/test-sts-7cbcbccf75  -              4m40s
default    ├─Pod/test-sts-0                          True           4m40s
default    ├─Pod/test-sts-1                          True           4m35s
default    └─Pod/test-sts-2                          True           4m29s
```

### 有序升級版本

使用 `kubectl rollout status` 指令，查看 StatefulSet 的更新狀態。

```BASH
kubectl rollout status sts test-sts
```

結果如下：

```BASH
partitioned roll out complete: 3 new pods have been updated...
```

更新 StatefulSet 配置檔，將 `image` 改為其他的映像檔。

```BASH
image: hwchiu/netutils
```

再套用一次配置檔。

```BASH
kubectl apply -f introduction/sts/basic.yaml
```

查看 StatefulSet 的更新狀態。

```BASH
kubectl rollout status sts test-sts
```

結果如下：

```BASH
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for partitioned roll out to finish: 1 out of 3 new pods have been updated...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for partitioned roll out to finish: 2 out of 3 new pods have been updated...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
partitioned roll out complete: 3 new pods have been updated...
```

使用另一個終端機視窗觀察 Pod 的變化。

```BASH
kubectl get pods -o wide -w
```

可以看到 Pod 的生成順序為：

```BASH
test-sts-0
test-sts-1
test-sts-2
```

### 有序降級版本

使用 `kubectl rollout undo` 指令。

```BASH
kubectl rollout undo sts test-sts
```

查看 StatefulSet 的更新狀態。

```BASH
kubectl rollout status sts test-sts
```

結果如下：

```BASH
Waiting for 1 pods to be ready...
Waiting for partitioned roll out to finish: 1 out of 3 new pods have been updated...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
Waiting for partitioned roll out to finish: 2 out of 3 new pods have been updated...
Waiting for 1 pods to be ready...
Waiting for 1 pods to be ready...
partitioned roll out complete: 3 new pods have been updated...
```

使用另一個終端機視窗觀察 Pod 的變化。

```BASH
kubectl get pods -o wide -w
```

可以看到新的 Pod 的生成順序為：

```BASH
test-sts-2
test-sts-1
test-sts-0
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
