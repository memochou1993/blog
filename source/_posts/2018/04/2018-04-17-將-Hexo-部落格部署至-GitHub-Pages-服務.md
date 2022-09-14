---
title: 將 Hexo 部落格部署至 GitHub Pages 服務
permalink: 將-Hexo-部落格部署至-GitHub-Pages-服務
date: 2018-04-17 10:15:43
tags: ["Hexo", "環境部署", "GitHub", "GitHub Pages"]
categories: ["靜態網頁生成器", "Hexo"]
---

## 環境

- Windows 7
- node 8.11.1
- npm 5.6.0
- git 2.17.0

## 安裝 Hexo

先確認電腦有安裝 `Node.js` 和 `git`。

```BASH
node -v
npm -v
git --version
```

將 Hexo 安裝在全域環境。

```BASH
npm install hexo -g
```

## 建立

建立一個 Hexo 部落格。

```BASH
hexo init blog
```

## 預覽

```BASH
hexo s
```

## 部署

在 GitHub 建立一個儲存庫 `blog`，並安裝 `hexo-deployer-git` 套件。

```BASH
npm install hexo-deployer-git --save
```

打開 `_config.yml` 檔，並更改為以下內容。

```ENV
# URL
url: https://memochou1993.github.io
root: /
# ...
# Deployment
deploy:
    type: git
    repository: git@github.com:memochou1993/blog.git
    branch: master
```

## 新增文章

```BASH
hexo n "New Post"
```

## 清除靜態網頁

```BASH
hexo clean
```

## 產生靜態網頁

```BASH
hexo g
```

## 發布

```BASH
hexo d
```
