---
title: 使用 Helm 管理 Kubernetes 設定檔
date: 2022-02-24 00:00:16
tags: ["環境部署", "Kubernetes", "Helm"]
categories: ["環境部署", "Kubernetes", "Helm"]
---

## 簡介

Helm 是一個管理 Kubernetes 應用程式的套件，透過 Helm Charts 可以幫助開發者打包、安裝、升級相關的 Kubernetes 應用程式。

Helm Charts 被設計得容易創造、版本控制、分享以及發佈，透過 Helm Charts 可以避免不斷地複製貼上各式各樣的 Kubernetes 配置檔。

## 安裝

使用 `brew` 安裝 `helm` 指令。

```BASH
brew install helm
```

## 範例

首先在本機使用 `kind` 啟動一個 Kubernetes 叢集。

```BASH
kind create cluster
```

添加一個名為 `bitnami` 的 Helm Chart 儲存庫。

```BASH
helm repo add bitnami https://charts.bitnami.com/bitnami
```

列出在 `bitnami` 儲存庫中可以安裝的 chart 資源。

```BASH
helm search repo bitnami
```

更新儲存庫。

```BASH
helm repo update
```

安裝名為 `bitnami/mysql` 的 chart 資源。

```BASH
helm install bitnami/mysql --generate-name
NAME: mysql-1645633212
LAST DEPLOYED: Thu Feb 24 00:20:16 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES: ...
```

查看名為 `bitnami/mysql` 的 chart 資訊。

```BASH
helm show chart bitnami/mysql
```

列出所有 chart 資源。

```BASH
helm list
NAME            	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART       	APP VERSION
mysql-1645633212	default  	1       	2022-02-24 00:20:16.871097 +0800 CST	deployed	mysql-8.8.25	8.0.28
```

列出所有 Pod 資源。

```BASH
kubectl get pods -o wide
NAME                 READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
mysql-1645633212-0   1/1     Running   0          14m   10.244.2.4   kind-worker   <none>           <none>
```

最後，可以移除 chart 資源。

```BASH
helm uninstall mysql-1645633212
```

## 參考資料

- [Helm](https://helm.sh/docs/)
