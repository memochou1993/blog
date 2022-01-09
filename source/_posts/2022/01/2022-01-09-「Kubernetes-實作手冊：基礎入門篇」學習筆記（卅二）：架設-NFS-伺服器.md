---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（卅二）：架設 NFS 伺服器
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（卅二）：架設-NFS-伺服器
date: 2022-01-09 20:45:10
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

NFS（Network File System）即網路檔案系統，是一種分散式檔案系統，使客戶端主機可以存取伺服器端的檔案，並且其過程與存取本地儲存時一樣。

使用 NFS 伺服器，可以讓 Pod 被重新部署到任一節點時，仍然能夠與其他 Pod 共享相同的儲存資源。

## 實作

### 安裝 NFS 伺服器

安裝 `nfs-kernel-server` 套件。

```BASH
sudo apt-get install nfs-kernel-server
```

在根目錄建立 `nfsshare` 資料夾。

```BASH
sudo mkdir /nfsshare
```

將相關權限寫入 `/etc/exports` 設定中。

```BASH
echo "/nfsshare *(rw,sync,no_root_squash)" | sudo tee /etc/exports
```

- 權限 `rw` 代表可讀寫。
- 權限 `sync` 代表可同步寫入記憶體和硬碟。
- 權限 `no_root_squash` 代表用戶進入後即變為 root 角色。

載入 `/etc/exports` 設定。

```BASH
sudo exportfs -r
```

列出 NFS 伺服器所分享出來的資料夾。

```BASH
sudo showmount -e
```

### 存取 NFS 伺服器

查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/storage/nfs/deploy.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-dir
spec:
  replicas: 3
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
          name: test-nfs
      volumes:
      - name: test-nfs
        nfs:
          server: 172.18.0.1
          path: "/nfsshare"
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/nfs/deploy.yaml
```

查看 Pod 列表。

```BASH
kubectl get pods
```

檢查其中一個 Pod 資源。

```BASH
kubectl describe pod nfs-dir-65f48c4f84-2ttnj
```

由於 Pod 之中沒有 NFS 的客戶端套件，因次無法成功部署。

```BASH
Events:
  Type     Reason       Age   From               Message
  ----     ------       ----  ----               -------
  Normal   Scheduled    71s   default-scheduler  Successfully assigned default/nfs-dir-65f48c4f84-2ttnj to kind-worker
  Warning  FailedMount  70s   kubelet            MountVolume.SetUp failed for volume "test-nfs" : mount failed: exit status 32
```

先更新各個節點上的儲存褲列表。

```BASH
docker exec -it kind-control-plane sed -i -re 's/([a-z]{2}.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
docker exec -it kind-worker sed -i -re 's/([a-z]{2}.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
docker exec -it kind-worker2 sed -i -re 's/([a-z]{2}.)?archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
```

先更新各個節點上的套件。

```BASH
docker exec -it kind-control-plane apt-get -y update
docker exec -it kind-worker apt-get -y update
docker exec -it kind-worker2 apt-get -y update
```

在各個節點上安裝 NFS 的客戶端套件

```BASH
docker exec -it kind-control-plane apt-get -y install nfs-common
docker exec -it kind-worker apt-get -y install nfs-common
docker exec -it kind-worker2 apt-get -y install nfs-common
```

進到其中一個 Pod 資源，在共享的資料夾新增一個檔案。

```BASH
cd /test
touch hello
```

使用另一個終端機視窗進入虛擬機，查看共享的資料夾，會新增一個檔案。

```BASH
ls /nfsshare
hello
```

### 同時讀寫

查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/storage/nfs/write.yaml
```

配置檔如下：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-write
spec:
  replicas: 3
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
          name: test-nfs
        command: ["/bin/bash"]
        args: ["-c", "while true; do echo $HOSTNAME >> /test/data ;sleep $[($RANDOM%5)+1]s; done"]
      volumes:
      - name: test-nfs
        nfs:
          server: 172.18.0.1
          path: "/nfsshare"
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/storage/nfs/write.yaml
```

使用 `tail` 指令監聽 `data` 檔案，可以看到檔案被不停地讀寫。

```BASH
tail -f data
```

### 存取模式

NFS 支援以下存取模式：

- ReadWriteOnce
- ReadOnlyMany
- ReadWriteMany

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
