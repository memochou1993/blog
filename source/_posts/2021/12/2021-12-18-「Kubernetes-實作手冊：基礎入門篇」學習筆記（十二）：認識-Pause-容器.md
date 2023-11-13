---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十二）：認識 Pause 容器
date: 2021-12-18 17:09:55
tags: ["Deployment", "Kubernetes", "Docker"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Pause 容器又稱 Infrastucture Container，每個 Pod 裡運行著一個特殊的被稱之爲 Pause 的容器，其他容器則爲業務容器，這些業務容器共享 Pause 容器的網路和儲存空間。

因此它們之間通訊和資料交換更為高效，同一個 Pod 裡的容器之間僅需通過 localhost 就能互相通訊。

## 實作

### Docker

首先，使用 Docker 運行一個範例容器。

```bash
docker run -d --name hwchiu hwchiu/netutils
```

運行另一個範例容器，將網路綁定到第一個範例容器。

```bash
docker run -d --net=container:hwchiu --name hwchiu2 hwchiu/netutils
```

檢查所有範例容器。

```bash
docker ps | grep hwchiu
```

使用 `ifconfig` 指令查看第一個範例容器的網卡。

```bash
docker exec -it hwchiu ifconfig
```

第一個範例容器的 IP 位址是 `172.17.0.2`。

```bash
eth0      Link encap:Ethernet  HWaddr 02:42:ac:11:00:02
          inet addr:172.17.0.2  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:14 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1116 (1.1 KB)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

使用 `ifconfig` 指令查看第二個範例容器的網卡。

```bash
docker exec -it hwchiu2 ifconfig
```

第二個範例容器的 IP 位址同樣是 `172.17.0.2`。

```bash
eth0      Link encap:Ethernet  HWaddr 02:42:ac:11:00:02
          inet addr:172.17.0.2  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:14 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1116 (1.1 KB)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

在第一個範例容器使用 `ping` 指令將封包往外送。

```bash
docker exec -it hwchiu ping 8.8.8.8
```

可以看到兩個範例容器接收到的 packets 是一樣的。

```bash
TX packets:7
```

將第一個範例容器刪除。

```bash
docker rm -f hwchiu
```

再次查看第二個範例容器的網卡。

```bash
docker exec -it hwchiu2 ifconfig
```

會發現網卡 `eth0` 已經不見。

```bash
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

如果 Container A 做為第一個 Container 提供 `172.17.0.2` 的 IP 位址，而 Container B 和 Container C 掛載在 Container A 的網路上，如果 Container A 的網路出問題，Container B 和 Container C 都會跟著有問題。

### Kubernetes

首先，查看 `introduction/pod` 範例資料夾中的 `pause.yaml` 配置檔如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: two-containers
  labels:
    app: myapp
spec:
  containers:
  - name: client
    image: hwchiu/netutils
  - name: www-server
    image: nginx
```

使用 `kubectl apply` 指令來創建 Pod。

```bash
kubectl apply -f introduction/pod/pause.yaml
```

查看 Pod 列表。

```bash
kubectl get pods
```

如果要用 `kubectl logs` 指令查看日誌的話，需要用 `-c` 參數來指定容器名稱。

```bash
kubectl logs -f two-containers -c client
```

如果要用 `kubectl exec` 進到容器的話，也需要用 `-c` 參數來指定容器名稱。

```bash
kubectl exec -it two-containers -c client bash
```

由於此 Pod 中的兩個容器都處於相同的 Network Namespace，因此可以用 `127.0.0.1` 相互溝通。

```bash
wget 127.0.0.1
cat index.html
```

列出所有的 Docker 容器，會發現當 Pod 被創建時，至少會有一個 Pause 容器在其中。因此 Pause 容器是整個 Pod 中網路的核心，也可以自己用 Docker 創建一個容器後，直接將網路掛載到此 Pause 容器。

```bash
docker ps | grep two-containers
k8s_www-server_two-containers_default_f1b30d6e-e3c3-4730-ac30-e6bc023d675b_0
k8s_client_two-containers_default_f1b30d6e-e3c3-4730-ac30-e6bc023d675b_0
k8s_POD_two-containers_default_f1b30d6e-e3c3-4730-ac30-e6bc023d675b_0
```

總結來說，在 Kubernetes 中，當 Pod 被創建時，Pause 容器就會被建立，CNI 框架會掛在 Pause 容器身上，使它具有網路能力，而其他的所有 Pod 都會將網路掛在此 Pause 容器身上。由於 Pause 容器在 Kubernetes 中的設計相當輕量、簡單，因此不太會有 crash 的情形發生。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
