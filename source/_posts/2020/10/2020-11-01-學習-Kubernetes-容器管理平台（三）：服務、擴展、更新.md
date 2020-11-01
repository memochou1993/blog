---
title: 學習 Kubernetes 容器管理平台（三）：服務、擴展、更新
permalink: 學習 Kubernetes 容器管理平台（三）：服務、擴展、更新
date: 2020-11-01 22:01:41
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
echo NODE_PORT=$NODE_PORT
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

我們創建了一個 Deployment，並透過 Service 讓其可以被公開訪問。但 Deployment 只為運行這個應用程式創建一個 Pod 而已。當流量增加時，我們需要擴容應用程式，以滿足使用者需求。

所謂「擴縮」，是透過改變 Deployment 中的副本數量來實現的。在執行 `kubectl run` 指令時，可以透過`--replicas` 參數來設置 Deployment 的副本數量，

```BASH
|-------------------------|    |-------------------------|
|         Service         |    |         Service         |
| |---------------------| |    | |---------| |---------| |
| |        Node         | |    | |  Node   | |  Node   | |
| |       |-----|       | |    | | |-----| | | |-----| | |
| |       | Pod |       | |    | | | Pod | | | | Pod | | |
| |       |-----|       | | -> | | |-----| | | |-----| | |
| |                     | |    | |         | |         | |
| |                     | |    | | |-----| | |         | |
| |                     | |    | | | Pod | | |         | |
| |                     | |    | | |-----| | |         | |
| |---------------------| |    | |---------| |---------| |
|-------------------------|    |-------------------------|
```

擴展 Deployment 將創建新的 Pods，並將資源調度請求分配到有可用資源的節點上，收縮 Deployment 會將 Pods 數量減少至所需的狀態。Kubernetes 還支援 Pods 的自動縮放，將 Pods 數量收縮到 0 也是可以的，但這會終止 Deployment 上所有已經部署的 Pods。

運行應用程式的多個實例，需要在它們之間分配流量。Service 有一種負載均衡器類型（LoadBalancer），可以將網路流量均衡分配到外部可以訪問的 Pods 上。服務將會一直通過端點來監聽 Pods 的運行，保證流量只分配到可用的 Pods 上。

一旦有了多個應用實例，就可以在不停機的情況下滾動更新。

### 縮放應用程式

首先，查看所有的 Deployments 資訊。

```BASH
kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   1/1     1            1           26s
```

- 欄位 `NAME` 會顯示叢集中 Deployment 的名字。
- 欄位 `READY` 會顯示運行中副本和預期副本的比例。
- 欄位 `UP-TO-DATE` 會顯示已經達到預期副本的數量。
- 欄位 `AVAILABLE` 會顯示已經可供使用者使用的副本數量。
- 欄位 `AGE` 會顯示應用程式的運行時間。

再來，查看由 Deployment 所創建的 `ReplicaSet` 資訊。

```BASH
kubectl get rs
NAME                             DESIRED   CURRENT   READY   AGE
kubernetes-bootcamp-57978f5f5d   1         1         1       9m28s
```

- 欄位 `DESIRED` 會顯示預期副本的數量。
- 欄位 `CURRENT` 會顯示運行中副本的數量。

現在，使用 `kubectl scale` 指令，將 Deployment 調整到 4 個副本。

```BASH
kubectl scale deployments/kubernetes-bootcamp --replicas=4
```

再查看一次 Deployments 資訊。

```BASH
kubectl get deployments                                                                                                             4.28G 
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   4/4     4            4           15m
```

然後查看所有的 Pods 資訊，現在有 4 個不同 IP 位址的 Pods 了。

```BASH
kubectl get pods -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
kubernetes-bootcamp-57978f5f5d-9lxcn   1/1     Running   0          16m     172.17.0.2   minikube   <none>           <none>
kubernetes-bootcamp-57978f5f5d-j6692   1/1     Running   0          3m10s   172.17.0.6   minikube   <none>           <none>
kubernetes-bootcamp-57978f5f5d-kwsdv   1/1     Running   0          3m10s   172.17.0.5   minikube   <none>           <none>
kubernetes-bootcamp-57978f5f5d-z7glk   1/1     Running   0          3m10s   172.17.0.4   minikube   <none>           <none>
```

這個改變會被記錄到 Deployment 的活動日誌中，查看 Deployment 的詳細資訊：

```BASH
kubectl describe deployments/kubernetes-bootcamp
...
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  18m    deployment-controller  Scaled up replica set kubernetes-bootcamp-57978f5f5d to 1
  Normal  ScalingReplicaSet  5m28s  deployment-controller  Scaled up replica set kubernetes-bootcamp-57978f5f5d to 4
```

現在確認一下 Service 是否有負載均衡流量，查看 Service 的詳細資訊。

```BASH
kubectl describe services/kubernetes-bootcamp
```

取得此 Service 的 Node 的埠號，記錄一下，存進 `NODE_PORT` 環境變數中。

```BASH
export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
echo NODE_PORT=$NODE_PORT
```

進到 minikube 虛擬機中，訪問此 Service。現在每一次的請求都是觸及到不同的 Pod，這代表負載均衡已經成功運作了。

