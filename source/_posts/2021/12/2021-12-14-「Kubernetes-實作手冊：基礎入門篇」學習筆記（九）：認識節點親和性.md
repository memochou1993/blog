---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（九）：認識節點親和性
date: 2021-12-14 14:41:10
tags: ["Deployment", "Kubernetes", "Docker"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

節點親和性（affinity）是 Pod 的一種屬性，它使 Pod 被吸引到一類特定的節點 （可能出於一種偏好，也可能是硬性要求）。

污點（taint）和容忍度（toleration）相互配合，可以用來避免 Pod 被分配到不合適的節點上。每個節點上都可以應用一個或多個污點，這表示對於那些不能容忍這些污點的 Pod，是不會被該節點所接受的。

## 實作

先啟動全新的虛擬環境，並選擇使用 kubeadm 創建叢集的環境。

```bash
vagrant destroy
cd kubeadm
vagrant up
```

由於範例使用 kubeadm 創建 Kubernetes 叢集，因此需要將主節點上的污點移除，才可以讓 Pod 被順利部署到主節點。處理方式有兩種：

- 移除污點。
- 讓 Pod 對於該污點有忍受力。

### 移除污點

以下透過 `kubctl run` 指令運行一個測試的 Pod 範例。

```bash
kubectl run test --generator=run-pod/v1 --image=hwchiu/netutils
```

查看 Pod 列表。

```bash
kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
test   0/1     Pending   0          8s
```

檢查一下名為 `test` 的 Pod。

```bash
kubectl describe pod test
```

由於 kubelet 發現主節點上有污點，因此無法部署。

```bash
Events:
  Type     Reason            Age               From               Message
  ----     ------            ----              ----               -------
  Warning  FailedScheduling  7s (x3 over 81s)  default-scheduler  0/1 nodes are available: 1 node(s) had taints that the pod didn't tolerate.
```

檢查一下名為 `k8s-dev` 的 Node。

```bash
kubectl describe node k8s-dev
```

可以看到此 Node 上有一個名為 `node-role.kubernetes.io/master:NoSchedule` 的污點。

```bash
Taints:             node-role.kubernetes.io/master:NoSchedule
```

使用 `kubectl taint` 指令以及 `-` 符號將主節點上的污點移除。

```bash
kubectl taint node k8s-dev node-role.kubernetes.io/master:NoSchedule-
```

再檢查一下名為 `test` 的 Pod。

```bash
kubectl describe pod test
```

由於主節點上已經沒有污點了，因此 Scheduler 重新排程並幫此 Pod 找到可以運行的節點。

```bash
Events:
  Type     Reason            Age                   From               Message
  ----     ------            ----                  ----               -------
  Warning  FailedScheduling  5m29s (x36 over 51m)  default-scheduler  0/1 nodes are available: 1 node(s) had taints that the pod didn't tolerate.
  Normal   Pulling           112s                  kubelet, k8s-dev   Pulling image "hwchiu/netutils"
  Normal   Pulled            55s                   kubelet, k8s-dev   Successfully pulled image "hwchiu/netutils"
  Normal   Created           54s                   kubelet, k8s-dev   Created container test
  Normal   Started           54s                   kubelet, k8s-dev   Started container test
```

使用 `kubectl logs` 指令查看此 Pod 的日誌，發現 Pod 已正常運行。

```bash
kubectl logs test -f
```

想要進入此 Pod，可以使用以下指令：

```bash
kubectl exec test -it bash
```

最後，刪除此 Pod。

```bash
kubectl delete pod test
```

### 指定標籤

以下透過指定標籤的方式，將 Pod 部署到擁有特定標籤的 Node 上。使用 `kubctl run` 指令，運行一個測試的 Pod 範例，同時寫入一個規則，此規則希望 Pod 被放到有 `node=vm` 的這個節點上。

```bash
kubectl run test --generator=run-pod/v1 --image=hwchiu/netutils --overrides='{"spec":{"nodeSelector":{"node":"vm"}}}'
```

查看 Pod 列表。

```bash
kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
test   0/1     Pending   0          8s
```

檢查一下名為 `test` 的 Pod。

```bash
kubectl describe pod test
```

由於沒有找到指定標籤的 Node，因此無法部署。

```bash
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  90s (x2 over 2m44s)  default-scheduler  0/1 nodes are available: 1 node(s) didn't match node selector.
```

可以使用 `kubectl label` 的指令，為主節點加上 `node=vm` 的標籤。

```bash
kubectl label node k8s-dev node=vm
```

由於主節點上已經有相應的標籤了，因此 Scheduler 重新排程並幫此 Pod 找到可以運行的節點。

```bash
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  94s (x3 over 4m18s)  default-scheduler  0/1 nodes are available: 1 node(s) didn't match node selector.
  Normal   Scheduled         38s                  default-scheduler  Successfully assigned default/test to k8s-dev
  Normal   Pulling           37s                  kubelet, k8s-dev   Pulling image "hwchiu/netutils"
  Normal   Pulled            33s                  kubelet, k8s-dev   Successfully pulled image "hwchiu/netutils"
  Normal   Created           33s                  kubelet, k8s-dev   Created container test
  Normal   Started           33s                  kubelet, k8s-dev   Started container test
```

想要進入此 Pod，可以使用以下指令：

```bash
kubectl exec test -it bash
```

最後，刪除此 Pod。

```bash
kubectl delete pod test
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
