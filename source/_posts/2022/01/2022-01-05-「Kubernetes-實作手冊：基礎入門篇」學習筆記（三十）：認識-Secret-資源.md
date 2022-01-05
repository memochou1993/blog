---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（三十）：認識 Secret 資源
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（三十）：認識-Secret-資源
date: 2022-01-05 15:42:19
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Secret 是一種包含少量敏感訊息例如密碼、令牌或密鑰的物件。使用 Secret 可以不需要將機密資料寫入應用程式的程式碼。

由於創建 Secret 可以獨立於使用它們的 Pod，因此在創建、查看和編輯 Pod 的工作流程中暴露 Secret 的風險較小。Kubernetes 和在叢集中運行的應用程式，也可以對 Secret 採取額外的預防措施，例如避免將敏感訊息寫入非揮發性記憶體。

在 Secret 中，有兩個欄位：

- `data`：以 base64 的格式進行編碼的文字
- `stringData`：未以 base64 的格式進行編碼的文字

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 ConfigMap 配置檔。

```BASH
cat introduction/storage/secret/secret.yaml
```

配置檔如下：

```YAML
apiVersion: v1
kind: Secret
metadata:
  name: secret-test
  namespace: default
data:
  key: eWVzCg==
  version.date: MjAyMAo=
stringData:
  key.new: "yes"
  version.data.new: "2020"
```

使用配置檔創建 Secret 資源。

```BASH
kubectl apply -f introduction/storage/secret/secret.yaml
```

查看 Secret 列表。

```BASH
kubectl get secrets -o yaml
```

為了更好閱讀 Secret 的值，可以安裝名為 `view-secret` 的套件。

```BASH
kubectl krew install view-secret
```

使用 `view-secret` 套件列出所有解碼後的 Secret 值。

```BASH
kubectl view-secret secret-test -a
```

### Volume

查看範例資料夾中的 Deployment 配置檔，這是使用 Volume 的方式使用 Secret。

```BASH
cat introduction/storage/secret/pod-vol.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secret-vol
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
        - name: secret-volume
          mountPath: /tmp/config
      volumes:
      - name: secret-volume
        secret:
          secretName: secret-test
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/secret/pod-vol.yaml
```

進到 Pod 中。

```BASH
kubectl exec -it secret-vol-57fbbbd9f8-dj7v6 -- bash
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

查看範例資料夾中的 Deployment 配置檔，這是使用 Env 的方式使用 Secret。

```BASH
cat introduction/storage/secret/pod-env.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secret-env
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
            secretKeyRef:
              name: secret-test
              key: key.new
        - name: version
          valueFrom:
            secretKeyRef:
              name: secret-test
              key: version.date
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/secret/pod-env.yaml
```

進到 Pod 中。

```BASH
kubectl exec -it secret-env-75d8b6f85b-qgqwb -- bash
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

### 補充

使用 Volume 來存取 ConfigMap 會比使用 Env 好，因為使用 Env 的情況下，容器內的環境變數可以透過節點的 `/proc/$pid/environ` 被存取；而使用 Volume 在預設情況下只有擁有使用 Docker 權限的使用者可以存取，多了一層保護。

## 編碼

使用 `base64` 指令可以為文字進行 base64 格式的編碼。

```BASH
echo "hello" | base64
aGVsbG8K
```

在 `echo` 指令使用 `-n` 參數，避免產生換行符號。

```BASH
echo -n "hello" | base64
aGVsbG8=
```

在 `base64` 指令使用 `-d` 參數，可以進行 base64 格式的解碼。

```BASH
echo -n "aGVsbG8=" | base64 -d
hello
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
