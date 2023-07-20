---
title: 使用 Linode 的 Firewalls 防火牆過濾網路流量
date: 2023-07-21 01:51:40
tags: ["環境部署", "Linode"]
categories: ["雲端運算服務", "Linode"]
---

## 做法

在 Linode 新增一個 Firewall 防火牆，並選擇指定的虛擬主機。

以「阻擋外部流量存取 5000 埠號」為例，在 Inbound Rules 區塊，新增一個規則如下：

- Label: accept-inbound-HTTP
- Protocol: TCP
- Port Range: 5000
- Sources: All IPv4, All IPv6
- Action: Drop

最後，點選「Save Changes」按鈕。
