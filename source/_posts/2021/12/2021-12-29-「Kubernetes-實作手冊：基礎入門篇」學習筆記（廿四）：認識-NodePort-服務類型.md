---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿四）：認識 NodePort 服務類型
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（廿四）：認識-NodePort-服務類型
date: 2021-12-29 15:30:16
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Kubernetes 的 Service 有不同的類型，選擇 `NodePort` 時，通過每個節點上的 IP 和靜態埠（NodePort）暴露服務。NodePort 服務會路由到自動創建的 ClusterIP 服務。通過請求節點 IP，應用程式可以從集群的外部訪問一個 NodePort 服務。

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/service/nodePort/hello.yml
```

配置檔如下：

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

```BASH
cat introduction/service/nodePort/service.yml
```

配置檔如下：

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
  selector:
    app: hello-kubernetes
```

使用配置檔創建 Deployment 和 Service 資源。

```BASH
kubectl apply -R -f introduction/service/nodePort
```

透過選擇器查看 Pod 列表。

```BASH
kubectl get pods -l app=hello-kubernetes -o wide
```

查看 Service 列表。

```BASH
kubectl get svc
```

查看名為 `nodeport-demo` 的 Service 資源。

```BASH
kubectl describe svc nodeport-demo
```

結果如下，可以看到 NodePort 的埠號：

```BASH
Name:                     nodeport-demo
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=hello-kubernetes
Type:                     NodePort
IP Families:              <none>
IP:                       10.96.143.124
IPs:                      <none>
Port:                     <unset>  80/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  30466/TCP
Endpoints:                10.244.0.6:8080,10.244.1.5:8080,10.244.2.4:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

進到名為 `client` 的 Pod 中。

```BASH
kubectl exec -it client-67674d5464-k447k -- bash
```

嘗試透過 Cluster IP 去存取服務。

```BASH
curl 10.96.226.2
```

顯示結果如下，代表可以從 Pod 中存取服務。

```HTML
<!DOCTYPE html>
<html>
<head>
    <title>Hello Kubernetes!</title>
    <link rel="stylesheet" type="text/css" href="/css/main.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Ubuntu:300" >
</head>
<body>

  <div class="main">
    <img src="/images/kubernetes.png"/>
    <div class="content">
      <div id="message">
  Hello world!
</div>
<div id="info">
  <table>
    <tr>
      <th>pod:</th>
      <td>hello-kubernetes-789cbf668d-2pwhw</td>
    </tr>
    <tr>
      <th>node:</th>
      <td>Linux (4.15.0-72-generic)</td>
    </tr>
  </table>

</div>
    </div>
  </div>

</body>
</html>
```

查看名為 `kind-worker` 的 Container 的 IP 位址。

```BASH
docker exec -it kind-worker ip addr
```

回到虛擬機，嘗試透過 Node 的 IP 位址和 NodePort 的埠號去存取服務。

```BASH
curl 172.17.0.2:30466
```

顯示結果如下，代表可以透過 Node 存取服務。

```HTML
<!DOCTYPE html>
<html>
<head>
    <title>Hello Kubernetes!</title>
    <link rel="stylesheet" type="text/css" href="/css/main.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Ubuntu:300" >
</head>
<body>

  <div class="main">
    <img src="/images/kubernetes.png"/>
    <div class="content">
      <div id="message">
  Hello world!
</div>
<div id="info">
  <table>
    <tr>
      <th>pod:</th>
      <td>hello-kubernetes-789cbf668d-8kpg2</td>
    </tr>
    <tr>
      <th>node:</th>
      <td>Linux (4.15.0-72-generic)</td>
    </tr>
  </table>

</div>
    </div>
  </div>

</body>
</html>
```

因此 NodePort 可以為節點暴露一個埠號，允許外部應用程式存取。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
