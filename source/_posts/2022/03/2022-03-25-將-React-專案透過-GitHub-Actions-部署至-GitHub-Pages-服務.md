---
title: 將 React 專案透過 GitHub Actions 部署至 GitHub Pages 服務
date: 2022-03-25 02:57:03
tags: ["Programming", "JavaScript", "React", "GitHub", "GitHub Pages", "GitHub Actions"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

首先，到專案的「Settings」頁面，將「Workflow permissions」設置為「Read and write permissions」。

在專案的 `.github/workflows` 資料夾新增 `gh-pages.yaml` 檔。

```yaml
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

```bash
git add .
git commit -m "Add deploy script"
git push
```

## 參考資料

- [actions-gh-pages](https://github.com/peaceiris/actions-gh-pages)
