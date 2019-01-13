---
title: 在 Laravel 5.7 使用 PHPUnit 查看程式碼覆蓋率
permalink: 在-Laravel-5-7-使用-PHPUnit-查看程式碼覆蓋率
date: 2018-11-30 14:27:38
tags: ["程式寫作", "PHP", "Laravel", "除錯", "PHPUnit", "Xdebug"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 環境
- macOS High Sierra

## 安裝套件
安裝 PHP 的 Xdebug 擴充套件。
```
$ pecl install xdebug
```
修改 `php.ini` 檔。
```
$ vi /usr/local/etc/php/7.2/php.ini
```
刪除第一行 `zend_extension="xdebug.so"`，並儲存。

新增 `xdebug.so` 檔。
```
$ vi /usr/local/etc/php/7.2/conf.d/xdebug.ini
```
加入以下內容：
```
[xdebug]
zend_extension="/usr/local/lib/php/pecl/20170718/xdebug.so"
```
重啟 PHP 服務。

使用指令或 `phpinfo()` 查看擴充套件是否安裝成功。
```
vagrant@homestead:~$ php -m
```

## 查看程式碼覆蓋率
### 使用指令
執行 `phpunit` 指令，並加上 `--coverage-html` 參數，以及輸出路徑。
```
$ phpunit --coverage-html ./report
```
### 修改 `phpunit.xml` 檔。
```XML
<phpunit backupGlobals="false"
         backupStaticAttributes="false"
         bootstrap="bootstrap/autoload.php"
         colors="true"
         convertErrorsToExceptions="true"
         convertNoticesToExceptions="true"
         convertWarningsToExceptions="true"
         processIsolation="false"
         stopOnFailure="false"
         syntaxCheck="true"
>
    ...
    <logging>
        <log type="coverage-html"
             target="./report"
             charset="UTF-8"
             highlight="true"
             lowUpperBound="50"
             highLowerBound="80"/>
    </logging>
</phpunit>
```
執行 `phpunit` 指令。
```
$ phpunit
```