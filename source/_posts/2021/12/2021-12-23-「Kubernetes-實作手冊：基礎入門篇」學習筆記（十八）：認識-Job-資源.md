---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十八）：認識 Job 資源
date: 2021-12-23 14:11:01
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Job 會創建一個或多個 Pod，並將持續重試 Pod 的執行，直到指定數量的 Pod 成功終止。隨著 Pod 成功結束，Job 跟蹤記錄成功完成的 Pod 數量。當數量達到指定的成功個數時，任務即結束。刪除 Job 的操作會清除所創建的全部 Pod。掛起 Job 的操作會刪除 Job 的所有活躍 Pod，直到 Job 被再次恢復執行。

Job 有完成模式和並行模式：如果 `completions` 大於 1，`parallelism` 是 1，則代表一個一個執行 Job；如果 `completions` 是 N，`parallelism` 也是 N，則代表要一次執行所有 Job。

## 實作

以下使用 kind 的環境。

```bash
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 Job 配置檔。

```bash
cat introduction/job/basic.yaml
```

以下是一個描述 Job 的 YAML 範例檔。由於 `completions` 設定為 5，`parallelism` 預設為 1，因此最終需要跑完 5 個成功的 Pod，一次一個。而 `backoffLimit` 設定為 4，代表如果出現 4 個失敗的 Pod，就要結束 Job。

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: Never
  completions: 5
  #parallelism: 3
  #activeDeadlineSeconds: 5
  backoffLimit: 4
```

使用配置檔創建 Job 資源。

```bash
kubectl apply -f introduction/job/basic.yaml
```

查看此 Job 與其他資源的關係。一開始只會有一個 Pod。

```bash
kubectl tree job pi
NAMESPACE  NAME            READY  REASON              AGE
default    Job/pi          -                          2s
default    └─Pod/pi-bxqpc  False  ContainersNotReady  2s
```

列出所有的 Job，顯示皆已完成。

```bash
kubectl get jobs
NAME       READY   STATUS      RESTARTS   AGE
pi-7z8c6   0/1     Completed   0          56s
pi-8clmm   0/1     Completed   0          3m48s
pi-9xnlv   0/1     Completed   0          6m25s
pi-cn9cv   0/1     Completed   0          3m56s
pi-xfbnr   0/1     Completed   0          64s
```

刪除 Job 資源。

```bash
kubectl delete -f introduction/job/basic.yaml
```

在描述 Job 的 YAML 範例檔，將 `parallelism` 修改為 3，表示使用並行模式，一次運行 3 個 Pod。

```bash
parallelism: 3
```

再創建一次 Job 資源。

```bash
kubectl apply -f introduction/job/basic.yaml
```

查看此 Job 與其他資源的關係。一開始就會有三個 Pod。

```bash
NAMESPACE  NAME            READY  REASON              AGE
default    Job/pi          -                          2s
default    ├─Pod/pi-6gfqd  False  ContainersNotReady  2s
default    ├─Pod/pi-qfjp4  False  ContainersNotReady  2s
default    └─Pod/pi-wdmdr  False  ContainersNotReady  2s
```

刪除 Job 資源。

```bash
kubectl delete -f introduction/job/basic.yaml
```

在描述 Job 的 YAML 範例檔，將 `activeDeadlineSeconds` 修改為 3，表示一個 Job 如果運行超過 5 秒，就視為失敗。

```bash
activeDeadlineSeconds: 5
```

再創建一次 Job 資源。

```bash
kubectl apply -f introduction/job/basic.yaml
```

列出所有的 Job，顯示皆未完成。

```bash
kubectl get jobs
NAME   COMPLETIONS   DURATION   AGE
pi     0/5           78s        78s
```

觀察一下 Job 詳細資訊。

```bash
kubectl describe job
```

結果如下，可以看到失敗的原因為 `DeadlineExceeded`。

```bash
Events:
  Type     Reason            Age                  From            Message
  ----     ------            ----                 ----            -------
  Normal   SuccessfulCreate  115s                 job-controller  Created pod: pi-sb8x8
  Normal   SuccessfulCreate  115s                 job-controller  Created pod: pi-ww5tn
  Normal   SuccessfulCreate  115s                 job-controller  Created pod: pi-l6h74
  Normal   SuccessfulDelete  110s                 job-controller  Deleted pod: pi-ww5tn
  Normal   SuccessfulDelete  110s                 job-controller  Deleted pod: pi-sb8x8
  Normal   SuccessfulDelete  110s                 job-controller  Deleted pod: pi-l6h74
  Warning  DeadlineExceeded  110s (x2 over 110s)  job-controller  Job was active longer than specified deadline
```

刪除 Job 資源。

```bash
kubectl delete -f introduction/job/basic.yaml
```

順帶一提，由於 `activeDeadlineSeconds` 的權重比 `backoffLimit` 高，因此 Job 一旦到達所設時限，就不會再部署額外的 Pod。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
