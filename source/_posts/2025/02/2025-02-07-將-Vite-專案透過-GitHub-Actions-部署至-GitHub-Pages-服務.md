---
title: 將 Vite 專案透過 GitHub Actions 部署至 GitHub Pages 服務
date: 2025-02-07 03:12:58
tags: ["Programming", "JavaScript", "TypeScript", "Vite", "GitHub", "GitHub Pages", "GitHub Actions"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

首先，修改 `vite.config.ts` 檔，將 `base` 設置為以專案名稱為名的資料夾路徑。

```js
import path from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
  base: process.env.NODE_ENV === 'production'
    ? '/<REPO_NAME>/'
    : '/',
  resolve: {
    alias: {
      '~': path.resolve(__dirname, 'src'),
    },
  },
});
```

到 GitHub 的專案頁面，點選「Settings」頁籤，點選「Pages」選單，將「Source」設置為「GitHub Actions」。

然後，在專案的 `.github/workflows` 資料夾新增 `gh-pages.yaml` 檔。

```yaml
name: Deploy static content to Pages

on:
  push:
    branches: ['main']

  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: 'pages'
  cancel-in-progress: true

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Build
        run: npm run build
      - name: Setup Pages
        uses: actions/configure-pages@v4
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: './dist'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

推送程式碼。

```bash
git add .
git commit -m "Add deploy script"
git push
```

完成後，即可瀏覽網頁。

## 參考資料

- [Vite - GitHub Pages](https://vitejs.dev/guide/static-deploy.html#github-pages)
