---
title: 在 macOS 上使用 kind 搭建 Kubernetes 容器管理平台
permalink: 在-macOS-上使用-kind-搭建-Kubernetes-容器管理平台
date: 2022-02-15 20:04:57
tags: ["環境部署", "Kubernetes", "Docker", "kind"]
categories: ["環境部署", "Kubernetes"]
---

## 安裝

使用 brew 安裝 `kind` 指令。

```BASH
brew install kind
```

## 使用

建立一個 `kind-config.yaml` 配置檔。

```BASH
cat > kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
```

使用配置檔創建一個多節點的叢集。

```BASH
kind create cluster --config kind-config.yaml
```

取得叢集資訊。

```BASH
kubectl cluster-info --context kind-kind
```

取得 Pod 列表。

```BASH
kubectl -n kube-system get pods
```

取得 Node 列表。

```BASH
kubectl -n kube-system get nodes
```

進入名為 `kind-worker` 的節點。

```BASH
docker exec -it kind-worker bash
```

刪除節點。

```BASH
kind delete cluster
```

## 參考資料

- [kind](https://kind.sigs.k8s.io/)
