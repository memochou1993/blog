---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（廿七）：認識 CoreDNS 伺服器
date: 2022-01-01 21:06:00
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

CoreDNS 是一個可擴充的 DNS 伺服器，可以做為 Kubernetes 叢集的 DNS 伺服器。與 Kubernetes 一樣，CoreDNS 專案由 CNCF 托管。透過在現有的叢集中替換 kube-dns，可以在叢集中使用 CoreDNS 部署，或者使用 kubeadm 等工具來部署和升級叢集。CoreDNS 本身使用 ClusterIP Service 暴露服務到全叢集。

Service Name 與 ClusterIP 的轉換仰賴 CoreDNS。當 Pod 運行起來的時候，Kubernetes 預設會修改 `/etc/resolv.conf` 檔，把 Name Server 指向 CoreDNS，因此發出的請求，都會被導向 CoreDNS。

Pod DNS Policy 可以指定 Kubernetes 如何處理 Pod 的 DNS，有以下四個選項：

- Default：Pod 的 DNS 繼承自節點的 DNS。
- None：忽略所有配置，使用 Pod 的 YAML 配置檔中的 `dnsConfig` 欄位自定義 DNS。
- ClusterFirst：預設的選項，所有請求會優先在叢集所在域查詢，如果沒有才會轉發到上游 DNS。
- ClusterFirstWithHostNet：和 ClusterFirst 選項一樣，但是可以使 Pod 被外部網路直接訪問，也可以被叢集內的其他 Pod 訪問。

## 實作

查看 Pod 列表，只有 `coredns` 是透過 CNI 框架去部署的 IP 位址，其餘的 Pod 皆是與 Host Network 、節點共享網路。

```bash
kubectl -n kube-system get pods -o wide
NAME                                         READY   STATUS    RESTARTS   AGE     IP           NODE                 NOMINATED NODE   READINESS GATES
coredns-6955765f44-4tvlr                     1/1     Running   0          3m23s   10.244.0.2   kind-control-plane   <none>           <none>
coredns-6955765f44-584jr                     1/1     Running   0          3m23s   10.244.0.4   kind-control-plane   <none>           <none>
etcd-kind-control-plane                      1/1     Running   0          3m39s   172.17.0.3   kind-control-plane   <none>           <none>
kindnet-55gvb                                1/1     Running   0          3m8s    172.17.0.4   kind-worker2         <none>           <none>
kindnet-fpt7k                                1/1     Running   0          3m8s    172.17.0.2   kind-worker          <none>           <none>
kindnet-xgxtj                                1/1     Running   0          3m23s   172.17.0.3   kind-control-plane   <none>           <none>
kube-apiserver-kind-control-plane            1/1     Running   0          3m39s   172.17.0.3   kind-control-plane   <none>           <none>
kube-controller-manager-kind-control-plane   1/1     Running   0          3m39s   172.17.0.3   kind-control-plane   <none>           <none>
kube-proxy-6s4j2                             1/1     Running   0          3m8s    172.17.0.2   kind-worker          <none>           <none>
kube-proxy-89jhj                             1/1     Running   0          3m8s    172.17.0.4   kind-worker2         <none>           <none>
kube-proxy-qdbb8                             1/1     Running   0          3m23s   172.17.0.3   kind-control-plane   <none>           <none>
kube-scheduler-kind-control-plane            1/1     Running   0          3m39s   172.17.0.3   kind-control-plane   <none>           <none>
```

查看 Service 列表，在 `kube-system` 命名空間中已有 `kube-dns` 服務。在叢集裡，可以使用 `10.96.0.10` 這個 Cluster IP 去存取 `coredns` 的服務。

```bash
kubectl -n kube-system get svc
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   103s
```

使用配置檔創建範例資料夾中的所有 Pod。

```bash
kubectl apply -R -f introduction/pod_dns
```

### Default

查看配置檔。

```bash
cat introduction/pod_dns/basic.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: default
  labels:
    app: myapp
spec:
  containers:
  - name: default
    image: hwchiu/netutils
  dnsPolicy: Default
```

查看 Pod 中的 `/etc/resolv.conf` 檔。

```bash
kubectl exec default -- cat /etc/resolv.conf
search hitronhub.home
nameserver 10.0.2.3
```

查看名為 `default` 的 Pod 所在的節點。

```bash
kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
clusterfirst                1/1     Running   0          4m57s   10.244.2.2   kind-worker    <none>           <none>
clusterfirst-true           1/1     Running   0          4m57s   172.17.0.4   kind-worker2   <none>           <none>
clusterfirstwithhost        1/1     Running   0          4m57s   10.244.2.3   kind-worker    <none>           <none>
clusterfirstwithhost-true   1/1     Running   0          4m57s   172.17.0.4   kind-worker2   <none>           <none>
default                     1/1     Running   0          4m57s   10.244.1.2   kind-worker2   <none>           <none>
none                        1/1     Running   0          4m57s   10.244.2.4   kind-worker    <none>           <none>
```

查看名為 `kind-worker2` 的節點中的 `/etc/resolv.conf` 檔。

```bash
docker exec kind-worker2 cat /etc/resolv.conf
nameserver 10.0.2.3
search hitronhub.home
```

Pod 與節點的 Name Server相同。

### None

查看配置檔。

```bash
cat introduction/pod_dns/none.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: none
  labels:
    app: myapp
spec:
  containers:
  - name: none
    image: hwchiu/netutils
  dnsPolicy: None
  dnsConfig:
    nameservers:
      - 8.8.8.8
    searches:
      - ns1.svc.cluster-domain.example
      - my.dns.search.suffix
    options:
      - name: ndots
        value: "2"
      - name: edns0
```

- ，必須提供 `dnsConfig` 欄位的配置。

查看 Pod 中的 `/etc/resolv.conf` 檔。

```bash
kubectl exec -it none -- cat /etc/resolv.conf
search ns1.svc.cluster-domain.example my.dns.search.suffix
nameserver 8.8.8.8
options ndots:2 edns0
```

與自定義的配置相同。

### ClusterFirst

查看配置檔。

```bash
cat introduction/pod_dns/clusterFirst.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: clusterfirst
  labels:
    app: myapp
spec:
  containers:
  - name: clusterfirst
    image: hwchiu/netutils
  dnsPolicy: ClusterFirst
```

查看 Pod 中的 `/etc/resolv.conf` 檔，Pod 的 Name Server 指向 CoreDNS 的 Cluster IP。

```bash
kubectl exec clusterfirst -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local hitronhub.home
nameserver 10.96.0.10
options ndots:5
```

### ClusterFirstWithHostNet

查看配置檔。

```bash
cat introduction/pod_dns/clusterwithhost.yaml
```

配置檔如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: clusterfirstwithhost
  labels:
    app: myapp
spec:
  containers:
  - name: clusterfirstwithhost
    image: hwchiu/netutils
  dnsPolicy: ClusterFirstWithHostNet
```

查看 Pod 中的 `/etc/resolv.conf` 檔，Pod 的 Name Server 指向 CoreDNS 的 Cluster IP。

```bash
kubectl exec -it clusterfirstwithhost -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local hitronhub.home
nameserver 10.96.0.10
options ndots:5
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
