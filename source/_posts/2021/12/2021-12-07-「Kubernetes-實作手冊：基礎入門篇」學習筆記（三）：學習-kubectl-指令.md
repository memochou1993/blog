---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（三）：學習 kubectl 指令
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（三）：學習-kubectl-指令
date: 2021-12-07 00:34:42
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 自動補全

啟用 kubectl 的自動補全功能。

```BASH
source <(kubectl completion bash)
```

## 指令

### get

取得 Pod 列表。

```BASH
kubectl -n kube-system get pods
```

- 使用 `-o=wide` 取得更多欄位
- 使用 `-o=yaml` 指定輸出格式為 YAML 格式
- 使用 `-o=json` 指定輸出格式為 JSON 格式
- 使用 `-w` 監聽資源變動

使用 JsonPath 輸出指定資訊。例如：

```BASH
kubectl -n kube-system get pods -o=jsonpath='{.items[*].metadata.name}'
```

### describe

取得指定 Pod 的資源描述。例如：

```BASH
kubectl -n kube-system describe pods kube-apiserver-k8s-dev
```

取得指定 Node 的資源描述。例如：

```BASH
kubectl -n kube-system describe nodes k8s-dev
```

### version

取得 Kubernetes 的 Client 和 Server 版本。

```BASH
kubectl version
```

### cluster-info

查看 Kubernetes 叢集的詳細資訊。

```BASH
kubectl cluster-info
```

### top

查看 Node 的 CPU 和 memory 的使用量。

```BASH
kubectl top nodes
```

查看 Pod 的 CPU 和 memory 的使用量。

```BASH
kubectl top pods
```

### api-versions

查看各資源 API 版本。

```BASH
kubectl api-versions
```

### logs

查看各資源的日誌。例如：

```BASH
kubectl -n kube-system logs kube-apiserver-k8s-dev
```

- 使用 `-f` 參數開啟串流模式，等待輸出

### cp

將檔案從本地複製到容器，或從容器複製到本地。例如：

```BASH
kubectl -n kube-system cp kube-apiserver-k8s-dev:/tmp/test.txt
```

### exec

使用互動模式進入到指定容器內。例如：

```BASH
kubectl -n kube-system exec -it etcd-k8s-dev sh
```

在指定容器執行指令。例如：

```BASH
kubectl -n kube-system exec etcd-k8s-dev ip addr
```

### port-forward

將本地的通訊埠轉發到容器的對外埠。例如：

```BASH
sudo kubectl -n kube-system port-forward pod/coredns-6955765f44-pz4sw 53:53
```

使用 `telnet` 指令測試本地的 53 埠。

```BASH
telnet localhost  53
Trying ::1...
Connected to localhost.
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
