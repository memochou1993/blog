---
title: 認識 Kubernetes 容器管理平台（二）：叢集、部署、豆莢
date: 2020-10-31 16:58:11
tags: ["Deployment", "Kubernetes", "Docker", "minikube"]
categories: ["Deployment", "Kubernetes", "Others"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- macOS
- minikube

## 叢集

Kubernetes 協調一個高可用的電腦叢集（Cluster），每個電腦作為獨立單元互相連接工作。Kubernetes 中的抽象允許容器化的應用被部署到叢集，而無需將它們綁定到某個特定的獨立電腦。為了使用這種新的部署模型，應用需要以將應用與單個主機分離的方式打包：它們需要被容器化。與過去的那種應用直接以一包的方式深度與主機集成的部署模型相比，容器化應用更靈活、更可用。Kubernetes 以更高效的方式跨叢集自動分發和調度應用容器。Kubernetes 是一個開源平台，並且可應用於生產環境。

一個 Kubernetes 叢集包含兩種類型的資源：

- Master 調度整個叢集
- Nodes 負責運行應用

```bash
|----------------------------------------------------|
|                       Cluster                      |
|----------------------------------------------------|
|                  |--------------|                  |
|                  |    Master    |                  |
|                  |--------------|                  |
|                                                    |
| |--------------| |--------------| |--------------| |
| |     Node     | |     Node     | |     Node     | |
| |--------------| |--------------| |--------------| |
| |node processes| |node processes| |node processes| |
| |--------------| |--------------| |--------------| |
|----------------------------------------------------|
```

Master 負責管理整個叢集。Master 協調叢集中的所有活動，例如調度應用、維護應用的所需狀態、應用擴容以及推出新的更新。

工作節點（Node）是一個虛擬機或者物理機，它在 Kubernetes 叢集中充當工作機器的角色，每個 Node 都有 Kubelet，它管理 Node 而且是 Node 與 Kubernetes 叢集通訊的代理。Node 還應該具有用於處理容器操作的工具，例如 Docker 或 rkt。處理生產級流量的 Kubernetes 叢集至少應具有三個 Node。

在 Kubernetes 上部署應用時，由 Master 啟動應用容器。Master 就編排容器在叢集的 Node 上運行。Node 使用 Master 暴露的 Kubernetes API 與 Master 通訊。終端使用者也可以使用 Kubernetes API 與叢集互動。

Kubernetes 既可以部署在物理機上，也可以部署在虛擬機上。minikube 是一種輕量級的 Kubernetes 實現，可在本地計算機上創建 VM 並部署僅包含一個節點的簡單叢集。minikube 可用於 Linux、macOS 和 Windows 系統。

### 創建叢集

查看 minikube 版本。

```bash
minikube version
```

啟動 minikube ，創建一個 Kubernetes 叢集。

```bash
minikube start
```

查看 kubectl 版本。

```bash
kubectl version
```

- `Client Version` 指的是 kubectl 的版本。
- `Server Version` 指的是 Kubernetes 的版本。

查看叢集資訊。

```bash
kubectl cluster-info
```

查看叢集中的所有工作節點（Nodes），狀態為 `Ready`，表示可以用來部署應用程式。

```bash
kubectl get nodes
```

## 部署

一旦運行了 Kubernetes 叢集，就可以在其上部署容器化應用程式。為此，需要創建 Kubernetes Deployment 配置。Deployment 指揮 Kubernetes 如何創建和更新應用程式的實例。創建 Deployment 後，Kubernetes master 會將應用程式實例調度到叢集中的各個節點上。

創建應用程式實例後，Kubernetes Deployment 控制器會持續監聽這些實例。如果託管實例的節點關閉或被刪除，則 Deployment 控制器會將該實例替換為叢集中另一個節點上的實例。這提供了一種自我修復機制來解決機器故障維修的問題。

在沒有 Kubernetes 這種編排系統之前，安裝腳本通常用於啟動應用程式，但它們不會從機器故障中恢復。通過創建應用程式實例並使它們在節點之間運行，Kubernetes Deployments 提供了一種與眾不同的應用程式管理方法。

### 創建應用程式

首先，創建一個應用程式的 Deployment。執行以下指令，Kubernetes 會找尋一個合適的 Node，並將應用程式調度到這個 Node 上。

```bash
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
```

查看所有的 Deployments。

```bash
kubectl get deployments
```

此應用程式在 Kubernetes 中運行，對外是隔離的。雖然在同一個叢集下的其他 Pods 和 Services 可以看見它，但從外部是無法的。

創建一個 proxy，這個 proxy 允許我們使用 API 和 Kubernetes 叢集互動。

```bash
kubectl proxy
```

使用 API 查看 Kubernetes 版本。

```bash
curl http://localhost:8001/version
```

API server 會自動為每個 Pod 建立各自的 API 端點。

## 豆莢

創建 Deployment 時，Kubernetes 添加了一個 Pod 來託管我們的應用實例。Pod 是 Kubernetes 抽象出來的，表示一組一個或多個應用程式容器（如 Docker），以及這些容器的一些共享資源。包括：

- 共享存儲。
- 網路。
- 有關每個容器如何運行的資訊，例如容器映像版本或要使用的特定端口。

Pod 為特定於應用程式的「邏輯主機」建模，並且可以包含相對高度耦合的不同應用容器。例如 Pod 可能既包含帶有 Node.js 應用的容器，也包含另一個不同的容器，用於提供 Node.js 網路伺服器要發布的資料。Pod 中的容器共享 IP 位址和端口，始終位於同一位置並且共同調度，並在同一個 Node 上的共享上下文中運行。

Pod 是 Kubernetes 裡的最小單位，當我們在 Kubernetes 上創建 Deployment 時，該 Deployment 會在其中創建包含容器的 Pod（而不是直接創建容器）。每個 Pod 都與調度它的 Node 綁定，並保持在那裡，直到終止（根據重啟策略）或刪除。如果 Node 發生故障，則會在叢集中的其他可用 Node 上調度相同的 Pod。

```bash
       10.10.10.1
      (IP Address)
|-----------------------|
|          Pod          |
|-----------------------|
|      |--------|       |
|      | volumn |       |
|      |--------|       |
| |-------------------| |
| | containerized app | |
| |-------------------| |
|-----------------------|
```

一個 Pod 總是運行在 Node 中。Node 是 Kubernetes 中的參與計算的機器，可以是虛擬機或物理機，取決於叢集。每個 Node 由主節點（Master）管理。Node 可以有多個 Pod，Kubernetes 主節點會自動處理在叢集中的 Node 上調度 Pod。主節點的自動調度考量了每個 Node 上的可用資源。

每個 Kubernetes 工作節點（Node）至少運行：

- Kubelet，負責 Kubernetes 主節點和工作節點之間通訊的過程，負責管理 Pod 和機器上運行的容器。
- 容器運行時（如 Docker）負責從倉庫中提取容器映像，解壓縮容器以及運行應用程式。

```bash
|-------------------------|
|          Node           |
|-------------------------|
| |-----| |-----| |-----| |
| | Pod | | Pod | | Pod | |
| |-----| |-----| |-----| |
|-------------------------|
|     node processes      |
|  |--------| |--------|  |
|  | Kublet | | Docker |  |
|  |--------| |--------|  |
|-------------------------|
```

### 探索應用程式

首先，查看所有的 Pods。

```bash
kubectl get pods
```

查看 Pods 所包含的容器，以及容器所使用的映像檔。

```bash
kubectl describe pods
```

創建一個 proxy。

```bash
kubectl proxy
```

取得此 Pod 的名字，記錄一下，存進 `POD_NAME` 環境變數中。

```bash
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo POD_NAME=$POD_NAME
```

查看此 Pod 的日誌。

```bash
kubectl logs $POD_NAME
```

列出此 Pod 的環境變數。

```bash
kubectl exec $POD_NAME env
```

進入此 Pod 的容器。

```bash
kubectl exec -ti $POD_NAME bash
```

使用 curl 指令確認應用程式正在運行中。

```bash
root@kubernetes-bootcamp:/# curl localhost:8080
```
