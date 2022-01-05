---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿九）：認識 ConfigMap 資源
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（廿九）：認識-ConfigMap-資源
date: 2022-01-04 14:50:56
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

ConfigMap 是 Kubernetes 的一種 API 物件，用來將非機密性的資料保存到鍵值對中。使用時，Pod 可以將其用做環境變數、命令行參數，或者 Volume 中的配置檔案。

ConfigMap 將環境配置訊息和 Container 解耦，以便於應用配置的修改。

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 ConfigMap 配置檔。

```BASH
cat introduction/storage/configmap/conf.yaml
```

配置檔如下：

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-test
  namespace: default
data:
  key: value
  version.date: "202020202"
  yaml.config: |
    name: hwchiu
    image: hwchiu/netutils
  json.data: |
    {
      "key": {
         "storage": "yes"
      }
    }
```

使用配置檔創建 ConfigMap 資源。

```BASH
kubectl apply -f introduction/storage/configmap/conf.yaml
```

查看 ConfigMap 列表。

```BASH
kubectl get cm
NAME          DATA   AGE
config-test   4      8s
```

檢查一下名為 `config-test` 的 ConfigMap。

```BASH
kubectl describe cm config-test
```

### Volume

查看範例資料夾中的 Deployment 配置檔，這是使用 Volume 的方式使用 ConfigMap。

```BASH
cat introduction/storage/configmap/pod-vol.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-vol
spec:
  replicas: 1
  selector:
    matchLabels:
      app: debug-vol
  template:
    metadata:
      labels:
        app: debug-vol
    spec:
      containers:
      - name: debug-server
        image: hwchiu/netutils
        volumeMounts:
        - name: config-volume
          mountPath: /tmp/config
      volumes:
      - name: config-volume
        configMap:
          name: config-test
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/configmap/pod-vol.yaml
```

進到 Pod 中。

```BASH
kubectl exec -it config-vol-5455c65b48-fg4kc -- bash
```

列出所有的 key 檔案。

```BASH
ls /tmp/config/
key  key.new  version.data.new  version.date
```

印出其中一個檔案。

```BASH
cat /tmp/config/version.date
202020202
```

### Env

查看範例資料夾中的 Pod 配置檔，這是使用 Env 的方式使用 ConfigMap。

```BASH
cat introduction/storage/configmap/pod-env.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-env
spec:
  replicas: 1
  selector:
    matchLabels:
      app: debug-env
  template:
    metadata:
      labels:
        app: debug-env
    spec:
      containers:
      - name: debug-server
        image: hwchiu/netutils
        env:
        - name: test_key
          valueFrom:
            configMapKeyRef:
              name: config-test
              key: key
        - name: version
          valueFrom:
            configMapKeyRef:
              name: config-test
              key: version.date
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/configmap/pod-env.yaml
```

進到 Pod 中。

```BASH
kubectl exec -it config-env-7468975c6b-tshz2 -- bash
```

列出所有的環境變數。

```BASH
env
```

印出其中一個環境變數。

```BASH
env | grep -i version
version=202020202
```

### 自動更新

進到名為 `config-vol` 的 Pod 中。

```BASH
kubectl exec -it config-vol-5455c65b48-fg4kc -- bash
```

先使用 `watch` 指令監聽 `yaml.config` 檔。

```BASH
watch cat /tmp/config/yaml.config
```

在另一個終端機視窗，將 `conf.yaml` 檔修改如下：

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-test
  namespace: default
data:
  key: value
  version.date: "202020202"
  yaml.config: |
    foo: bar
  json.data: |
    {
      "key": {
         "storage": "yes"
      }
    }
```

再套用一次 ConfigMap 資源。

```BASH
kubectl apply -f introduction/storage/configmap/conf.yaml
```

過一陣子，`yaml.config` 檔的內容更新如下：

```BASH
Every 2.0s: cat /tmp/config/yaml.config                                                                                Tue Jan  4 08:01:22 2022

foo: bar
```

至於容器中的應用程式是如何知道 ConfigMap 更新，需要透過其他方式去實現，例如使用 inotify 的方式去監聽特定檔案系統是否有檔案變動，來達到自動重載的功能。

### 補充

使用 Volume 來存取 ConfigMap 會比使用 Env 好，因為使用 Env 的情況下，容器內的環境變數可以透過節點的 `/proc/$pid/environ` 被存取；而使用 Volume 在預設情況下只有擁有使用 Docker 權限的使用者可以存取，多了一層保護。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
