---
title: 使用 JavaScript 發布 npm 套件
date: 2021-10-14 14:34:52
tags: ["Programming", "JavaScript", "npm"]
categories: ["Programming", "JavaScript", "Others"]
---

使用以下指令建立 `package.json` 檔：

```bash
npm init
```

建立的 `package.json` 檔如下：

```json
{
  "name": "@memochou1993/example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
```

修改 `package.json` 檔，指定特定內容需要被發布。

```json
{
  "main": "index.js",
  "files": [
    "index.js"
  ]
}
```

在 `index.js` 檔建立主程式：

```js
const hello = () => {
  console.log('Hello');
};

export {
  hello,
};
```

測試發布，查看即將發布的檔案列表。

```bash
npm publish --dry-run
```

登入 `npm` 套件管理平台。

```bash
npm login
```

發布套件。

```bash
npm publish --access=public
```
