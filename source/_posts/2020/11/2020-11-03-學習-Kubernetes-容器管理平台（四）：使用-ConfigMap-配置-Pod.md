---
title: 學習 Kubernetes 容器管理平台（四）：使用 ConfigMap 配置 Pod
permalink: 學習-Kubernetes-容器管理平台（四）：使用-ConfigMap-配置-Pod
date: 2020-11-03 21:05:17
tags: ["環境部署", "Kubernetes", "Docker", "minikube"]
categories: ["環境部署", "Kubernetes"]
---

## 前言

本文為〈[Kubernetes 官方文件](https://kubernetes.io/docs/home/)〉的學習筆記。

## 環境

- MacOS
- minikube

## 概述

ConfigMap 允許配置文件與鏡像文件分離，使得容器化的應用程式具有可移植性。

## 創建配置文件

新增一個 `configure-pod-container/configmap` 資料夾。

```BASH
mkdir -p configure-pod-container/configmap/
```

### 使用 kubectl create configmap 指令

#### 基於檔案

下載範例檔到 `configure-pod-container/configmap` 資料夾中。

```BASH
wget https://kubernetes.io/examples/configmap/game.properties -O configure-pod-container/configmap/game.properties
wget https://kubernetes.io/examples/configmap/ui.properties -O configure-pod-container/configmap/ui.properties
```

使用 `kubectl create configmap` 指令將 `configure-pod-container/configmap` 資料夾下的所有檔案，即 `game.properties` 檔和 `ui.properties` 檔打包到名為 `game-config` 的 ConfigMap 中。

```BASH
kubectl create configmap game-config --from-file=configure-pod-container/configmap/
```

查看 `game-config` 的詳細資訊。

```BASH
kubectl describe configmaps game-config
```

輸出如下，`game.properties` 檔和 `ui.properties` 檔的內容會出現在 ConfigMap 的 Data 部分。

```BASH
Name:         game-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
game.properties:
----
enemies=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLRBABAS
secret.code.allowed=true
secret.code.lives=30
ui.properties:
----
color.good=purple
color.bad=yellow
allow.textmode=true
how.nice.to.look=fairlyNice
```

以 YAML 的形式查看。

```BASH
kubectl get configmaps game-config -o yaml
```

輸出類似以下內容：

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2016-02-18T18:52:05Z
  name: game-config
  namespace: default
  resourceVersion: "516"
  selfLink: /api/v1/namespaces/default/configmaps/game-config
  uid: b4952dc3-d670-11e5-8cd0-68f728db1985
data:
  game.properties: |
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30
  ui.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
    how.nice.to.look=fairlyNice
```

在使用 `--from-file` 參數時，可以定義在 ConfigMap 的 Data 部分出現的鍵名，而不是使用預設的文件名稱當做鍵名。

```BASH
kubectl create configmap game-config-special-key --from-file=game-special-key=configure-pod-container/configmap/game.properties
```

以 YAML 的形式查看。

```BASH
kubectl get configmaps game-config-special-key -o yaml
```

輸出類似以下內容：

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2016-02-18T18:54:22Z
  name: game-config-3
  namespace: default
  resourceVersion: "530"
  selfLink: /api/v1/namespaces/default/configmaps/game-config-3
  uid: 05f8da22-d671-11e5-8cd0-68f728db1985
data:
  game-special-key: |
    enemies=aliens
    lives=3
    enemies.cheat=true
    enemies.cheat.level=noGoodRotten
    secret.code.passphrase=UUDDLRLRBABAS
    secret.code.allowed=true
    secret.code.lives=30
```

#### 基於環境變數檔

使用 `--from-env-file` 參數，可以從 ENV 檔（環境變數檔）創建 ConfigMap。

ENV 檔的語法規則如下：

- 每一行必須為 `VAR=VAL` 的格式。
- 以 `#` 符號開頭的行，視為註解，將被忽略。
- 空行將被忽略。
- 引號不會被特別處理（會直接成為 ConfigMap 值的一部分）。

下載範例檔案到 `configure-pod-container/configmap` 資料夾中。

```BASH
wget https://kubernetes.io/examples/configmap/game-env-file.properties -O configure-pod-container/configmap/game-env-file.properties
wget https://k8s.io/examples/configmap/ui-env-file.properties -O configure-pod-container/configmap/ui-env-file.properties
```

將 ENV 檔打包到名為 `game-config-env-file` 的 ConfigMap 中。注意，當多次使用 `--from-env-file` 參數時，只會採取最後一個 ENV 檔的內容。

```BASH
kubectl create configmap game-config-env-file --from-env-file=configure-pod-container/configmap/game-env-file.properties
```

以 YAML 的形式查看。

```BASH
kubectl get configmap game-config-env-file -o yaml
```

輸出類似以下內容：

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2017-12-27T18:36:28Z
  name: game-config-env-file
  namespace: default
  resourceVersion: "809965"
  selfLink: /api/v1/namespaces/default/configmaps/game-config-env-file
  uid: d9d1ca5b-eb34-11e7-887b-42010a8002b8
data:
  allowed: '"true"'
  enemies: aliens
  lives: "3"
```

#### 基於字面值

使用 `--from-literal` 參數，可以從指令指定的字面值創建。

```BASH
kubectl create configmap special-config --from-literal=special.how=very --from-literal=special.type=charm
```

以 YAML 的形式查看。

```BASH
kubectl get configmaps special-config -o yaml
```

輸出類似以下內容：

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2016-02-18T19:14:38Z
  name: special-config
  namespace: default
  resourceVersion: "651"
  selfLink: /api/v1/namespaces/default/configmaps/special-config
  uid: dadce046-d673-11e5-8cd0-68f728db1985
data:
  special.how: very
  special.type: charm
```

若要查看所有的 ConfigMap，使用以下指令：

```BASH
kubectl get configmaps
```

### 基於生成器創建

自版本 1.14 開始，kubectl 開始支援 `kustomization.yaml` 檔。可以基於生成器創建 ConfigMap，然後將其應用於 API 伺服器上的創建物件。

#### 基於檔案

例如，要從 `configure-pod-container/configmap/game.properties` 檔生成一個 ConfigMap：

```BASH
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: game-config-4
  files:
  - configure-pod-container/configmap/game.properties
EOF
```

使用 `kubectl apply` 指令創建 ConfigMap 物件：

```BASH
kubectl apply -k .
```

- 生成的 ConfigMap 名稱具有通過對內容進行雜湊而附加的後綴，這樣可以確保每次修改內容時，都會生成新的 ConfigMap。

如果要定義在 ConfigMap 的 Data 部分出現的鍵名，而不是使用預設的文件名稱當做鍵名：

```BASH
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: game-config-5
  files:
  - game-special-key=configure-pod-container/configmap/game.properties
EOF
```

創建 ConfigMap 物件：

```BASH
kubectl apply -k .
```

#### 基於環境變數檔

從指令指定的字面值創建。

```BASH
configMapGenerator:
- name: special-config-6
  env: configure-pod-container/configmap/game-env-file.properties
EOF
```

創建 ConfigMap 物件：

```BASH
kubectl apply -k .
```

#### 基於字面值

從指令指定的字面值創建。

```BASH
cat <<EOF >./kustomization.yaml
configMapGenerator:
- name: special-config-7
  literals:
  - special.how=very
  - special.type=charm
EOF
```

創建 ConfigMap 物件：

```BASH
kubectl apply -k .
```

## 定義容器的環境變數

TODO
