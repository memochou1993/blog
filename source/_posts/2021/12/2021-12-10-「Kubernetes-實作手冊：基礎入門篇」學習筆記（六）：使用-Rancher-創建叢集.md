---
title: 「Kubernetes 實作手冊：基礎入門篇」學習筆記（六）：使用 Rancher 創建叢集
date: 2021-12-10 15:18:44
tags: ["Deployment", "Kubernetes", "Docker", "Rancher"]
categories: ["Deployment", "Kubernetes", "「Kubernetes 實作手冊：基礎入門篇」Study Notes"]
---

## 前言

本文為「Kubernetes 實作手冊：基礎入門篇」課程的學習筆記。

## 簡介

Rancher 是一個開源專案，用於部署及管理多個 Kubernetes 叢集，可以擴縮 Kubernetes 節點數量。Rancher 提供各式各樣的 CI/CD 工具，並且支援各種外掛。

## 安裝

先啟動全新的虛擬環境。

```bash
vagrant destroy
vagrant up
```

在虛擬機器中啟動一個 Rancher 服務。

```bash
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:v2.3.5
```

取得 Docker 容器列表，會有 Rancher 容器。

```bash
docker ps
```

前往 <http://172.17.8.111/> 瀏覽。

## 創建叢集

設定密碼後登入，並執行以下步驟創建叢集。

1. 點選「Add Cluster」創建叢集。
2. 輸入叢集名稱：「sandbox」。
3. 選擇 Kubernetes 版本：「v1.17.4」。
4. 選擇 Network Provider：「Flannel」。
5. 選擇 Cloud Provider：「Custom」。
6. 選擇 Nginx Ingress：「Disabled」（保持簡單）。
7. 點選「Next」後，在 Node Role 開啟 etch、Control Plane 和 Worker 角色。
8. 複製命令，點選「Done」。

最後，執行複製的命令：

```bash
sudo docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.3.5 --server https://172.17.8.111 --token w64695bzdlc455zd2dzg9dtggkq7ghfsfbdsj4jrtzjnl6gg78xtr2 --ca-checksum 5b91fdf12485553473d7496d6c00afd812cc1a1c964754ec460a8488cfb2f55b --etcd --controlplane --worker
```

- 此 IP 位址定義在 `Vagrantfile` 檔案中。

從 UI 介面可以看到叢集已經被創建。

## 參考資料

- [Kubernetes 實作手冊：基礎入門篇](https://hiskio.com/courses/349/about)
