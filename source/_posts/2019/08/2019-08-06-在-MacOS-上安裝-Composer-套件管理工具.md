---
title: 在 MacOS 上安裝 Composer 套件管理工具
permalink: 在-MacOS-上安裝-Composer-套件管理工具
date: 2019-08-06 23:24:09
tags: ["Composer", "PHP"]
categories: ["其他", "套件管理工具"]
---

## 步驟

使用 `brew` 指令安裝 Composer。

```BASH
brew install composer
```

將 Composer 的套件執行檔寫進環境變數。

```BASH
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
```

重新讀取 `.bashrc` 檔。

```BASH
source .bashrc
```

確認 Composer 的版本。

```BASH
composer --version
```
