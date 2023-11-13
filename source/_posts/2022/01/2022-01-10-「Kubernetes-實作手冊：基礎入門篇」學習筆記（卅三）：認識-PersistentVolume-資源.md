---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（卅三）：認識 PersistentVolume 資源
date: 2022-01-10 14:09:45
tags: ["Deployment", "Kubernetes", "Docker"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

持久卷（PersistentVolume，PV）是叢集中的一塊存儲，可以由管理員事先供應，或者使用存儲類（Storage Class）來動態供應。持久卷是叢集資源，就像節點也是叢集資源一樣。PV 和普通的 Volume 一樣，也是使用卷套件來實現的，只是它們擁有獨立於任何使用 PV 的 Pod 的生命週期。此 API 物件中描述了存儲的實現細節，無論其背後是 NFS、iSCSI 還是特定於雲平台的存儲系統。

持久卷宣告（PersistentVolumeClaim，PVC）表達的是用戶對存儲的請求。概念上與 Pod 類似。Pod 會耗用節點資源，而 PVC 宣告會耗用 PV 資源。Pod 可以請求特定數量的資源（CPU 和記憶體）；同樣 PVC 宣告也可以請求特定的大小和訪問模式（例如要求 PV 卷能夠以 `ReadWriteOnce`、`ReadOnlyMany` 或 `ReadWriteMany` 模式之一來掛載）。

當用戶不再使用其存儲卷時，他們可以從 API 中將 PVC 物件刪除，從而允許該資源被回收再利用。

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
cat introduction/storage/pv_pvc/pv.yaml
```

配置檔如下，將 NFS Server 的 IP 位址修改為虛擬機的 IP 位址：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-1
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 172.18.0.1
    path: /nfsshare
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-2
spec:
  capacity:
    storage: 1000Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 172.18.0.1
    path: /nfsshare
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-claim
spec:
  capacity:
    storage: 1000Gi
  accessModes:
    - ReadWriteMany
  claimRef:
    name: force-nfs
    namespace: default
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 172.18.0.1
    path: /nfsshare
```

使用配置檔創建 PV 資源。

```bash
kubectl apply -f introduction/storage/pv_pvc/pv.yaml
```

### Pending

查看範例資料夾中的 PVC 配置檔。

```bash
cat introduction/storage/pv_pvc/pvc-pending.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-pending
  namespace: default
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5000Gi
```

使用配置檔創建 PVC 資源。

```bash
kubectl apply -f introduction/storage/pv_pvc/pvc-pending.yaml
```

查看 PVC 列表。

```bash
kubectl get pvc
NAME              STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc-nfs-pending   Pending                                                     9s
```

檢查 PVC 資源。

```bash
kubectl describe pvc pvc-nfs-pending
```

事件如下：

```bash
Events:
  Type    Reason         Age                From                         Message
  ----    ------         ----               ----                         -------
  Normal  FailedBinding  7s (x8 over 104s)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set
```

由於沒有 `5000Gi` 容量的 PV 可用，因此 PVC 將處於 `Pending` 狀態。

### Force

查看範例資料夾中的 PVC 配置檔。

```bash
cat introduction/storage/pv_pvc/pvc-force.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: force-nfs
  namespace: default
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
```

使用配置檔創建 PVC 資源。

```bash
kubectl apply -f introduction/storage/pv_pvc/pvc-force.yaml
```

查看 PVC 列表，名為 `force-nfs` 的 PVC 已被綁定。

```bash
kubectl get pvc
NAME              STATUS    VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE
force-nfs         Bound     nfs-claim   1000Gi     RWX                           58s
pvc-nfs-pending   Pending                                                        5m52s
```

查看 PV 列表，名為 `nfs-claim` 的 PV 已被綁定。

```bash
kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM               STORAGECLASS   REASON   AGE
nfs-1       5Gi        RWO            Retain           Available                                               11m
nfs-2       1000Gi     RWX            Retain           Available                                               11m
nfs-claim   1000Gi     RWX            Retain           Bound       default/force-nfs                           11m
```

### Normal

查看範例資料夾中的 PVC 配置檔。

```bash
cat introduction/storage/pv_pvc/pvc.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
  namespace: default
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

使用配置檔創建 PVC 資源。

```bash
kubectl apply -f introduction/storage/pv_pvc/pvc.yaml
```

查看 PVC 列表，名為 `pvc-nfs` 的 PVC 已被綁定。

```bash
kubectl get pvc
NAME              STATUS    VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   AGE
force-nfs         Bound     nfs-claim   1000Gi     RWX                           4m41s
pvc-nfs           Bound     nfs-1       5Gi        RWO                           14s
pvc-nfs-pending   Pending                                                        9m35s
```

查看 PV 列表，名為 `nfs-1` 的 PV 已被綁定。

```bash
kubectl get pv
NAME        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM               STORAGECLASS   REASON   AGE
nfs-1       5Gi        RWO            Retain           Bound       default/pvc-nfs                             13m
nfs-2       1000Gi     RWX            Retain           Available                                               13m
nfs-claim   1000Gi     RWX            Retain           Bound       default/force-nfs                           13m
```

### Deployment

查看範例資料夾中的 Deployment 配置檔。

```bash
cat introduction/storage/pv_pvc/deploy.yaml
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
```

使用配置檔創建 Deployment 資源。

```bash
kubectl apply -f introduction/storage/pv_pvc/deploy.yaml
```

在 Pod 中新增 `hello` 檔案。

```bash
kubectl exec pv-debug-server -- touch /test/hello
```

查看虛擬機的共享資料夾，可以發現多了 `hello` 檔案。

```bash
ls /nfsshare
hello
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
