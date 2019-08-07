---
title: 在 macOS 上安裝 PHP 的 Swoole 擴充套件
permalink: 在-macOS-上安裝-PHP-的-Swoole-擴充套件
date: 2019-01-24 11:45:02
tags: ["環境部署", "PHP", "Swoole", "macOS", "Laravel"]
categories: ["程式寫作", "PHP", "擴充套件"]
---

## 步驟

更新 PECL 倉庫。

```CMD
pecl channel-update pecl.php.net
```

安裝 PHP 的 Swoole 擴充套件。

```CMD
pecl install swoole
```

修改 `php.ini` 檔，並刪除第一行 `extension="swoole.so"`。

```CMD
vi /usr/local/etc/php/7.2/php.ini
```

新增 `swoole.ini` 檔。

```CMD
vi /usr/local/etc/php/7.2/conf.d/swoole.ini
```

加入以下內容：

```
[swoole]
extension="/usr/local/lib/php/pecl/20170718/swoole.so"
```

使用指令查看擴充套件是否安裝成功，或在 PHP 腳本中使用 `phpinfo()` 查看。

```CMD
php -m |grep swoole
swoole
$ php -i|grep extension_dir
extension_dir => /usr/local/lib/php/pecl/20170718 => /usr/local/lib/php/pecl/20170718
$ cd /usr/local/lib/php/pecl/20170718 && ls
```

查看詳細資訊。

```
vagrant@homestead:~$ php --ri swoole
```

## 錯誤處理

### openssl/ssl.h

出現 `openssl/ssl.h` 找不到的警告：

```TEXT
fatal error: 'openssl/ssl.h' file not found
```

確認 `openssl` 是否有安裝：

```CMD
brew search openssl
```

安裝 `openssl`：

```CMD
brew install openssl
Warning: openssl 1.0.2q is already installed and up-to-date
```

在標頭檔目錄建立 `openssl` 資料夾的軟連結：

```CMD
ln -s /usr/local/Cellar/openssl/1.0.2q/include/openssl /usr/local/include/
```

### openssl library

出現 `openssl library` 找不到的警告。

```
error: "Enable openssl support, require openssl library."
```

查看 `openssl` 詳細資訊。

```CMD
brew info openssl
```

設置環境變量。

```TEXT
For compilers to find openssl you may need to set:
  export LDFLAGS="-L/usr/local/opt/openssl/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl/include"
```

若仍然出現警告，則重新安裝 `openssl`。

```CMD
brew reinstall openssl
```

### extension

出現 `extension` 錯誤的警告：

```TEXT
swoole.so doesn't appear to be a valid Zend extension
```

使用：

```ENV
extension=swoole.so
```

不使用：

```
zend_extension=swoole.so
```
