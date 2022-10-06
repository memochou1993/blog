---
title: 使用 Helm 搭建 Metabase 資料分析工具
date: 2022-08-04 16:50:31
tags: ["環境部署", "Kubernetes", "Helm", "Metabase", "BI Tool"]
categories: ["環境部署", "Kubernetes", "Helm"]
---

## 做法

添加社群維護的儲存庫。

```bash
helm repo add pmint93 https://pmint93.github.io/helm-charts
```

更新儲存庫。

```bash
helm repo update
```

建立 `config.yaml` 檔。

```yaml
replicaCount: 1
podAnnotations: {}
podLabels: {}
image:
  repository: metabase/metabase
  tag: v0.43.4.2
  pullPolicy: IfNotPresent
listen:
  host: "0.0.0.0"
  port: 3000
ssl:
  enabled: false
database:
  type: postgres
  host: your-db-host
  port: 5432
  dbname: your-db-name
  username: your-db-username
  password: your-db-password
password:
  complexity: normal
  length: 6
timeZone: UTC
emojiLogging: true
session: {}
livenessProbe:
  initialDelaySeconds: 120
  timeoutSeconds: 30
  failureThreshold: 6
readinessProbe:
  initialDelaySeconds: 30
  timeoutSeconds: 3
  periodSeconds: 5
service:
  name: metabase
  type: ClusterIP
  externalPort: 80
  internalPort: 3000
  nodePort:
  annotations: {}
ingress:
  enabled: false
  hosts:
  path: /
  labels:
  annotations: {}
  tls:
resources: {}
nodeSelector: {}
tolerations: []
affinity: {}
```

安裝 chart 資源。

```bash
helm install -f config.yaml metabase pmint93/metabase
```

列出所有 chart 資源。

```bash
helm list
```

將 `services/metabase` 服務轉發至本機。

```bash
kubectl port-forward services/metabase 8080:80
```

## 參考資料

- [Artifact Hub - metabase](https://artifacthub.io/packages/helm/metabase/metabase)
