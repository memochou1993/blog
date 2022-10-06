---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿五）：認識 Headless 服務類型
date: 2021-12-29 16:25:42
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

有時不需要或不想要負載平衡，以及單獨的 Service IP。 遇到這種情況，可以透過指定 Cluster IP 的值為 `None` 來創建 Headless Service。

可以使用 Headless Service 與其他服務發現機制，而不必與 Kubernetes 的實現捆綁在一起。

Headless Service 並不會分配 Cluster IP，kube-proxy 不會處理它們，而且平台也不會為它們進行負載平衡和路由。DNS 如何實現自動配置，依賴於 Service 是否定義了選擇器。

## 實作

以下使用 kind 的環境。

```bash
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 StatefulSet 和 Deployment 配置檔。

```bash
cat introduction/service/headless/hello.yml
```

配置檔如下：

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: hello-kubernetes
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes
  serviceName: "headless-demo"
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
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: client
  template:
    metadata:
      labels:
        app: client
    spec:
      containers:
      - name: client
        image: hwchiu/netutils
```

查看範例資料夾中的 Service 配置檔。

```bash
cat introduction/service/headless/service.yml
```

配置檔如下：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: headless-demo
spec:
  clusterIP: None
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-kubernetes
```

使用配置檔創建 StatefulSet、Deployment 和 Service 資源。

```bash
kubectl apply -R -f introduction/service/headless
```

透過選擇器查看 Pod 列表。

```bash
kubectl get pods -l app=hello-kubernetes -o wide
```

結果如下：

```bash
NAME                      READY   STATUS    RESTARTS   AGE   IP           NODE                 NOMINATED NODE   READINESS GATES
client-67674d5464-w5t5b   1/1     Running   0          27s   10.244.2.5   kind-worker          <none>           <none>
hello-kubernetes-0        1/1     Running   0          27s   10.244.1.6   kind-worker2         <none>           <none>
hello-kubernetes-1        1/1     Running   0          25s   10.244.2.6   kind-worker          <none>           <none>
hello-kubernetes-2        1/1     Running   0          23s   10.244.0.7   kind-control-plane   <none>           <none>
```

查看 Service 列表。

```bash
kubectl get svc
```

結果如下：

```bash
NAME            TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
headless-demo   ClusterIP   None         <none>        80/TCP    46s
kubernetes      ClusterIP   10.96.0.1    <none>        443/TCP   2d
```

查看 Endpoint 列表。

```bash
kubectl get endpoints
```

結果如下：

```bash
NAME            ENDPOINTS                                         AGE
headless-demo   10.244.0.7:8080,10.244.1.6:8080,10.244.2.6:8080   105s
kubernetes      172.17.0.3:6443                                   2d
```

透過 client 容器訪問 Service 的 DNS。

```bash
kubectl exec client-67674d5464-w5t5b -- nslookup headless-demo
```

所有的 Endpoint 結果如下：

```bash
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	headless-demo.default.svc.cluster.local
Address: 10.244.2.6
Name:	headless-demo.default.svc.cluster.local
Address: 10.244.0.7
Name:	headless-demo.default.svc.cluster.local
Address: 10.244.1.6
```

透過 client 容器訪問 3 個 Pod 的 DNS。

```bash
kubectl exec client-67674d5464-w5t5b -- nslookup hello-kubernetes-0.headless-demo
kubectl exec client-67674d5464-w5t5b -- nslookup hello-kubernetes-1.headless-demo
kubectl exec client-67674d5464-w5t5b -- nslookup hello-kubernetes-2.headless-demo
```

刪除所有名為 `hello-kubernetes` 的 Pod。

```bash
kubectl delete pod hello-kubernetes-0 hello-kubernetes-1 hello-kubernetes-2
```

再取得一次 Pod 列表，會發現 IP 位址都改變了。

```bash
kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE   IP           NODE                 NOMINATED NODE   READINESS GATES
client-67674d5464-w5t5b   1/1     Running   0          15m   10.244.2.5   kind-worker          <none>           <none>
hello-kubernetes-0        1/1     Running   0          27s   10.244.1.7   kind-worker2         <none>           <none>
hello-kubernetes-1        1/1     Running   0          25s   10.244.2.7   kind-worker          <none>           <none>
hello-kubernetes-2        1/1     Running   0          24s   10.244.0.8   kind-control-plane   <none>           <none>
```

但是依舊可以透過 client 容器訪問 Pod 的 DNS，對應用程式來講只要保持相同的 Domain Name 都可以存取。

```bash
kubectl exec client-67674d5464-w5t5b -- nslookup hello-kubernetes-0.headless-demo
kubectl exec client-67674d5464-w5t5b -- nslookup hello-kubernetes-1.headless-demo
kubectl exec client-67674d5464-w5t5b -- nslookup hello-kubernetes-2.headless-demo
```

總結來說，Headless Service 經常與 StatefulSet 搭配，用在一些 Layer 7 的應用程式，例如 gRPC 等，無法使用 TCP 的分流來完成負載平衡。而解決方式就是取得所有的伺服器 Endpoint，自行實作如何達成負載平衡。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
