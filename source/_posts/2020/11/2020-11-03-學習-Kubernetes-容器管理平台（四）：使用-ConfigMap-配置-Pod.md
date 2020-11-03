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

ConfigMap 允許配置檔案與鏡像檔案分離，使得容器化的應用程式具有可移植性。

## 創建配置檔案

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

在使用 `--from-file` 參數時，可以定義在 ConfigMap 的 Data 部分出現的鍵名，而不是使用預設的檔案名稱當做鍵名。

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

如果要定義在 ConfigMap 的 Data 部分出現的鍵名，而不是使用預設的檔案名稱當做鍵名：

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
cat <<EOF >./kustomization.yaml
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

### 使用單個 ConfigMap 定義

先清除舊的 ConfigMap 的範例。

```BASH
kubectl delete pods --all
kubectl delete configmap --all
```

創建名為 `special-config` 的 ConfigMap。

```BASH
kubectl create configmap special-config --from-literal=special.how=very
```

使用 Pod 定義檔創建 Pod。

```BASH
kubectl create -f https://kubernetes.io/examples/pods/pod-single-configmap-env-variable.yaml
```

現在，此 Pod 的輸出會包含環境變數 `SPECIAL_LEVEL_KEY=very`。

### 使用多個 ConfigMap 定義

先清除舊的範例。

```BASH
kubectl delete pods --all
kubectl delete configmap --all
```

創建名為 `special-config` 和 `env-config` 的 ConfigMaps。

```BASH
kubectl create -f https://kubernetes.io/examples/configmap/configmaps.yaml
```

使用 Pod 定義檔創建 Pod。

```BASH
kubectl create -f https://kubernetes.io/examples/pods/pod-multiple-configmap-env-variable.yaml
```

現在，此 Pod 的輸出會包含環境變數 `SPECIAL_LEVEL_KEY=very` 和 `LOG_LEVEL=INFO`。

### 配置所有 ConfigMap 的鍵值對

先清除舊的範例。

```BASH
kubectl delete pods --all
kubectl delete configmap --all
```

創建一個包含多個鍵值對的 ConfigMap：

```BASH
kubectl create -f https://kubernetes.io/examples/configmap/configmap-multikeys.yaml
```

使用 `envFrom` 將所有 ConfigMap 的鍵值對定義為容器的環境變數。

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      envFrom:
      - configMapRef:
          name: special-config
  restartPolicy: Never
```

使用 Pod 定義檔創建 Pod。

```BASH
kubectl create -f https://kubernetes.io/examples/pods/pod-configmap-envFrom.yaml
```

現在，此 Pod 的輸出會包含環境變數 `SPECIAL_LEVEL=very` 和 `SPECIAL_TYPE=charm`。

### 在 Pod 定義檔使用 ConfigMap 定義的環境變數

先清除舊的範例。

```BASH
kubectl delete pods --all
kubectl delete configmap --all
```

使用 `$(VAR_NAME)` 的替換語法在 Pod 定義檔的 `command` 中使用 ConfigMap 定義的環境變數。

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "echo $(SPECIAL_LEVEL_KEY) $(SPECIAL_TYPE_KEY)" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: SPECIAL_LEVEL
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: SPECIAL_TYPE
  restartPolicy: Never
```

使用 Pod 定義檔創建 Pod。

```BASH
kubectl create -f https://kubernetes.io/examples/pods/pod-configmap-env-var-valueFrom.yaml
```

現在，此 Pod 的容器會輸出 `very charm`。

## 定義資料卷的環境變數

創建名為 `special-config` 的 ConfigMap。

```BASH
kubectl create -f https://kubernetes.io/examples/configmap/configmap-multikeys.yaml
```

### 將 ConfigMap 中的資料添加到資料卷

先清除舊的範例。

```BASH
kubectl delete pods --all
kubectl delete configmap --all
```

在 Pod 定義檔的 `volumes` 字段下添加 ConfigMap 名稱。這會將 ConfigMap 資料添加到指定為 `volumeMounts.mountPath` 的資料夾（範例為 `/etc/config`）。`command` 字段引用儲存在 ConfigMap 中的 `special.level`。

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "ls /etc/config/" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
  restartPolicy: Never
```

使用 Pod 定義檔創建 Pod。

```BASH
kubectl create -f https://kubernetes.io/examples/pods/pod-configmap-volume.yaml
```

現在 Pod 運行時，指令 `ls /etc/config/` 會產生以下輸出：

```BASH
SPECIAL_LEVEL
SPECIAL_TYPE
```

### 將 ConfigMap 中的資料添加到資料卷中的特定路徑

先清除舊的範例。

```BASH
kubectl delete pods --all
kubectl delete configmap --all
```

使用 `path` 字段為特定的 ConfigMap 項目指定預期的檔案路徑。在這裡，`SPECIAL_LEVEL` 將掛載在 `config-volume` 資料卷中 `/etc/config/keys` 資料夾下。

```YAML
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh","-c","cat /etc/config/keys" ]
      volumeMounts:
      - name: config-volume
        mountPath: /etc/config
  volumes:
    - name: config-volume
      configMap:
        name: special-config
        items:
        - key: SPECIAL_LEVEL
          path: keys
  restartPolicy: Never
```

使用 Pod 定義檔創建 Pod。

```BASH
kubectl create -f https://kubernetes.io/examples/pods/pod-configmap-volume-specific-key.yaml
```

當 Pod 運行時，指令 `cat /etc/config/keys` 會產生以下輸出：

```BASH
very
```

## 補充

ConfigMap 的 `data` 字段包含配置資料。它可以很簡單（如用 `--from-literal` 的單個屬性定義）或很複雜（如用 `--from-file` 的配置檔案）

```BASH
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: 2016-02-18T19:14:38Z
  name: example-config
  namespace: default
data:
  # --from-literal
  example.property.1: hello
  example.property.2: world
  # --from-file
  example.property.file: |-
    property.1=value-1
    property.2=value-2
    property.3=value-3
```

### 限制

一些限制如下：

- 在 Pod 定義檔引用之前，必須先創建一個 ConfigMap（除非將 ConfigMap 標記為「可選的」）。如果引用的 ConfigMap 不存在，則 Pod 不會啟動。同樣，引用 ConfigMap 中不存在的鍵，也會阻止 Pod 啟動。
- 如果使用 `envFrom` 來定義環境變數，無效的鍵會被忽略。啟動 Pod 時，無效名稱會被記錄在事件日誌中，使用 `kubectl get events` 指令可以進行查看。
- ConfigMap 位於特定的命名空間中，每個 ConfigMap 只能被相同命名空間中的 Pod 引用。
- 不能將 ConfigMap 用於靜態 Pod，Kubernetes 不支援這種用法。
