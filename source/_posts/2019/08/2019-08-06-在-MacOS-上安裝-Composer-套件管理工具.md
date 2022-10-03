---
title: 在 macOS 上安裝 Composer 套件管理工具
date: 2019-08-06 23:24:09
tags: ["程式設計", "PHP", "Composer", "套件管理工具"]
categories: ["程式設計", "PHP", "其他"]
---

## 步驟

使用 `brew` 安裝 Composer。

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

## 指令

正式環境使用指令。

```BASH
composer install --prefer-dist --no-dev --no-scripts --no-suggest --optimize-autoloader
```

- `--prefer-dist` 參數，Composer 將從 `dist` 獲取。
- `--require-dev` 參數，Composer 將跳過 `require-dev` 列出的套件。
- `--no-scripts` 參數，Composer 將跳過 `composer.json` 文件中定義的腳本。
- `--no-suggest` 參數，Composer 將跳過 `composer.json` 文件中建議的套件。
- `--optimize-autoloader` 參數，轉換 PSR-0/4 autoloading 到 classmap，可以獲得更快的加載。特別是在正式環境下應該這麼做，但由於運行需要一段時間，因此沒有作為預設值。
