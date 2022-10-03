---
title: 在 macOS 上安裝 Node 和 npm 套件管理工具
date: 2019-08-06 23:32:12
tags: ["程式設計", "JavaScript", "Node", "npm", "套件管理工具"]
categories: ["程式設計", "JavaScript", "Node"]
---

## 前言

nvm 可以用於管理不同的 Node 版本，同時也會安裝 npm 套件管理工具。

## 步驟

使用 `curl` 指令安裝 nvm。

```BASH
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

確認 nvm 的版本。

```BASH
nvm --version
```

重新讀取 `.bashrc` 檔。

```BASH
source .bashrc
```

安裝 Node 的穩定版本。

```BASH
nvm install --lts
```

指定 Node 的穩定版本。

```BASH
nvm use --lts
```

指定 Node 的穩定版本做為預設版本。

```BASH
nvm alias default stable
```

確認 npm 的版本。

```BASH
npm --version
```

## 參考資料

- [nvm-sh/nvm](https://github.com/nvm-sh/nvm)
