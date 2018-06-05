---
title: 在 GitHub 上部署 Hexo 部落格
date: 2018-04-17 10:15:43
tags: ["程式寫作", "Hexo", "GitHub"]
---

## 環境
- Windows 7
- node 8.11.1
- npm 5.6.0
- git 2.17.0

## 安裝 Hexo
先確認電腦有安裝 `Node.js` 和 `git`。
```
$ node -v
$ npm -v
$ git --version
```
將 Hexo 安裝在全域環境。
```
$ npm install hexo -g
```
## 建立
建立一個 Hexo 部落格。
```
$ hexo init blog
```

## 預覽
```
$ hexo s
```

## 部署
在 GitHub 建立一個儲存庫 `blog`，並安裝 `hexo-deployer-git` 套件。
```
npm install hexo-deployer-git --save
```
打開 `_config.yml` 檔，並更改為以下內容。
```
# URL
url: https://memochou1993.github.io/blog
root: /blog/
...
# Deployment
deploy:
    type: git
    repository: git@github.com:memochou1993/blog.git
    branch: master
```

## 新增文章
```
$ hexo n "New Post"
```

## 清除靜態網頁
```
$ hexo clean
```

## 產生靜態網頁
```
$ hexo g
```

## 發布
```
$ hexo d
```