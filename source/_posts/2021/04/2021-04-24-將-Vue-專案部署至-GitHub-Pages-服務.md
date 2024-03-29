---
title: 將 Vue 專案部署至 GitHub Pages 服務
date: 2021-04-24 21:19:10
tags: ["Programming", "JavaScript", "Vue", "GitHub", "GitHub Pages"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

修改 `vue.config.js` 檔，將 `publicPath` 設置為以專案名稱為名的資料夾路徑。

```js
module.exports = {
  publicPath: process.env.NODE_ENV === 'production'
    ? '/<REPO>/'
    : '/'
}
```

新增 `deploy.sh` 部署腳本。

```bash
#!/usr/bin/env sh

set -e
npm run build
cd dist

git init
git add -A
git commit -m 'deploy'
git push -f git@github.com:<USERNAME>/<REPO>.git master:gh-pages

cd -
```

執行部署腳本。

```bash
sh deploy.sh
```

最後，至專案的 GitHub Pages 頁面，將分支設置為 `gh-pages`。

## 參考資料

- [Vue CLI - Deployment](https://cli.vuejs.org/guide/deployment.html#github-pages)
