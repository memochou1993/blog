---
title: 在 macOS 上安裝並使用 Node.js 和 npm 套件管理工具
date: 2019-08-06 23:32:12
tags: ["Programming", "JavaScript", "Node.js", "npm", "Package Manager"]
categories: ["Programming", "JavaScript", "Node.js"]
---

## 前言

nvm 可以用於管理不同的 Node 版本，同時也會安裝 npm 套件管理工具。

## 做法

使用 `curl` 指令安裝 nvm。

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

確認 nvm 的版本。

```bash
nvm --version
```

重新讀取 `.bashrc` 檔。

```bash
source .bashrc
```

安裝 Node 的穩定版本。

```bash
nvm install --lts
```

指定 Node 的穩定版本。

```bash
nvm use --lts
```

指定 Node 的穩定版本做為預設版本。

```bash
nvm alias default stable
```

確認 npm 的版本。

```bash
npm --version
```

## 參考資料

- [nvm-sh/nvm](https://github.com/nvm-sh/nvm)
