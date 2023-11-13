---
title: 認識 Kubernetes 容器管理平台（一）：使用 minikube 安装 Kubernetes
date: 2020-10-30 14:02:16
tags: ["Deployment", "Kubernetes", "Docker", "minikube"]
categories: ["Deployment", "Kubernetes", "Others"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- macOS
- minikube

## 更新

使用 Homebrew 安裝 minikube。

```bash
brew install minikube
```

## 創建叢集

啟動 minikube 並創建一個叢集（Cluster）。

```bash
minikube start
```

使用 `kubectl` 指令與叢集進行互動。以下使用 `echoserver` 映像檔創建一個  Kubernetes Deployment，並開放在 8080 埠號。

```bash
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.10
```

要訪問 `hello-minikube` 這個 Deployment，需要將其做為 Service 公開：

```bash
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```

- 參數 `--type` 用來指定 Service 的類型。

檢查 Pod 運行狀態。

```bash
kubectl get pod
```

- 狀態 `STATUS` 為 `ContainerCreating` 表示 Pod 仍在創建中。
- 狀態 `STATUS` 為 `Running` 表示 Pod 正在運行中。

獲取 Service 的 URL。

```bash
minikube service hello-minikube --url
```

刪除 `hello-minikube` Service。

```bash
kubectl delete services hello-minikube
```

刪除 `hello-minikube` Deployment。

```bash
kubectl delete deployment hello-minikube
```

停止本地 minikube 叢集：

```bash
minikube stop
```

刪除本地 minikube 叢集：

```bash
minikube delete
```

## 管理叢集

使用以下指令，指定 Kubernetes 版本。

```bash
minikube start --kubernetes-version v1.19.0
```

使用以下指令，指定 VM 驅動。

```bash
minikube start --vm-driver=<driver_name>
```

使用以下指令，將 shell 指向 minikube 的 Docker 守護行程（daemon）。Docker Client 會把 build context 送往 minikube 內的 Docker 守護行程進行打包。打包出來的映像檔會存在 minikube 虛擬機內，如此一來可以加速本地端的實驗。

```bash
eval $(minikube docker-env)
```

現在可以使用 Docker 與 minikube 虛擬機內的 Docker 守護行程進行通訊。

```bash
docker ps
```

## 設定

在 `minikube start` 指令中，使用 `--extra-config` 參數，可以調整 Kubernetes 設定。

例如要在 `Kubelet` 上將 `MaxPods` 設定調整為 5，可以使用以下參數：

```bash
--extra-config=kubelet.MaxPods=5
```

若要將 `apiserver` 的 `AuthorizationMode` 設定調整為 RBAC（一種身分驗證方法），使用以下參數：

```bash
--extra-config=apiserver.authorization-mode=RBAC
```

## 與叢集互動

### kubectl

使用 `minikube start` 指令時，會創建一個名為 `minikube` 的 `kubectl` 上下文。此上下文包含與 minikube 叢集通訊的配置。使用以下指令，查看當前的 `kubectl` 上下文。

```bash
kubectl config current-context
```

### UI 介面

使用以下指令，開啟 UI 介面。

```bash
minikube dashboard
```

### 網路

minikube 虛擬機透過 host-only IP 開放給主機系統，可以使用以下指令獲得此 IP：

```bash
minikube ip
```

在 NodePort 上，可以透過此 IP 位址訪問任何類型同為 NodePort 的服務。要確定服務的 NodePort，使用以下指令：

```bash
kubectl get service $SERVICE --output='jsonpath="{.spec.ports[0].nodePort}"'
```

### Persistent Volume

minikube 支援 `hostPath` 類型的 Persistent Volume，它們會映射為 minikube 虛擬機内的目錄。以下是 Persistent Volume 的配置範例：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0001
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 5Gi
  hostPath:
    path: /data/pv0001/
```
