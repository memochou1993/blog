---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（十四）：認識 kubectl 套件
permalink: 「Kubernetes-實作手冊：基礎入門篇」學習筆記（十四）：認識-kubectl-套件
date: 2021-12-20 22:28:59
tags: ["環境部署", "Kubernetes", "Docker"]
categories: ["環境部署", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」學習筆記"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Krew 是一個用來管理各種 kubectl 套件的管理工具。

## 安裝

執行以下指令，安裝 Krew 套件管理工具。

```BASH
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc
```

## 使用

使用以下指令列出所有套件。

```BASH
kubectl krew list
```

使用以下指令尋找套件。

```BASH
kubectl krew search
```

安裝 `tree` 套件，可以用樹狀結構來表示 Kubernetes 中各資源的關係。

```BASH
kubectl krew install tree
```

使用 `kubectl tree` 指令，用樹狀結構列出某個 ReplicaSet 與其他資源的關係。

```BASH
kubectl tree rs test-rs
NAMESPACE  NAME                 READY  REASON  AGE
default    ReplicaSet/test-rs   -              22h
default    ├─Pod/test-rs-c2njg  True           22h
default    ├─Pod/test-rs-cv8fz  True           22h
default    ├─Pod/test-rs-d6rtj  True           22h
default    ├─Pod/test-rs-nmdjp  True           22h
default    └─Pod/test-rs-swzkt  True           22h
```

使用 `kubectl tree` 指令，用樹狀結構列出某個 Deployment 與其他資源的關係。

```BASH
kubectl tree -n kube-system deployment coredns
NAMESPACE    NAME                              READY  REASON  AGE
kube-system  Deployment/coredns                -              23h
kube-system  └─ReplicaSet/coredns-6955765f44   -              23h
kube-system    ├─Pod/coredns-6955765f44-rhrvb  True           23h
kube-system    └─Pod/coredns-6955765f44-wc7k7  True           23h
```

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
