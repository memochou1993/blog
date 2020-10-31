---
title: 學習 Kubernetes 容器管理平台（三）：服務、擴展、更新
permalink: 學習 Kubernetes 容器管理平台（三）：服務、擴展、更新
date: 2020-10-31 22:01:41
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- MacOS
- minikube

## 服務

Kubernetes Pod 是稍縱即逝的。Pod 實際上擁有生命週期。當一個工作 Node 死亡後，在 Node 上運行 Pod 也會消亡。ReplicaSet 會自動地創建新的 Pod 驅動叢集回到目標狀態，以保證應用程式正常運行。這些副本是可替換的；前端系統不應該關心後端副本，即使 Pod 丟失或重新創建。也就是說，Kubernetes 集群中的每個 Pod（即使是在同一個 Node 上）都有一個唯一的 IP 位址，因此需要一種方法自動調度 Pod 之間的變更，以便應用程式保持運行。

Kubernetes 中的服務（Service）是一種抽象概念，它定義了 Pod 的邏輯集合訪問 Pod 的協議。Service 使從屬 Pod 之間的低耦合成為可能。和其他 Kubernetes 對象一樣，Service 用 YAML（推薦）或者 JSON 來定義。Service 下的一組 Pod 通常由 LabelSelector 來標記。

儘管每個 Pod 都有一個唯一的 IP 位址，但是如果沒有 Service，這些 IP 不會暴露在叢集外部。Service 允許應用程式接收流量。

Service 也可以用在 ServiceSpec 標記 `type` 的方式暴露：

- ClusterIP：是預設的類型，在叢集的內部 IP 上公開 Service。此類型使得 Service 只能從叢集內訪問。
- NodePort：使用 NAT 在叢集中每個選定 Node 的相同端口上公開 Service。使用 `<NodeIP>:<NodePort>` 從叢集外部訪問 Service。是 ClusterIP 的超集。
- LoadBalancer：在當前雲中創建一個外部負載均衡器（如果支援的話），並為 Service 分配一個固定的外部 IP。是 NodePort 的超集。
- ExternalName：通過返回帶有該名稱的 CNAME 記錄，使用任意名稱（由 spec 中的 externalName 制定）公開 Service。不使用代理。這種類型需要 kube-dns 的 v1.7 或更高版本。

```BASH
|-----------------------|
|         Service       |
| |--------| |--------| |
| |  Node  | |  Node  | |
| |--------| |--------| |
|-----------------------|
```

Service 透過一組 Pod 路由通訊。Service 是一種抽象，它允許 Pod 死亡並在 Kubernetes 中複製，而不會影響應用程式。在依賴的 Pod（如應用程式中的前端和後端組件）之間進行發現和路由是由 Kubernetes Service 處理的。

Service 匹配一組 Pod 是使用標籤（Label）和選擇器（Selector），它們是允許對 Kubernetes 中的對象進行邏輯操作的一種分組原語。標籤是附加在對象上的鍵值對，可以以多種方式使用：

- 指定用於開發、測試和生產的對象。
- 嵌入版本標籤。
- 使用標籤將對象進行分類。

```BASH
|---------------------|
|       Service       |
|       s:App=A       |
| |-------| |-------| |
| |  Node | |  Node | |
| | app=A | | app=A | |
| |-------| |-------| |
|---------------------|
```

### 暴露應用程式

首先，查看所有的 Pods。

```BASH
kubectl get pods
```

查看所有的 Services。

```BASH
kubectl get services
```

使用 `NodePort` 類型暴露此服務。此 Service 將擁有一個唯一的叢集 IP、內部埠號和外部 IP（Node 的 IP）。

```BASH
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
```

查看此 Service 的外部埠號。

```BASH
kubectl describe services/kubernetes-bootcamp
```

取得此 Service 的 Node 的埠號，記錄一下，存進 `NODE_PORT` 環境變數中。

```BASH
export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
```

從本機透過 minikube 執行應用程式。

```BASH
minikube service kubernetes-bootcamp
```

或進到 minikube 虛擬機中，訪問此 Service。

```BASH
minikube ssh
docker@minikube:~$ curl localhost:<NODE_PORT>
```

Deployment 會自動幫 Pod 建立標籤，查看一下 Deployment 的詳細資訊。

```BASH
kubectl describe deployment
```

可以使用標籤來查詢符合條件的所有 Pods：

```BASH
kubectl get pods -l app=kubernetes-bootcamp
```

也可以查詢 Services：

```BASH
kubectl get services -l app=kubernetes-bootcamp
```

套用一個新的標籤給 Pod：

```BASH
kubectl label pod $POD_NAME run=v1
```

使用新的標籤查詢 Pods：

```BASH
kubectl get pods -l run=v1
```

使用標籤刪除符合查詢條件的 Service：

```BASH
kubectl delete service -l app=kubernetes-bootcamp
```

進到 minikube 虛擬機中，此 Service 已無法從外部被訪問。

```BASH
minikube ssh
docker@minikube:~$ curl localhost:<NODE_PORT>
```

但是其實 Service 還是在 Pod 中運行，因為此應用程式仍被 Deployment 所管理。

```BASH
kubectl exec -ti $POD_NAME -- curl localhost:8080
```

## 擴展

TODO

## 更新

TODO
