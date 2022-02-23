---
title: 在 macOS 上使用 kind 搭建 Kubernetes 容器管理平台
permalink: 在-macOS-上使用-kind-搭建-Kubernetes-容器管理平台
date: 2022-02-15 20:04:57
tags: ["環境部署", "Kubernetes", "Docker", "kind"]
categories: ["環境部署", "Kubernetes", "其他"]
---

## 安裝

使用 `brew` 安裝 `kind` 指令。

```BASH
brew install kind
```

## 使用

建立一個 `kind-config.yaml` 配置檔。

```BASH
cat > kind-config.yaml <<EOF
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
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

刪除叢集。

```BASH
kind delete cluster
```

## 範例

建立 `deployment.yaml` 檔：

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kubernetes
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes
  template:
    metadata:
      labels:
        app: hello-kubernetes
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.7
        ports:
        - containerPort: 8080
```

建立 `service.yaml` 檔：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: nodeport-demo
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30000
  selector:
    app: hello-kubernetes
```

修改 `kind-config.yaml` 檔：

```YAML
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    listenAddress: "0.0.0.0"
    protocol: tcp
- role: worker
- role: worker
```

創建叢集。

```BASH
kind create cluster --config kind-config.yaml
```

建立資源。

```BASH
kubectl apply -f deployment.yaml -f service.yaml
```

列出所有節點。

```BASH
kubectl get nodes -o wide
NAME                 STATUS   ROLES                  AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION     CONTAINER-RUNTIME
kind-control-plane   Ready    control-plane,master   9m47s   v1.21.1   172.25.0.4    <none>        Ubuntu 21.04   5.10.25-linuxkit   containerd://1.5.2
kind-worker          Ready    <none>                 9m21s   v1.21.1   172.25.0.3    <none>        Ubuntu 21.04   5.10.25-linuxkit   containerd://1.5.2
kind-worker2         Ready    <none>                 9m22s   v1.21.1   172.25.0.2    <none>        Ubuntu 21.04   5.10.25-linuxkit   containerd://1.5.2
```

列出所有服務。

```BASH
kubectl get svc
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP        10m
nodeport-demo   NodePort    10.96.234.153   <none>        80:30000/TCP   9m40s
```

從本機存取應用程式。

```BASH
curl localhost:30000
```

刪除資源。

```BASH
kubectl delete -f service.yaml -f deployment.yaml
```

刪除叢集。

```BASH
kind delete cluster
```

## 參考資料

- [kind](https://kind.sigs.k8s.io/)
