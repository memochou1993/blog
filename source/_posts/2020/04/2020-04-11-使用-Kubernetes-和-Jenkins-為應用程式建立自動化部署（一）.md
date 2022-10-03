---
title: 使用 Kubernetes 和 Jenkins 為應用程式建立自動化部署（一）
date: 2020-04-11 15:23:29
tags: ["環境部署", "Kubernetes", "Docker", "minikube", "CI/CD"]
categories: ["環境部署", "Kubernetes", "其他"]
---

## 前言

本文為〈[Set Up A CI/CD Pipeline With Kubernetes](https://www.linux.com/audience/enterprise/set-cicd-pipeline-kubernetes-part-1-overview/)〉系列文章（deprecated）的學習筆記。

## 環境

- macOS
- Docker (with HyperKit)

## 目標

使用 Kubernetes 和 Jenkins 為範例應用程式建立 CI/CD 自動化部署流程。

## 環境設定

安裝 minikube。

```BASH
brew install minikube
```

查看 minikube 版本。

```BASH
minikube version
```

安裝 kubectl。

```BASH
brew install kubernetes-cli
```

查看 kubectl 版本。

```BASH
kubectl version
```

安裝 Helm 管理工具。

```BASH
brew install kubernetes-helm
```

查看 Helm 版本。

```BASH
helm version
```

為了從頭開始，使用以下指令將先前使用過的 minikube 痕跡清除。

```BASH
minikube stop; minikube delete; sudo rm -rf ~/.minikube; sudo rm -rf ~/.kube
```

## 範例專案

複製一份 [kenzanlabs/kubernetes-ci-cd](https://github.com/kenzanlabs/kubernetes-ci-cd) 專案到自己的儲存庫，並下載到工作目錄。

```BASH
git clone git@github.com:<YOUR_REPOSITORY>/kubernetes-ci-cd.git
```

## 啟動叢集

啟動一個 cluster。

```BASH
minikube start
```

- 使用 `--memory` 參數可以指定分配的記憶體。
- 使用 `--cpus` 參數可以指定分配的處理器。

啟用 [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) 附加元件，用來管理 cluster 中服務的外部存取。

```BASH
minikube addons enable ingress
```

檢查 cluster 內所有的 pods。

```BASH
kubectl get pods --all-namespaces
```

使用另一個終端機視窗輸入以下指令，開啟圖形化介面。

```BASH
minikube dashboard
```

試著將一個 Nginx 的 image 部署到一個 pod。

```BASH
kubectl run --generator=run-pod/v1 --image=nginx nginx-app --port=80
```

暴露這個 Nginx 的 pod。

```BASH
kubectl expose deployment nginx --type NodePort --port 80
```

開啟 Nginx 服務。

```BASH
minikube service nginx
```

刪除 Nginx 服務。

```BASH
kubectl delete service nginx
```

刪除 Nginx 部署。

```BASH
kubectl delete deployment nginx
```

## 本地映像檔儲存庫

為了建立一個本地的映像檔儲存庫，進到 kubernetes-ci-cd 專案，透過寫好的 YAML 文件啟動一個 pod。

```BASH
kubectl apply -f manifests/registry.yaml
```

- 如果出現錯誤，到原專案查看 [Pull Request](https://github.com/kenzanlabs/kubernetes-ci-cd/pulls) 可能需要被修正的項目。

查看儲存庫的部署狀態。

```BASH
kubectl rollout status deployments/registry
```

開啟 registry-ui 服務。

```BASH
minikube service registry-ui
```

試著更新一個應用程式，修改 `applications/hello-kenzan/index.html` 檔：

```HTML
Hello from Me!
```

建立一個帶有域名前綴的 Docker image。

```BASH
docker build -t 127.0.0.1:30400/hello-kenzan:latest -f applications/hello-kenzan/Dockerfile applications/hello-kenzan
```

在推送 image 之前，需要先啟動一個用來處理 proxy 的容器。

```BASH
docker run -d -e "REG_IP=`minikube ip`" -e "REG_PORT=30400" --name socat-registry -p 30400:5000 socat-registry
```

把 image 推送到儲存庫，並重新查看儲存庫的頁面，多了一個 hello-kenzan。

```BASH
docker push 127.0.0.1:30400/hello-kenzan:latest
```

將用來處理 proxy 的容器停止。

```BASH
docker stop socat-registry
```

透過另一個寫好的 YAML 文件部署 hello-kenzan 這個應用程式。

```BASH
kubectl apply -f applications/hello-kenzan/k8s/manual-deployment.yaml
```

開啟 hello-kenzan 服務，發現先前對應用程式修改的部分。

```BASH
minikube service hello-kenzan
```

刪除 hello-kenzan 服務。

```BASH
kubectl delete service hello-kenzan
```

刪除 hello-kenzan 部署。

```BASH
kubectl delete deployment hello-kenzan
```

告一段落，停止 minikube。

```BASH
minikube stop
```

## 參考資料

- [Set Up A CI/CD Pipeline With Kubernetes Part 1: Overview (deprecated)](https://www.linux.com/audience/enterprise/set-cicd-pipeline-kubernetes-part-1-overview/)