```BASH
minikube ssh
docker@minikube:~$ curl localhost:<NODE_PORT>
```

如果要收縮 Service 到 2 個副本，執行以下指令：

```BASH
kubectl scale deployments/kubernetes-bootcamp --replicas=2
```

查看一下 Deployment 資訊。

```BASH
kubectl get deployments
```

並確認一下 Pods，已經有 2 個 Pods 被終止了。

```BASH
kubectl get pods -o wide
```

## 更新

使用者會希望應用程式始終可用，而開發人員則需要每天多次部署它們的新版本。在 Kubernetes 中，這些是透過滾動更新（Rolling Updates）完成的。滾動更新允許透過使用新的實例逐步更新 Pod 實例，零停機進行 Deployment 更新。新的 Pod 將在具有可用資源的節點上進行調度。

前面我們將應用程式擴展為運行多個實例，這是在不影響應用程式可用性的情況下執行更新的要求。預設情形下，更新期間不可用的 Pod 的最大值和可以創建的新的 Pod 數量都是 1。這兩個選項都可以被設置為數字或百分比。在 Kubernetes 中，更新是經過版本控制的，任何 Deployment 更新都可以恢復到以前的版本。

```BASH
|-------------------------|    |-------------------------|    |-------------------------|
|         Service         |    |         Service         |    |         Service         |
| |---------| |---------| |    | |---------| |---------| |    | |---------| |---------| |
| |  Node   | |  Node   | |    | |  Node   | |  Node   | |    | |  Node   | |  Node   | |
| | |-----| | | |-----| | |    | | |-----| | | |-----| | |    | | |-----| | | |-----| | |
| | | App | | | | App | | | -> | | | New | | | | App | | | -> | | | New | | | | New | | |
| | |     | | | |-----| | |    | | | App | | | |     | | |    | | | App | | | | App | | |
| | |-----| | | |-----| | |    | | |-----| | | |-----| | |    | | |-----| | | |-----| | |
| |---------| |---------| |    | |---------| |---------| |    | |---------| |---------| |
|-------------------------|    |-------------------------|    |-------------------------|
```

與應用程式擴展類似，如果公開了 Deployment，Service 將在更新期間僅對可用的 Pod 進行負載均衡。滾動更新允許以下操作：

- 將應用程式從一個環境提升到另一個環境（通過容器鏡像更新）。
- 回滾到以前的版本。
- 持續整合（CI）和持續部署（CD），無需停機。

### 更新應用程式版本

首先，查看所有的 Deployments。

```BASH
kubectl get deployments
```

查看所有的 Pods。

```BASH
kubectl get pods
```

查看應用程式的映像檔版本。

```BASH
kubectl describe pods
```

使用 `set image` 指令，更新映像檔版本。

```BASH
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
```

取得此 Service 的 Node 的埠號，記錄一下，存進 `NODE_PORT` 環境變數中。

```BASH
export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
echo NODE_PORT=$NODE_PORT
```

進到 minikube 虛擬機中，訪問此 Service。現在此應用程式已經被更新為版本 2 了。

```BASH
minikube ssh
docker@minikube:~$ curl localhost:<NODE_PORT>
```

確認一下更新狀態。

```BASH
kubectl rollout status deployments/kubernetes-bootcamp
```

現在，更新映像檔版本到 10。

```BASH
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=gcr.io/google-samples/kubernetes-bootcamp:v10
```

查看一下 Deployments，發現預期副本的數量和可供使用者使用的副本數量不一樣。

```BASh
kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   2/4     3            2           21m
```

查看所有的 Pods，有一些 Pods 的狀態可能會顯示為 `ErrImagePull` 或 `ImagePullBackOff`。

```BASH
kubectl get pods
NAME                                  READY   STATUS             RESTARTS   AGE
kubernetes-bootcamp-597654dbd-j5xmt   0/1     ImagePullBackOff   0          5m22s
kubernetes-bootcamp-597654dbd-m74dc   0/1     ImagePullBackOff   0          5m23s
kubernetes-bootcamp-597654dbd-tkbgf   0/1     ImagePullBackOff   0          6m17s
kubernetes-bootcamp-769746fd4-59wpw   1/1     Running            0          24m
kubernetes-bootcamp-769746fd4-t9zf9   1/1     Running            0          5m22s
```

由於根本沒有版本 10 的映像檔，因此需要回復到先前的版本。

```BASH
kubectl rollout undo deployments/kubernetes-bootcamp
```

現在，查看所有的 Deployments。

```BASH
kubectl get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
kubernetes-bootcamp   4/4     4            4           34m
```

再查看所有的 Pods，全部都回復正常了。

```BASH
NAME                                  READY   STATUS    RESTARTS   AGE
kubernetes-bootcamp-769746fd4-59wpw   1/1     Running   0          26m
kubernetes-bootcamp-769746fd4-qd4tz   1/1     Running   0          44s
kubernetes-bootcamp-769746fd4-rrpq4   1/1     Running   0          44s
kubernetes-bootcamp-769746fd4-t9zf9   1/1     Running   0          7m10s
```
