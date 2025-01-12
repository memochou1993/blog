---
title: 使用 Node.js 執行 Shell 指令
date: 2022-11-28 22:22:25
tags: ["Programming", "JavaScript", "Node.js", "Shell"]
categories: ["Programming", "JavaScript", "Node.js"]
---

## 做法

新增 `index.js` 檔。

```js
const { execSync } = require('child_process');

execSync('echo "Hello, World!"', {
  stdio: 'inherit',
});
```

執行程式。

```bash
node index.js
```

輸出如下：

```bash
Hello, World!
```

## 參考資料

- [Node.js - documentation](https://nodejs.org/api/child_process.html)
