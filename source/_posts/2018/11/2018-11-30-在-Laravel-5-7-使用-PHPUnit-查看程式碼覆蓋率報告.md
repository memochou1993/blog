---
title: 在 Laravel 5.7 使用 PHPUnit 查看程式碼覆蓋率報告
permalink: 在-Laravel-5-7-使用-PHPUnit-查看程式碼覆蓋率報告
date: 2018-11-30 14:27:38
tags: ["程式設計", "PHP", "Laravel", "Testing", "PHPUnit", "Xdebug", "Code Coverage"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 環境

- macOS
- xdebug 2.6.1

## 做法

執行 `phpunit` 指令，並加上 `--coverage-html` 參數，以及輸出路徑。

```BASH
phpunit --coverage-html ./report
```

修改 `phpunit.xml` 檔

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

```BASH
phpunit
```
