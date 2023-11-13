---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（卅四）：認識 StorageClass 資源
date: 2022-01-12 23:51:07
tags: ["Deployment", "Kubernetes", "Docker"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

StorageClass 可以用於動態分配 PersistentVolume 使用。

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

查看範例資料夾中的 NFS Client Provisioner 的 Deployment 配置檔。

```bash
cat introduction/storage/pv_pvc/pv.yaml
```

配置檔如下，將 NFS Server 的 IP 位址修改為虛擬機的 IP 位址：

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nfs-client-provisioner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nfs-client-provisioner
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 172.18.0.1
            - name: NFS_PATH
              value: /nfsshare
      volumes:
        - name: nfs-client-root
          nfs:
            server: 172.18.0.1
            path: /nfsshare
```

使用配置檔創建 Role 和 Deployment 資源。

```bash
kubectl apply -f introduction/storage/storageclass/nfs_provisioner/rbac.yaml
kubectl apply -f introduction/storage/storageclass/nfs_provisioner/deploy.yaml
```

查看範例資料夾中的 StorageClass 配置檔。

```bash
cat introduction/storage/storageclass/nfs_provisioner/sc.yaml
```

配置檔如下：

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs
parameters:
  archiveOnDelete: "false"
```

使用配置檔創建 StorageClass 資源。

```bash
kubectl apply -f introduction/storage/storageclass/nfs_provisioner/sc.yaml
```

查看 StorageClass 列表。

```bash
kubectl get sc
NAME                  PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
managed-nfs-storage   fuseim.pri/ifs          Delete          Immediate              false                  25s
```

查看範例資料夾中的第一個 Pod 配置檔。

```bash
cat introduction/storage/storageclass/pod.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pv-debug-server
spec:
  containers:
  - image: hwchiu/netutils
    imagePullPolicy: Always
    name: debug-server
    volumeMounts:
      - mountPath: /test
        name: data-pvc
  volumes:
  - name: data-pvc
    persistentVolumeClaim:
      claimName: pvc-nfs
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-nfs
spec:
  storageClassName: "managed-nfs-storage"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
```

查看範例資料夾中的第二個 Pod 配置檔。

```bash
cat introduction/storage/storageclass/pod-2.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pv-debug-server-2
spec:
  containers:
  - image: hwchiu/netutils
    imagePullPolicy: Always
    name: debug-server
    volumeMounts:
      - mountPath: /test
        name: data-pvc
  volumes:
  - name: data-pvc
    persistentVolumeClaim:
      claimName: pvc-nfs-2
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-nfs-2
spec:
  storageClassName: "managed-nfs-storage"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
```

查看 PVC 列表。

```bash
kubectl get pvc
```

查看 PV 列表。

```bash
kubectl get pvc
```

查看 `/nfsshare` 資料夾，可以看到新增了 2 個對應的資料夾。

```bash
ls /nfsshare
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
