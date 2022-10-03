---
title: 使用 Kubernetes 和 Jenkins 為應用程式建立自動化部署（二）
date: 2020-04-12 20:17:01
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

啟動 minikube。

```BASH
minikube start
```

## 持續整合工具

進到 kubernetes-ci-cd 專案，用寫好的 YAML 文件建立一個 Jenkins 容器。

```BASH
docker build -t 127.0.0.1:30400/jenkins:latest -f applications/jenkins/Dockerfile applications/jenkins
```

- 注意 Dockerfile 中的 `jenkins/jenkins` 映像檔版本不要低於 2.226。

再次將處理 proxy 的容器啟動。

```BASH
docker start socat-registry
```

將 Jenkins 的 Docker image 推送到本地的映像檔儲存庫。

```BASH
docker push 127.0.0.1:30400/jenkins:latest
```

開啟儲存庫的頁面，會看到 Jenkins 出現在列表上。

```BASH
minikube service registry-ui
```

將用來處理 proxy 的容器停止。

```BASH
docker stop socat-registry
```

再使用寫好的 YAML 文件，部署一個 Jenkins 應用程式。

```BASH
kubectl apply -f manifests/jenkins.yaml
```

查看 Jenkins 的部署狀態。

```BASH
kubectl rollout status deployments/jenkins
```

- 如果出現錯誤，到原專案查看 [Pull Request](https://github.com/kenzanlabs/kubernetes-ci-cd/pulls) 可能需要被修正的項目。

開啟 Jenkins 服務。

```BASH
minikube service jenkins
```

印出 Jenkins 初始密碼。

```BASH
kubectl exec -it `kubectl get pods --selector=app=jenkins --output=jsonpath={.items..metadata.name}` cat /var/jenkins_home/secrets/initialAdminPassword
```

將密碼輸入後，點選「Install suggested plugins」安裝相關套件。

建立一組使用者帳號，並點選「Save and Continue」，最後點選「Restart」（如果畫面沒有更新，則重新整理頁面）。

## 安裝套件

登入 Jenkins 後，先到 Plugin Manager 頁面安裝 Kubernetes Continuous Deploy 套件。

為了讓 Jenkins 能夠存取 Kubernetes 的 cluster，需要提供一組 kubeconfig 設定檔。點選「Credentials」，選擇「Jenkins」的「Global credentials」選項，然後點選「Add Credentials」。

新增以下內容：

- Kind: Kubernetes configuration (kubeconfig)
- ID: kenzan_kubeconfig
- Kubeconfig: From a file on the Jenkins master
- File: /var/jenkins_home/.kube/config

最後點選「Ok」。

## 建置流程

回到首頁後，進行以下操作：

1. 點選「New Item」；
2. 輸入名稱「Hello-Kenzan Pipeline」，並選擇「Pipeline」選項；
3. 將「Pipeline」區塊的「Definition」設定為「Pipeline script from SCM」；
4. 將「SCM」設定為「Git」；
5. 將「Repository URL」設定為：https://github.com/&lt;YOUR_REPOSITORY&gt;/kubernetes-ci-cd

由於 `Jenkinsfile` 已經被寫好在專案的根目錄，因此點選「Save」。

## 執行部署

點選「Build Now」執行 pipeline。

如果失敗：

- 可能是 YAML 文件的問題，到原專案查看 [Pull Request](https://github.com/kenzanlabs/kubernetes-ci-cd/pulls) 可能需要被修正的項目。
- 可能是 executor 的問題，到 Manage Nodes 頁面，將 master 的「# of executors」設定為 1 或更多。

Jenkins 會從 GitHub 將程式碼拉取下來，並建立映像檔後進行部署。

最後，啟動 hello-kenzan 服務。

```BASH
minikube service hello-kenzan
```

## 參考資料

- [Set Up A CI/CD Pipeline With A Jenkins Pod In Kubernetes (deprecated)](https://www.linux.com/audience/devops/set-cicd-pipeline-jenkins-pod-kubernetes-part-2/)
