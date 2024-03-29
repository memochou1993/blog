---
title: 使用 gh-pages 套件將 React 專案部署至 GitHub Pages 服務
date: 2022-03-25 02:57:03
tags: ["Programming", "JavaScript", "React", "GitHub", "GitHub Pages"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

安裝 `gh-pages` 套件。

```bash
npm install gh-pages --save-dev
```

修改 `package.json` 檔，添加 `homepage` 內容。

```json
{
  "name": "my-app",
  "homepage": "https://<your-github-username>.github.io/my-app"
}
```

並且添加 `deploy` 指令。

```json
{
  "scripts": {
    "deploy": "gh-pages -d build"
  }
}
```

執行編譯。

```bash
npm run build
```

執行部署。

```bash
npm run deploy
```

## 參考資料

- [react-gh-pages](https://github.com/gitname/react-gh-pages)
