---
title: 使用 JavaScript 發布 NPM 套件
permalink: 使用-JavaScript-發布-NPM-套件
date: 2021-10-14 14:34:52
tags:
categories:
---

使用以下指令建立 `package.json` 檔：

```BASH
npm init
```

建立的 `package.json` 檔如下：

```JSON
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

修改 `package.json` 檔，指定只有 `dist` 資料夾中的內容需要被發布。

```JSON
{
  "main": "dist/index.js",
  "files": [
    "dist"
  ]
}
```

在 `index.js` 檔建立主程式：

```JS
const hello = () => {
  console.log('Hello');
};

module.exports = {
  hello,
};
```

測試發布，查看即將發布的檔案列表。

```BASH
npm publish --dry-run
```

登入 `npm` 套件管理平台。

```BASH
npm login
```

發布套件。

```BASH
npm publish --access=public
```
