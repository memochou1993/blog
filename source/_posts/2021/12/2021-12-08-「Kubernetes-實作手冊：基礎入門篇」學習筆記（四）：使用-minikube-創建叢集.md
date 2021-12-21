---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（四）：使用 minikube 創建叢集
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（四）：使用-minikube-創建叢集
date: 2021-12-08 14:35:21
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 做法

先啟動全新的虛擬環境。

```BASH
vagrant destroy
vagrant up
```

在虛擬機器中安裝 minikube。

```BASH
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
```

安裝依賴套件。

```BASH
sudo apt-get install conntrack
```

啟動叢集。

```BASH
sudo ./minikube start --vm-driver=none 
```

安裝 kubectl 指令（也可以使用 `minikube kubectl` 指令代替）。

```BASH
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubectl
```

調整權限。

```BASH
sudo chown -R $USER $HOME/.kube $HOME/.minikube
```

查看所有 namespace 的 Pod 列表。

```BASH
kubectl get --all-namespaces pods
```

查看 minikube 的外掛列表。

```BASH
sudo ./minikube addons list
```

啟用 minikube 的 dashboard 外掛。

```BASH
sudo ./minikube addons enable dashboard
```

使用 port-forward 的功能，把封包從容器外轉到容器內。

```BASH
kubectl port-forward --address 172.17.8.111 -n kubernetes-dashboard service/kubernetes-dashboard 8888:80
```

- 此 IP 位址定義在 `Vagrantfile` 檔案中。

前往 UI 介面：<http://172.17.8.111:8888>

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
