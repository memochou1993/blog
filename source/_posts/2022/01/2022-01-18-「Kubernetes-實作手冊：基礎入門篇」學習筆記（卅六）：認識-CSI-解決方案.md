---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（卅六）：認識 CSI 解決方案
date: 2022-01-18 15:43:42
tags: ["Deployment", "Kubernetes", "Docker"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Kubernetes CSI（Container Storage Interface）是用於將儲存系統與 Kubernetes 這類容器管理系統接觸的標準介面。

## 實作

以下使用 kind 的環境，並安裝好 NFS 伺服器。

```bash
cd vagrant/kind
vagrant ssh
```

使用配置檔創建 NFS 的 CSI 解決方案。

```bash
kubectl apply -f introduction/storage/csi/csi-nodeplugin-rbac.yaml
kubectl apply -f introduction/storage/csi/csi-nodeplugin-nfsplugin.yaml
kubectl apply -f introduction/storage/csi/csi-nfs-driverinfo.yaml
```

取得 Pod 列表。

```bash
kubectl get pods
```

觀察所有的 CSI Driver 資源。

```bash
kubectl describe csidrivers
```

結果如下：

```yaml
Name:         nfs.csi.k8s.io
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  storage.k8s.io/v1beta1
Kind:         CSIDriver
Metadata:
  Creation Timestamp:  2022-01-18T08:07:06Z
  Resource Version:    1857
  Self Link:           /apis/storage.k8s.io/v1beta1/csidrivers/nfs.csi.k8s.io
  UID:                 17765c7a-5482-4f83-9c31-3215e413e1c3
Spec:
  Attach Required:    false
  Pod Info On Mount:  true
  Volume Lifecycle Modes:
    Persistent
Events:  <none>
```

使用 `ifconfig` 指令查詢虛擬機的 IP 位址。

```bash
ifconfig
```

查看範例資料夾中的 Pod 配置檔。

```bash
cat introduction/storage/csi/deploy.yaml
```

配置檔如下，將 NFS Server 的 IP 位址修改為虛擬機的 IP 位址：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-nfsplugin
  labels:
    name: data-nfsplugin
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 100Gi
  csi:
    driver: nfs.csi.k8s.io
    volumeHandle: data-id
    volumeAttributes:
      server: 172.18.0.1
      share: /nfsshare
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-nfsplugin
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 100Gi
  selector:
    matchExpressions:
    - key: name
      operator: In
      values: ["data-nfsplugin"]
---
apiVersion: v1
kind: Pod
metadata:
  name: debug-server
spec:
  containers:
  - image: hwchiu/netutils
    imagePullPolicy: Always
    name: debug-server
    volumeMounts:
      - mountPath: /test
        name: data-nfsplugin
  volumes:
  - name: data-nfsplugin
    persistentVolumeClaim:
      claimName: data-nfsplugin
```

使用配置檔創建 PV、PVC 和 Pod 資源。

```bash
kubectl apply -f introduction/storage/csi/deploy.yaml
```

在 Pod 中新增檔案。

```bash
kubectl exec debug-server -- touch /test/hello
```

查看 `/nfsshare` 資料夾中的檔案。

```bash
ls /nfsshare/
hello
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
