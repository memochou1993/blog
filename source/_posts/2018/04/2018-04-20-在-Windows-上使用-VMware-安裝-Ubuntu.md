---
title: 在 Windows 上使用 VMware 安裝 Ubuntu
permalink: 在-Windows-上使用-VMware-安裝-Ubuntu
date: 2018-04-20 10:16:09
tags: ["環境部署", "Windows", "Linux", "Ubuntu"]
categories: ["環境部署", "Linux"]
---

## 環境

- Windows 7
- 啟用硬體虛擬化（VT-x）

## 下載需要軟體

- 下載 VMware Workstation 並安裝。
- 下載 Ubuntu 16 映像檔。

## 開始安裝

- 開啟 VMware Workstation 掛載 `ubuntu-16.04.4-desktop-amd64.iso` 映像檔。
- 設定處理器為 2 個。
- 每個處理器的核心數為 2 個。
- 記憶體為 4096 MB。
- 設定使用者名稱、帳號及密碼。

## 連上網路

- 停止虛擬機。
- 將 Ubuntu 64-bit 的 `Network Adapter` 設置為 `NAT`。

## 更新

- 登入圖形介面。
- 開啟終端機。
- 使用內建的 `apt-get` 指令完成更新。

```CMD
sudo apt-get update
```
