---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十九）：認識 CronJob 資源
date: 2021-12-23 15:23:21
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

CronJob 資源是一個或多個基於時間間隔重複調度的 Job 資源。一個 CronJob 資源就像 `crontab` 文件中的一行。它用 Cron 格式進行編寫，並周期性地在給定的調度時間執行 Job。

## 實作

以下使用 kind 的環境。

```BASH
cd vagrant/kind
vagrant up
vagrant ssh
```

首先，查看範例資料夾中的 CronJob 配置檔。

```BASH
cat introduction/cronjob/basic.yaml
```

以下是一個描述 CronJob 的 YAML 範例檔。和 Job 類似。

```YAML
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: pi
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: pi
            image: perl
            command: ["perl",  "-Mbignum=bpi", "-wle", "print bpi(2000)"]
          restartPolicy: Never
      completions: 5
      #parallelism: 2
      #activeDeadlineSeconds: 3
      backoffLimit: 4
```

使用配置檔創建 CronJob 資源。

```BASH
kubectl apply -f introduction/cronjob/basic.yaml
```

隔一段時間，查看此 CronJob 與其他資源的關係。

```BASH
kubectl tree cronjob pi
NAMESPACE  NAME                         READY  REASON        AGE
default    CronJob/pi                   -                    3m37s
default    ├─Job/pi-1640244540          -                    2m51s
default    │ ├─Pod/pi-1640244540-8rpts  False  PodCompleted  2m51s
default    │ ├─Pod/pi-1640244540-97x9g  False  PodCompleted  2m42s
default    │ ├─Pod/pi-1640244540-td5hb  False  PodCompleted  2m18s
default    │ ├─Pod/pi-1640244540-wb6d4  False  PodCompleted  2m26s
default    │ └─Pod/pi-1640244540-x5zs8  False  PodCompleted  2m34s
```

列出所有的 CronJob 資源。

```BASH
kubectl get cronjobs
NAME   SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
pi     */1 * * * *   False     1        23s             4m2s
```

刪除 CronJob 資源。

```BASH
kubectl delete -f introduction/cronjob/basic.yaml
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
