---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿三）：認識 clusterIP 服務類型
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（廿三）：認識-clusterIP-服務類型
date: 2021-12-28 14:38:17
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Kubernetes 的 Service 有不同的類型，選擇 `ClusterIP` 時，可以透過叢集的內部 IP 暴露服務，但是服務只能夠在叢集內部被訪問。

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/service/clusterIP/hello.yml
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
        image: hwchiu/netutil
```

查看範例資料夾中的 Service 配置檔。

```BASH
cat introduction/service/clusterIP/service.yml
```

配置檔如下：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: cluster-demo
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-kubernetes
```

使用配置檔創建 Deployment 和 Service 資源。

```BASH
kubectl apply -R -f introduction/service/clusterIP
```

透過選擇器查看 Pod 列表。

```BASH
kubectl get pods -l app=hello-kubernetes -o wide
```

查看 Service 列表。

```BASH
kubectl get svc
```

查看 Endpoint 列表。

```BASH
kubectl get endpoints
```

進到名為 `client` 的 Pod 中。

```BASH
kubectl exec -it client-67674d5464-mth4j -- bash
```

嘗試透過 Cluster IP 去存取服務。

```BASH
curl 10.96.226.2
```

顯示結果如下，代表可以從 Pod 中存取服務。。會發現 HTML 中 Pod 的名稱每一次都不太一樣，這是隨機的。

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
      <td>hello-kubernetes-789cbf668d-2lpqm</td>
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

進到名為 `kind-worker` 的 Container 中。

```BASH
docker exec -it kind-worker bash
```

嘗試透過 Cluster IP 去存取服務。

```BASH
curl 10.96.226.2
```

顯示結果如下，代表可以從 Node 中存取服務。

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
      <td>hello-kubernetes-789cbf668d-2lpqm</td>
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

回到虛擬機。

```BASH
exit
```

如果直接從叢集外部透過 Cluster IP 去存取服務，會無法存取。

```BASH
curl 10.96.226.2
```

因此 Cluster IP 只能在叢集內部的 Node 或 Pod 中被存取，不允許外部存取。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
