---
title: 使用 GitHub Actions 將 Vue 專案部署至 GitHub Pages 服務
date: 2023-02-17 20:48:01
tags: ["程式設計", "JavaScript", "Vue", "GitHub", "GitHub Pages", "GitHub Actions"]
categories: ["程式設計", "JavaScript", "環境部署"]
---

## 做法

首先，修改 `vite.config.js` 檔，將 `base` 設置為以專案名稱為名的資料夾路徑。

```js
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: process.env.NODE_ENV === 'production'
    ? '/<REPO_NAME>/'
    : '/',
});
```

到 GitHub 的專案頁面，點選「Settings」頁籤，點選「Actions」的「General」選單，將「Workflow permissions」設置為「Read and write permissions」。

然後，在專案的 `.github/workflows` 資料夾新增 `gh-pages.yaml` 檔。

```yaml
name: GitHub Pages

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  deploy:
    runs-on: ubuntu-latest
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
          publish_dir: ./dist
```

推送程式碼。

```bash
git add .
git commit -m "Add deploy script"
git push
```

再回到 GitHub 的專案頁面，點選「Settings」頁籤，將「Pages」的「Branch」設置為「gh-pages」。

## 參考資料

- [Vite - GitHub Pages](https://vitejs.dev/guide/static-deploy.html#github-pages)
- [actions-gh-pages](https://github.com/peaceiris/actions-gh-pages)
