---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（二）：使用 kubeadm 創建叢集
date: 2021-12-06 15:26:20
tags: ["環境部署", "Kubernetes", "Docker", "kubeadm"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 安裝 kubeadm

指令 `kubeadm` 適合一般使用者創建 Kubernetes 叢集，並且支援單一節點或多節點。

根據[官方文件](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)，需要在每台機器上安裝以下套件：

- kubeadm：用來初始化叢集的指令。
- kubelet：在叢集中的每個節點上用來啟動 Pod 和容器等。
- kubectl：用來與叢集通訊的命令列工具。

首先，指定要安裝的 Kubernetes 版本。

```bash
export KUBE_VERSION="1.17.0"
```

更新 apt 套件索引，並安裝使用 Kubernetes apt 倉庫所需要的套件：

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
```

下載 Google Cloud 公開簽名密鑰：

```bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```

添加 Kubernetes apt 倉庫：

```bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

更新 apt 套件索引，安裝指定版本的 kubelet、kubeadm 和 kubectl：

```bash
sudo apt-get update
sudo apt-get install -y kubeadm=${KUBE_VERSION}-00 kubelet=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00
```

kubelet 現在每隔幾秒就會重啟，因為它陷入了一個等待 kubeadm 的無窮迴圈。

## 啟動叢集

注意 Pod 網路不行和任何主機網路重疊，如果有衝突，在執行 `kubeadm init` 指令時需要使用 `--pod-network-cidr` 參數。

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

kubeadm 會開始在 `/etc/kubernetes/manifests` 資料夾創建一些檔案，這些 YAML 檔各自描述了四個核心元件：包括 API Server、Controller、Scheduler 和 etcd。

kubelet 會去讀取這些檔案，然後透過 Docker 創造出這些 container，這些 container 互相溝通就形成了 Kubernetes 叢集，最後 kubeadm 會透過和 API Server 溝通的方式，把 kube-proxy 以及 DNS 這兩個 container 部署到 Kubernetes 叢集之中。

為了讓一般使用者也能夠使用叢集，執行以下指令。

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

接著，使用以下指令取得 Pod 列表，由於 Kubernetes 的 4 個核心元件是被放到預設的 namespace，因此需要指定 namespace 為 `kube-system`。

```bash
kubectl -n kube-system get pods
NAME                              READY   STATUS    RESTARTS   AGE
coredns-6955765f44-pz4sw          0/1     Pending   0          94s
coredns-6955765f44-wd9vg          0/1     Pending   0          94s
etcd-k8s-dev                      1/1     Running   0          110s
kube-apiserver-k8s-dev            1/1     Running   0          109s
kube-controller-manager-k8s-dev   1/1     Running   0          110s
kube-proxy-hms85                  1/1     Running   0          93s
kube-scheduler-k8s-dev            1/1     Running   0          110s
```

最後，啟動一個 CNI 外掛，此處使用 Flannel 外掛。

```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/2140ac876ef134e0ed5af15c65e414cf26827915/Documentation/kube-flannel.yml
```

再檢查一次 Pod 列表，所有的 Pod 狀態都已更新為正在運行。

```bash
kubectl -n kube-system get pods
NAME                              READY   STATUS    RESTARTS   AGE
coredns-6955765f44-pz4sw          1/1     Running   0          13m
coredns-6955765f44-wd9vg          1/1     Running   0          13m
etcd-k8s-dev                      1/1     Running   0          14m
kube-apiserver-k8s-dev            1/1     Running   0          14m
kube-controller-manager-k8s-dev   1/1     Running   0          14m
kube-flannel-ds-amd64-p29vd       1/1     Running   0          5m12s
kube-proxy-hms85                  1/1     Running   0          13m
kube-scheduler-k8s-dev            1/1     Running   0          14m
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
