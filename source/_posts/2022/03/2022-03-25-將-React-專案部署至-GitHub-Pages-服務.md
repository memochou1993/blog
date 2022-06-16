---
title: 將 React 專案部署至 GitHub Pages 服務
permalink: 將-React-專案部署至-GitHub-Pages-服務
date: 2022-03-25 02:57:03
tags: ["程式設計", "JavaScript", "React", "GitHub", "GitHub Pages"]
categories: ["程式設計", "JavaScript", "環境部署"]
---

## 做法

### 方法一

使用 `actions-gh-pages` 的 GitHub Action 樣板，在 `.github/workflows` 資料夾新增 `gh-pages.yaml` 檔。

```YAML
name: GitHub Pages

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  deploy:
    runs-on: ubuntu-20.04
    concurrency:
      group: ${{ github.workflow }}-${{ github.ref }}
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '14'

      - name: Cache dependencies
        uses: actions/cache@v2
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            ${{ runner.os }}-node-

      - run: npm ci
      - run: npm run build

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        if: ${{ github.ref == 'refs/heads/main' }}
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

推送程式碼。

```BASH
git add .
git commit -m "Add deploy script"
git push
```

### 方法二

安裝 `gh-pages` 套件。

```BASH
npm install gh-pages --save-dev
```

修改 `package.json` 檔，添加 `homepage` 內容。

```JSON
{
  "name": "my-app",
  "homepage": "https://<your-github-username>.github.io/my-app"
}
```

並且添加 `deploy` 指令。

```JSON
{
  "scripts": {
    "deploy": "gh-pages -d build"
  }
}
```

執行編譯。

```BASH
npm run build
```

執行部署。

```BASH
npm run deploy
```

## 參考資料

- [actions-gh-pages](https://github.com/peaceiris/actions-gh-pages)
- [react-gh-pages](https://github.com/gitname/react-gh-pages)
