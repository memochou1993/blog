---
title: 使用 Deployer 為 Laravel 專案實現自動化測試與部署
permalink: 使用-Deployer-為-Laravel-專案實現自動化測試與部署
date: 2019-02-06 00:42:17
tags: ["環境部署", "CI/CD", "Linux", "Ubuntu", "Laravel"]
categories: ["環境部署", "CI/CD"]
---

## 環境

- Ubuntu（遠端伺服器）
- macOS（本機）

## 遠端伺服器

### 連線

連線至遠端伺服器。

```BASH
sh ec2.sh
```

### 新增使用者

新增 `deployer` 使用者。

```BASH
sudo adduser deployer --disabled-password
```

- 參數 `--disabled-password` 讓使用者無法使用密碼登入。

將 `deployer` 使用者加進 `nginx` 使用者所待的 `www-data` 群組。

```BASH
sudo adduser deployer www-data
```

### 設定權限

切換到 `deployer` 使用者，設定基礎權限。

```BASH
sudo su - deployer
echo "umask 022" >> ~/.bashrc
exit
```

為 `deployer` 使用者添加 sudo 權限。

```BASH
sudo vi /etc/sudoers
```

修改 `sudoers` 檔：

```ENV
# User privilege specification
root    ALL=(ALL:ALL) ALL
deployer ALL=(ALL) NOPASSWD: ALL
```

切換回 `deployer` 使用者，修改專案目錄權限。

```BASH
sudo su - deployer
sudo chown deployer:www-data /var/www
sudo chmod g+s /var/www
```

### 連線設定

新增 `~/.ssh` 資料夾，並設定權限。

```BASH
mkdir ~/.ssh
chmod 700 ~/.ssh
```

新增 `authorized_keys` 檔。

```BASH
touch ~/.ssh/authorized_keys
```

將遠端伺服器的公有金鑰的內容複製到 `authorized_keys` 檔。

```TEXT
ssh-rsa ...
```

設定金鑰權限。

```BASH
chmod 600 ~/.ssh/authorized_keys
```

### 建立儲存庫連線金鑰

新增 `id_rsa` 檔。

```BASH
touch ~/.ssh/id_rsa
```

將本機的私有金鑰 `aws.pem` 檔的內容複製到 `~/.ssh/id_rsa` 檔。

```TEXT
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```

新增 `id_rsa.pub` 檔。

```BASH
touch ~/.ssh/id_rsa
```

將 `authorized_keys` 檔的內容複製到 `~/.ssh/id_rsa.pub` 檔。

```BASH
cat ~/.ssh/authorized_keys >> ~/.ssh/id_rsa.pub
```

設定金鑰權限。

```BASH
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
```

### 儲存庫 SSH 設定

將 `id_rsa.pub` 檔的內容複製到儲存庫 SSH 設定。

```BASH
cat ~/.ssh/id_rsa.pub
```

## 本機

### 安裝 Deployer

使用 Composer 安裝 Deployer。

```BASH
composer global require deployer/deployer -vvv
```

### 建立專案

建立專案。

```BASH
laravel new laravel
```

初始化 Deployer。

```BASH
cd laravel
dep init
```

修改初始化 Deployer 後所生成的 `deploy.php` 檔：

```PHP
// ...
set('repository', 'git@xxx/laravel.git');

// ...

host('xx.xxx.xxx.xxx')
    ->user('deployer')
    ->identityFile('~/.ssh/aws.pem')
    ->set('deploy_path', '/var/www/laravel');
// ...
```

### 執行部署

在本機端的專案目錄執行以下指令：

```BASH
dep deploy -vvv
```
