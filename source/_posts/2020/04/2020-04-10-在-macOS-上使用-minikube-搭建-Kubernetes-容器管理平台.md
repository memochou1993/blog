---
title: 在 macOS 上使用 minikube 搭建 Kubernetes 容器管理平台
date: 2020-04-10 17:36:24
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes", "其他"]
---

## 環境

- macOS
- Docker (with HyperKit)

## 名詞解釋

### Cluster

叢集，是指由 Kubernetes 使用一系列的物理機、虛擬機和其他基礎資源來運行應用程式，或計算、存儲網路資源的集合。

### Master

主控，是 Cluster 的大腦，負責調度 Node，決定應用程式應該放在哪裡運行。Master 運行Linux 作業系統，可以是物理機或虛擬機。

### Node

節點，負責監控並匯報容器的狀態，同時根據 Master 的要求管理容器的生命周期。

### Pod

豆莢，是 Kubernetes 的最小調度單位，每個 Pod 包含一或多個容器。Pod 中的容器會作為一個整體被 Master 調度到一個 Node 上運行。

## 環境設定

首先安裝 minikube，minikube 可以將 Kubernetes 運行在本地端，方便學習與開發。

```BASH
brew install minikube
```

查看 minikube 的版本。

```BASH
minikube version
```

使用管理員權限啟動一個 cluster。

```BASH
minikube start
```

- 使用 `--driver` 參數可以指定虛擬機器。

查看 cluster 資訊。

```BASH
kubectl cluster-info
```

查看 minikube 狀態。

```BASH
minikube status
```

啟動 Kubernetes 圖形化介面。

```BASH
minikube dashboard
```

## 部署應用程式

部署一個 hello-minikube 範例。

```BASH
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
```

- `--image` 參數代表 Docker image 的位址和版本。

將其暴露在 8080 埠，並將服務類型設為 `NodePort`，使服務可以從叢集的外部被訪問。

```BASH
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```

- `--type` 參數用來指定服務的類型。
- `--port` 參數代表 container 對外的埠號。

查看 pod 列表。

```BASH
kubectl get pods
```

查看 cluster 的 IP。

```BASH
minikube ip
```

查看服務列表。

```BASH
kubectl get services
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-minikube   NodePort    10.103.2.111   <none>        8080:31220/TCP   3m48s
kubernetes       ClusterIP   10.96.0.1      <none>        443/TCP          16m
```

開啟 hello-minikube 服務。

```BASH
minikube service hello-minikube
```

## 管理叢集

暫停 Kubernetes。

```BASH
minikube pause
```

停止 cluster。

```BASH
minikube stop
```

增加預設記憶體限制（需要重新啟動）。

```BASH
minikube config set memory 16384
```

查看附加元件列表。

```BASH
minikube addons list
```

刪除所有 cluster。

```BASH
minikube delete --all
```

## 擴充應用

查看副本數。

```BASH
kubectl get deployments
```

將 hello-minikube 的副本數設定成 3。

```BASH
kubectl scale deployments/hello-minikube --replicas=3
```

## 基礎指令

用 minikube 啟動一個 cluster。

```BASH
minikube start
```

用 minikube 開啟 Kubernetes 圖形化介面。

```BASH
minikube dashboard
```

建立一個服務。

```BASH
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4
```

暴露一個 NodePort 服務。

```BASH
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```

在瀏覽器打開一個服務。

```BASH
minikube service hello-minikube
```

更新 cluster。

```BASH
minikube start --kubernetes-version=latest
```

啟動第二個 cluster。

```BASH
minikube start -p cluster2
```

停止 cluster。

```BASH
minikube stop
```

刪除 cluster。

```BASH
minikube delete
```

刪除所有 cluster。

```BASH
minikube delete --all
```

## 參考資料

- [Kubernetes Documentation](https://kubernetes.io/zh/docs/home/)
- [minikube Documentation](https://minikube.sigs.k8s.io/docs/)
