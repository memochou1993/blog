---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（卅一）：認識 HostPath 儲存卷類型
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（卅一）：認識-HostPath-儲存卷類型
date: 2022-01-06 22:51:17
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

HostPath 儲存卷能夠將主機節點檔案系統上的檔案或目錄掛載到 Pod 當中。

HostPath 儲存卷存在許多安全風險，應盡可能避免使用 HostPath。當必須使用時，它的範圍應僅限於所需的檔案或目錄，並以唯讀方式掛載。

比較常見的應用場景是搭配 DaemonSet 在每個節點上安裝資料時使用。

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

### Directory

查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/storage/hostpath/pod-dir.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostpath-dir
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
        volumeMounts:
        - mountPath: /test
          name: test-hostpath
      volumes:
      - name: test-hostpath
        hostPath:
          path: /tmp
          type: Directory
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/hostpath/pod-dir.yaml
```

查看 Pod 所在的節點位置。

```BASH
kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
hostpath-dir-66f78996cb-8rx4c   1/1     Running   0          2m4s   10.244.1.3   kind-worker    <none>           <none>
```

進入節點。

```BASH
docker exec -it kind-worker bash
cd tmp
```

使用另一個終端機視窗進入 Pod。

```BASH
kubectl exec -it hostpath-dir-66f78996cb-8rx4c -- bash
cd test
```

在節點的 `tmp` 資料夾中新增檔案，而 Pod 的 `test` 資料夾也會出現相同檔案。

```BASH
touch hello
echo "world" >> hello
```

但是如果 Pod 因為某些原因轉移到其他節點，那 Pod 只會和當前節點同步，而不是原來的節點。

### File

查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/storage/hostpath/pod-file.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostpath-file
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
        volumeMounts:
        - mountPath: /my-data
          name: test-hostpath
      volumes:
      - name: test-hostpath
        hostPath:
          path: /tmp/data
          type: FileOrCreate
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/hostpath/pod-file.yaml
```

查看 Pod 所在的節點位置。

```BASH
kubectl get pods -o wide
NAME                            READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
hostpath-file-9544994db-rdfhg   1/1     Running   0          66s    10.244.2.3   kind-worker2   <none>           <none>
```

進入節點。

```BASH
docker exec -it kind-worker2 bash
cat tmp/data
```

使用另一個終端機視窗進入 Pod。

```BASH
kubectl exec -it hostpath-file-9544994db-rdfhg -- bash
cat my-data
```

在節點中的檔案寫入內容，而 Pod 的檔案也會跟著同步。

```BASH
echo "test" >> my-data
```

同樣的，如果 Pod 因為某些原因轉移到其他節點，那 Pod 只會和當前節點同步，而不是原來的節點。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
