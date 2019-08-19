---
title: 在 Homestead 中安裝 phpMyAdmin 資料庫管理工具
permalink: 在-Homestead-中安裝-phpMyAdmin-資料庫管理工具
date: 2018-10-14 22:25:45
tags: ["環境部署", "Homestead", "phpMyAdmin", "資料庫"]
categories: ["環境部署", "Homestead"]
---

## 下載

下載 [phpMyAdmin](https://www.phpmyadmin.net/) 至專案資料夾。

## 編輯 Homestead.yaml 檔

```YAML
sites:
    - map: phpmyadmin.test
      to: /home/vagrant/Projects/phpmyadmin

databases:
    - phpmyadmin
```

重新執行設定檔。

```BASH
vagrant provision
```

## 登入

進入 [http://phpmyadmin.test](http://phpmyadmin.test)。

- 帳號：homestead
- 密碼：secret
