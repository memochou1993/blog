---
title: 在 Windows 上建立 Homestead 環境
date: 2018-04-28 10:16:27
tags: ["程式設計", "PHP", "Homestead"]
categories: ["程式設計", "PHP", "環境安裝"]
---

## 環境

- Windows 10
- 啟用硬體虛擬化（VT-x）

## 下載需要軟體

- 下載 VirtualBox 並安裝。
- 下載 Vagrant 並安裝。

## 安裝 Homestead

新增一個 `laravel/homestead` 盒子。

```BASH
vagrant box add laravel/homestead
```

從 Github 上下載 Homestead 下來。

```BASH
cd ~/
git clone https://github.com/laravel/homestead.git ~/Homestead
```

切換到想要的版本。

```BASH
cd Homestead
git checkout v7.4.0
```

初始化。

```BASH
init.bat
```

## 設定專案資料夾

打開 `Homestead.yaml` 檔，修改站台和共享資料夾等路徑。

```ENV
folders:
    - map: D:\Projects // 任意位置都可以
      to: /home/vagrant/Projects

sites:
    - map: homestead.test // 網站一
      to: /home/vagrant/Projects/laravel/public
    - map: test.test // 網站二
      to: /home/vagrant/Projects/test/public

databases:
    - homestead // 資料庫一
    - test // 資料庫二
```

## 註冊虛擬主機別名

編輯 C:\Windows\System32\drivers\etc\hosts 檔，新增以下虛擬主機路徑：

```ENV
192.168.10.10  homestead.test
192.168.10.10  test.test
```

## 啟動 Homestead

```BASH
cd ~/Homestead
vagrant up
```

## 登入 Homestead

如果沒有公開金鑰，先執行以下命令：

```BASH
ssh-keygen
```

再登入 Homestead。

```BASH
vagrant ssh
```

## 建立專案

如果沒有 Laravel 安裝器，先執行以下命令：

```BASH
composer global require "laravel/installer"
```

再建立專案。

```BASH
cd Projects
laravel new laravel
```

## 測試

使用瀏覽器測試 <http://homestead.test>，可以看見 Laravel 的歡迎頁面。

## 關閉 Homestead

關閉虛擬機。

```BASH
vagrant halt
```

暫停虛擬機。

```BASH
vagrant suspend
```
