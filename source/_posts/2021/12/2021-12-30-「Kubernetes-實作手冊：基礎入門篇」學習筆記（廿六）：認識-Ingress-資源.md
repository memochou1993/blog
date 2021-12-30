---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿六）：認識 Ingress 資源
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（廿六）：認識-Ingress-資源
date: 2021-12-30 14:36:58
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Ingress 是對叢集中服務的外部訪問進行管理的 API 物件，典型的訪問方式是 HTTP。

Ingress 可以提供負載平衡、SSL Termination 和基於名稱的虛擬托管（name-based virtual hosting）。

Ingress 的相關物件有：

- Ingress Resource：由 Kubernetes 所定義的 Ingress 的 YAML 格式。
- Ingress Controller：觀察 Ingress Resource 變化，將更新提交給 Ingress Server。
- Ingress Server：接收 HTTP 請求，再轉發到不同的後端服務（可以是 Pod 或 Service）。

在一些 Ingress 實作，會處理好負載平衡，直接將封包送給 Pod，不透過 Service 轉換，也不需要使用 VIP，效率會較好。

以下是一個 Ingress 資源的 YAML 範例檔：

```YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```

- `metadata.annotations` 可以用來註解，例如要覆寫 Nginx 的路由規則。
- `spec.rules` 可以用來處理請求的分發。

實務上，還需要幫 Ingress Server 封裝上一層 Kubernetes Server，來讓 Ingress Server 藉由 NodePort 被外界存取。

## 實作

實作順序如下：

- 使用 Nginx 做為 Ingress 解決方案
- 部署兩個應用程式：`hello-k8s` 和 `httpd`
- 部署三個 Service，兩個 ClusterIP 和一個 NodePort
- 修改 VM 中的 DNS
- 部署 Ingress Resource，根據不同的 host 將封包轉發到不同的 Pod
- 從 VM 進行存取

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 Deployment 配置檔。

```BASH
cat introduction/ingress/hello.yml
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
  name: httpd
spec:
  replicas: 3
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd
        ports:
        - containerPort: 80
```

查看範例資料夾中的 Service 配置檔。

```BASH
cat introduction/ingress/service.yaml
```

配置檔如下：

```YAML
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  type: NodePort
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---
apiVersion: v1
kind: Service
metadata:
  name: hellok8s
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-kubernetes
---
apiVersion: v1
kind: Service
metadata:
  name: httpd
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: httpd
```

查看範例資料夾中的 Ingress 配置檔。

```BASH
cat introduction/ingress/ingress.yaml
```

配置檔如下：

```YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-http
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: test.com
    http:
      paths:
      - path: /v1/
        backend:
          serviceName: hellok8s
          servicePort: 80
      - path: /v2/
        backend:
          serviceName: httpd
          servicePort: 80
  - host: hello.com
    http:
      paths:
      - backend:
          serviceName: hellok8s
          servicePort: 80
  - host: httpd.com
    http:
      paths:
      - backend:
          serviceName: httpd
          servicePort: 80
```

- 使用 `rewrite-target` 規則，將轉發後的路徑改寫為根目錄。

這邊使用網路上的範例檔，部署一個基於 Nginx 的 Ingress Controller 和 Ingress Server。

```BASH
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml
```

查看在 `ingress-nginx` 命名空間中的 Pod 列表。

```BASH
kubectl -n ingress-nginx get pods
```

進到名為 `nginx-ingress-controller` 的 Pod 中。

```BASH
kubectl -n ingress-nginx exec -it nginx-ingress-controller-7f74f657bd-c5w6q -- bash
```

查看程序管理，會觀察到這個 Container 中運行了兩個 Daemon，分別是 `nginx-ingress-controller` 和 `nginx`。

```BASH
ps axuw | grep nginx
```

使用配置檔創建 Deployment 資源。

```BASH
kubectl apply -f introduction/ingress/hello.yml
```

使用配置檔創建 Service 資源。

```BASH
kubectl apply -f introduction/ingress/service.yaml
```

查看 Service 列表，有兩個新部署的 ClusterIP 服務。

```BASH
kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
hellok8s     ClusterIP   10.96.63.206    <none>        80/TCP    22s
httpd        ClusterIP   10.96.215.120   <none>        80/TCP    22s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   2d23h
```

查看在 `ingress-nginx` 命名空間中的 Service 列表，有一個新部署的 NodePort 服務。

```BASH
kubectl -n ingress-nginx get svc
NAME            TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx   NodePort   10.96.94.30   <none>        80:31789/TCP,443:30185/TCP   39s
```

使用配置檔創建 Ingress 資源。

```BASH
kubectl apply -f introduction/ingress/ingress.yaml
```

查看 Ingress 列表。

```BASH
kubectl get ing
NAME           HOSTS                          ADDRESS       PORTS   AGE
ingress-http   test.com,hello.com,httpd.com   10.96.94.30   80      24s
```

為了讓 VM 能夠存取應用程式，需要取得節點 IP 位址和 NodePort 埠號。

```BASH
kindIP=$(docker inspect kind-worker  | jq '.[0].NetworkSettings.Networks.bridge.IPAddress' | tr -d '""')
NODEPORT=$(kubectl -n ingress-nginx get svc ingress-nginx -o jsonpath='{.spec.ports[0].nodePort}')
```

修改 `/etc/hosts` 檔：

```BASH
echo "$kindIP test.com" | sudo tee -a  /etc/hosts
echo "$kindIP hello.com" | sudo tee -a  /etc/hosts
echo "$kindIP httpd.com" | sudo tee -a  /etc/hosts
```

詢問 DNS 資訊。

```BASH
nslookup test.com
nslookup hello.com
nslookup httpd.com
```

使用 `curl` 存取 test.com 的 `/v1/` 路徑。

```BASH
curl test.com:$NODEPORT/v1/
```

或存取 hello.com 路徑。

```BASH
curl hello.com:$NODEPORT
```

結果如下，流量會到 `hello-k8s` 的 Pod 資源：

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
      <td>hello-kubernetes-789cbf668d-4nh5c</td>
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

使用 `curl` 存取 test.com 的 `/v2/` 路徑。

```BASH
curl test.com:$NODEPORT/v2/
```

或存取 httpd.com 路徑。

```BASH
curl httpd.com:$NODEPORT
```

結果如下，流量會到 `httpd` 的 Pod 資源：

```HTML
<html><body><h1>It works!</h1></body></html>
```

查看 Nginx Ingress 的日誌。

```BASH
kubectl -n ingress-nginx logs nginx-ingress-controller-7f74f657bd-c5w6q -f
```

查看 Nginx Ingress Controller 的日誌。

```BASH
kubectl -n ingress-nginx logs nginx-ingress-controller-7f74f657bd-c5w6q | grep -i controller
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
