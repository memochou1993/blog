---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（七）：使用 kubeconfig 配置叢集
date: 2021-12-11 17:17:54
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

kubeconfig 用於管理多個 Kubernetes 的叢集、使用者、命名空間及認證等資訊。

## 使用

kubectl 預設會去找 `$HOME/.kube/config` 路徑。

以 Rancher 建立的叢集為例，定義了 Cluster、Context 和 User 資訊，其 `kubeconfig` 檔如下：

```BASH
apiVersion: v1
kind: Config
clusters:
- name: "sandbox"
  cluster:
    server: "https://172.17.8.111/k8s/clusters/c-xxlj4"
    certificate-authority-data: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM3akNDQ\
      WRhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFvTVJJd0VBWURWUVFLRXdsMGFHVXQKY\
      21GdVkyZ3hFakFRQmdOVkJBTVRDV05oZEhSc1pTMWpZVEFlRncweU1URXlNVEV3T1RNeU1UZGFGd\
      zB6TVRFeQpNRGt3T1RNeU1UZGFNQ2d4RWpBUUJnTlZCQW9UQ1hSb1pTMXlZVzVqYURFU01CQUdBM\
      VVFQXhNSlkyRjBkR3hsCkxXTmhNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ\
      0tDQVFFQXlZTnB2MUtpakpqd1ZiZ1MKenlnT2dIb0lZb2QxUUJHc2FSbmFQQ3pIbWlLcE5xMWtpO\
      VE4L3NSdlFuUUNiTUNFc1VLZTZXQ0cyak5zOUtPcApzeC9uQlRqY0hHTHE1VHpYaDJ5V2VRSFpUL\
      2hDODNKTE5aUEFacXB5U1hoU0NlazBXOFlTUUhyVG1sNFY1TUUxCmdIcmZqdDk1VnIzbGIrVGdtd\
      HVFVFFUSzhDSUhDN2F0QmUxTDNNcC9qMlJpQlp0SytmOVhFM2xmTXNwampuY3UKTWVxV0hqaG1tS\
      jRBODRsMWpnbk9nMGpIcWhsNEIyOW8xZ1M4T3RGdWR0dmJZZDdjdlBnZWFmR25VS2syZkJISgpma\
      2lubXJPUU5YQ2RJaFVMcFVFYWVaV1pxMjZJVlR4dEtHbjBGS2VCWHZXTHlteTdlM1cweE5uQm95O\
      VR3MEVQCkthM1pMUUlEQVFBQm95TXdJVEFPQmdOVkhROEJBZjhFQkFNQ0FxUXdEd1lEVlIwVEFRS\
      C9CQVV3QXdFQi96QU4KQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBYjQxekd3UXkxY1oxSUduZEJhN\
      VBlVUZiSTVzc0JlWlh1MGM3c3VJawpUT1FtL0Qxd2NxU2hDQmRmVW1UcXlzM1QrQ1BIcm9QSFFTQ\
      3lWZ2VIY0pyUmcreFlhbnpFbGIxeWwyMURVN09rClJmN0lOTUpTNXFkZ0FwYXMrckdvUTl3NzJZV\
      lFCQ1YxTTgxR1phOUd1RUh4aytrRERIcXlWbjQ1TzF2ZkRsMm0KWGtpM1dhMFV4VjdzbE84NXVmR\
      HJkMFg1R3phNnh0YkM4ZWNGU1pZc0xBcHJMbUdYa3NSTzIveUJreWllQ210YQpteVc5VVhIRFBEd\
      VFKa0d1TzVJYUlPQlB1cG1lRVZLTEE3OWJscWNJSFVRMW0rYnBzSXdTYWZndTRCVnFseHlYClQza\
      0NiMnEybGFBWFEyUmlERzRIbUIzTytUcXhsQVFjdXFmWWZtekRiSnBMbFE9PQotLS0tLUVORCBDR\
      VJUSUZJQ0FURS0tLS0t"
- name: "sandbox-k8s-dev"
  cluster:
    server: "https://10.0.2.15:6443"
    certificate-authority-data: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN3akNDQ\
      WFxZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFTTVJBd0RnWURWUVFERXdkcmRXSmwKT\
      FdOaE1CNFhEVEl4TVRJeE1UQTVNell3TTFvWERUTXhNVEl3T1RBNU16WXdNMW93RWpFUU1BNEdBM\
      VVFQXhNSAphM1ZpWlMxallUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0NnZ\
      0VCQUxESlZnRkU4dVo5CndnQmd5REF2Ykh6dlpHK1ExTThWbkZkc3lkZXRWcWROV0c5L0E0R3NOM\
      m5aOHVlODIrSUxDTEd4R0dlUzFmQ1EKTkpNbzJ2Z1VkclRXMmNaNkYwaDZ3b29mV3AxWUlKdUVlU\
      UxyKzNYYXE1UnlDS1hCcFQwV2EyZXNmRUczU3dsRwoxOUlPM24wSklVZm85ZzJPdG81TGhoSlBNN\
      HlCak0xWXprZHBEdGh1RTZWaFVSelRhTlBWM1g3NHJadCtuYmtFCnNrMHNkS1FLdVM2N01wRnVoY\
      2ZtdkpwUVVpL2d3SGZHS1N6R1I3VDNUU1pETWlYbjBaWFJ0eFVXNjdKbWpQbmoKRUVOVVh0aXRiT\
      U0zbXEzREFUS3Y5bTF2K0RRRWsyZnlMZjI4YlZjSVRIenhSVEVOclgwTzk4aFdCZDQwbWdieApxM\
      Fpjb2pwWTI0a0NBd0VBQWFNak1DRXdEZ1lEVlIwUEFRSC9CQVFEQWdLa01BOEdBMVVkRXdFQi93U\
      UZNQU1CCkFmOHdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRnJIYzVDOHpSc0l4Nzl1YnlmVUpIR\
      E5Tc0JRcVR6RUc0SncKRDU5N0ZNNTlRZXdmKy9LekdwdC85Q25NbTc4bTZpek5SZEIra2Q5bVExa\
      HhSZ2UzWU96ZDJWRHp3WERLWC9NQQp6Z3l4L3AwZ2VrOXA0MmNSa2o3dzlaYzVxZERZWEFCa1J4V\
      0IyZm1Pc1hwZXlzSndUSTBDZm1uTkpDVHNYUVR6Cnh4dVNPSkZ1cjFIOWJEUFdDSjN0MzBlZ3JKc\
      UVab3AxYUd5cUFUb29ac1JaclloOFZXdVdYZWZIUzNkQTU1ZUsKYithaTJTMGlzdkRPaSs3blN0d\
      DBaOGtSRTNVMTdDMWJBN01hOWdHNHpQTzRHcnFUNTJ2ckV5MTcwd1BIVlJ1SwpsVmM1TTBRWFRFb\
      3lnVlhBaFQ3RFRlSmJvazgzMk9INDdjbTZwRWZ2MTZXUEsvRUgrRUE9Ci0tLS0tRU5EIENFUlRJR\
      klDQVRFLS0tLS0K"

users:
- name: "sandbox"
  user:
    token: "kubeconfig-user-g8s6b.c-xxlj4:ffb8wjsbnbd8vbx8xj7cqxnrmhv2pflf84l2pwwvlxdcdfn6ssbjw7"

contexts:
- name: "sandbox"
  context:
    user: "sandbox"
    cluster: "sandbox"
- name: "sandbox-k8s-dev"
  context:
    user: "sandbox"
    cluster: "sandbox-k8s-dev"

current-context: "sandbox"
```

Rancher 定義了兩個叢集，一個是 Rancher Server，另一個是 Kubernetes API Server。

## 做法

將以上 `kubeconfig` 檔存成名為 `rancher` 的檔案。

## 指令

使用 `config view` 指令查看名為 `rancher` 的 `kubeconfig` 檔。例如：

```BASH
kubectl config view --kubeconfig rancher
```

使用 `config get-contexts` 指令取得 `rancher` 環境下的 Cluster 列表。例如：

```BASH
kubectl config get-contexts --kubeconfig rancher
```

切換在 `rancher` 環境裡，要使用的 Cluster。例如：

```BASH
kubectl config use-context sandbox --kubeconfig rancher
```

顯示在 `rancher` 環境裡，正在使用的 Cluster。例如：

```BASH
kubectl config current-context --kubeconfig rancher
```

取得 Pod 列表。

```BASH
kubectl get pods -n kube-system --kubeconfig rancher
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
