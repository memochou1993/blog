---
title: 使用 Deployer 為 PHP 專案實現自動化部署
permalink: 使用-Deployer-為-PHP-專案實現自動化部署
date: 2019-02-06 00:42:17
tags: ["環境部署", "Linux", "Ubuntu", "Deployer", "Laravel"]
categories: ["環境部署", "PHP"]
---

## 環境
- Ubuntu（遠端伺服器）
- macOS（本機）

## 遠端伺服器
### 連線
連線至遠端伺服器。
```
$ sh ec2.sh
```

### 新增使用者
新增一名使用者。
```
$ sudo adduser deployer --disabled-password
```
- 參數 `--disabled-password` 讓使用者無法使用密碼登入。

將 `deployer` 使用者加進 `nginx` 使用者所待的 `www-data` 群組。
```
$ sudo adduser deployer www-data
```

### 設定權限
切換到 `deployer` 使用者，設定基礎權限。
```
$ sudo su - deployer
$ echo "umask 022" >> ~/.bashrc
$ exit
```

切換到 `root` 使用者，為 `deployer` 使用者添加 sudo 權限。
```
$ sudo -s
$ vi /etc/sudoers
```

修改 `sudoers` 檔：
```
# User privilege specification
root    ALL=(ALL:ALL) ALL
deployer ALL=(ALL) NOPASSWD: ALL
```

切換回 `deployer` 使用者，修改專案目錄權限。
```
$ sudo su - deployer
$ sudo chown deployer:www-data /var/www
$ sudo chmod g+s /var/www
```

### 連線設定
新增 `~/.ssh` 資料夾，並設定權限。
```
$ mkdir ~/.ssh
$ chmod 700 ~/.ssh
```

新增 `authorized_keys` 檔，並設定權限。
```
$ touch .ssh/authorized_keys
$ chmod 600 .ssh/authorized_keys
```

將遠端伺服器的公有金鑰複製到 `authorized_keys` 檔。
```
ssh-rsa ...
```

### 建立儲存庫連線金鑰
生成金鑰。
```
$ ssh-keygen -t rsa -b 4096 -C "deployer@ubuntu"
```

將金鑰內容複製到儲存庫。
```
$ cat ~/.ssh/id_rsa.pub
```

## 本機
### 安裝 Deployer
使用 Composer 安裝 Deployer。
```
$ composer global require deployer/deployer -vvv
```

### 部署
在本機端的專案目錄執行以下指令：
```
$ dep deploy -vvv
```
