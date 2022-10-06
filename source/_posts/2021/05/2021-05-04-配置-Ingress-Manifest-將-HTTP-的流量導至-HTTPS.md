---
title: 配置 Ingress Manifest 將 HTTP 的流量導至 HTTPS
date: 2021-05-04 23:16:22
tags: ["環境部署", "Kubernetes", "Ingress", "HTTPS"]
categories: ["環境部署", "Kubernetes", "其他"]
---

## 做法

使用以下語法，讓 ALB 將 HTTP 的流量導至 HTTPS：

```bash
alb.ingress.kubernetes.io/actions.${action-name}
```

修改 `ingress.yaml` 檔：

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  namespace: default
  name: ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-west-2:xxxx:certificate/xxxxxx
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
spec:
  rules:
    - http:
        paths:
         - path: /*
           backend:
             serviceName: ssl-redirect
             servicePort: use-annotation
         - path: /*
           backend:
             serviceName: my-service
             servicePort: 80
```

- 註解 `alb.ingress.kubernetes.io/listen-ports` 必須至少包含 `[{"HTTP": 80}, {"HTTPS":443}]` 兩個埠號。
- 註解 `alb.ingress.kubernetes.io/certificate-arn` 必須設置憑證。
- 動作 `ssl-redirect` 必須在規則的第一個，讓 ALB 優先解析。

套用設定。

```bash
kubectl apply -f ingress.yaml
```

查看 Ingress 狀態。

```bash
kubectl describe ingress my-service
```

## 參考資料

- [Redirect Traffic from HTTP to HTTPS](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/tasks/ssl_redirect/)
