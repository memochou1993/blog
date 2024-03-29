---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（五）：使用 kind 創建叢集
date: 2021-12-09 14:32:26
tags: ["Deployment", "Kubernetes", "Docker", "kind"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

KIND 是 Kubernetes In Docker 的意思，使用 Docker 容器做為 Kubernetes 節點。適合用於測試 Kubernetes 本身，並建構多節點的 Kubernetes 叢集。

## 做法

先啟動全新的虛擬環境。

```bash
vagrant destroy
vagrant up
```

在虛擬機器中安裝 kind。

```bash
curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64" && chmod +x ./kind
```

使用指定的設定檔創建一個多節點的叢集。

```bash
sudo ./kind create cluster --config hiskio-course/vagrant/kind.yaml
```

指定的設定檔如下：

```yaml
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
- role: worker
- role: worker
```

修正權限。

```bash
sudo chown -R $USER $HOME/.kube
```

安裝 kubectl 指令。

```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubectl
```

取得叢集資訊。

```bash
kubectl cluster-info --context kind-kind
```

取得 Pod 列表。

```bash
kubectl -n kube-system get pods
```

取得 Node 列表。

```bash
kubectl get nodes
```

取得 Docker 容器列表，會有 `kind-worker`、`kind-worker2` 和 `kind-control-plane` 三個容器。

```bash
docker ps
```

進到 `kind-control-plane` 容器內。

```bash
docker exec -it kind-control-plane bash
```

使用 `crictl` 指令查看容器列表，會有 `kube-apiserver`、`kube-controller-manager`、`kube-scheduler` 和 `etcd` 等容器。

```bash
crictl ps
```

## 補充

如果在創建叢集時，遇到以下錯誤訊息：

```bash
k8s: ERROR: failed to create cluster: failed to generate kubeadm config content: failed to get kubernetes version from node: failed to get file: command "docker exec --privileged kind-control-plane cat /kind/version" failed with error: exit status 1
```

可以使用以下指令：

```bash
sudo ./kind create cluster --config hiskio-course/vagrant/kind.yaml
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
