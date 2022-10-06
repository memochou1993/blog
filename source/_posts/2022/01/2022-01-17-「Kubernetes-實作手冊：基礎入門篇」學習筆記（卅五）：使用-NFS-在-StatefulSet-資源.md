---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（卅五）：使用 NFS 在 StatefulSet 資源
date: 2022-01-17 20:49:25
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

StatefulSet 使用 VolumeClaimTemplates 的格式，可以確保 Pod 使用的 PVC 總是固定。

## 實作

以下使用 kind 的環境，並安裝好 NFS 伺服器。

```bash
cd vagrant/kind
vagrant ssh
```

使用 `ifconfig` 指令查詢虛擬機的 IP 位址。

```bash
ifconfig
```

查看範例資料夾中的 PV 配置檔。

```bash
cat introduction/storage/sts/pv.yaml
```

配置檔如下，將 NFS Server 的 IP 位址修改為虛擬機的 IP 位址：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-a
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 172.18.0.1
    path: /nfsshare/sts-a
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-b
spec:
  capacity:
    storage: 1000Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 172.18.0.1
    path: /nfsshare/sts-b
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-c
spec:
  capacity:
    storage: 1000Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 172.18.0.1
    path: /nfsshare/sts-c
```

新增資料夾。

```bash
sudo mkdir /nfsshare/sts-a
sudo mkdir /nfsshare/sts-b
sudo mkdir /nfsshare/sts-c
```

使用配置檔創建 PV 資源。

```bash
kubectl apply -f introduction/storage/sts/pv.yaml
```

列出 PV 列表。

```bash
kubectl get pv
NAME    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
nfs-a   5Gi        RWX            Retain           Available                                   18s
nfs-b   1000Gi     RWX            Retain           Available                                   18s
nfs-c   1000Gi     RWX            Retain           Available                                   18s
```

查看範例資料夾中的 StatefulSet 配置檔。

```bash
cat introduction/storage/sts/deploy.yaml
```

配置檔如下：

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: sts-pv
  labels:
    app: debug
spec:
  replicas: 3
  selector:
    matchLabels:
      app: debug
  serviceName: "debug"
  template:
    metadata:
      labels:
        app: debug
    spec:
      containers:
      - name: debug-server
        image: hwchiu/netutils
        volumeMounts:
        - mountPath: /test
          name: data-pvc
  volumeClaimTemplates:
  - metadata:
      name: data-pvc
    spec:
      storageClassName: ""
      accessModes:
        - ReadWriteMany
      resources:
        requests:
          storage: 50Mi
```

使用配置檔創建 StatefulSet 資源。

```bash
kubectl apply -f introduction/storage/sts/deploy.yaml
```

在 `/nfsshare` 的個別資料夾新增不同檔案。。

```bash
sudo touch /nfsshare/sts-a/a
sudo touch /nfsshare/sts-b/b
sudo touch /nfsshare/sts-c/c
```

查看名為 `sts-pv-0` 的 Pod 中，在 `test` 資料夾的檔案。

```bash
kubectl exec sts-pv-0 -- ls /test
a
```

查看名為 `sts-pv-1` 的 Pod 中，在 `test` 資料夾的檔案。

```bash
kubectl exec sts-pv-1 -- ls /test
b
```

查看名為 `sts-pv-2` 的 Pod 中，在 `test` 資料夾的檔案。

```bash
kubectl exec sts-pv-2 -- ls /test
c
```

將 StatefulSet 資源重新部署一次。

```bash
kubectl delete -f introduction/storage/sts/deploy.yaml
kubectl apply -f introduction/storage/sts/deploy.yaml
```

查看名為 `sts-pv-0` 的 Pod 中，在 `test` 資料夾的檔案。

```bash
kubectl exec sts-pv-0 -- ls /test
a
```

查看名為 `sts-pv-1` 的 Pod 中，在 `test` 資料夾的檔案。

```bash
kubectl exec sts-pv-1 -- ls /test
b
```

查看名為 `sts-pv-2` 的 Pod 中，在 `test` 資料夾的檔案。

```bash
kubectl exec sts-pv-2 -- ls /test
c
```

將 StatefulSet 資源移除。

```bash
kubectl delete -f introduction/storage/sts/deploy.yaml
```

所有 PVC 資源仍會保留。

```bash
kubectl get pvc
NAME                STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-pvc-sts-pv-0   Bound    nfs-a    5Gi        RWX                           16m
data-pvc-sts-pv-1   Bound    nfs-b    1000Gi     RWX                           5m11s
data-pvc-sts-pv-2   Bound    nfs-c    1000Gi     RWX                           3m42s
```

因此 StatefulSet 可以確保 Pod 擁有專屬 PVC 資源。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
