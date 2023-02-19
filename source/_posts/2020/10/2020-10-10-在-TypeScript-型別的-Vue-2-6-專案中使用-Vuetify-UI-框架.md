---
title: 在 TypeScript 型別的 Vue 2.6 專案中使用 Vuetify UI 框架
date: 2020-10-10 02:29:21
tags: ["程式設計", "JavaScript", "Vue", "Vuetify", "TypeScript"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 前言

Vuetify 的型別宣告定義在 `node_modules/vuetify/types` 中，因此 Vuetify 可以直接被使用在 TypeScript 型別的 Vue 專案裡。

## 做法

修改根目錄的 `tsconfig.json` 檔，將 `vuetify` 的型別宣告添加到 `types` 列表中。

```json
{
  "compilerOptions": {
    "types": [
      "vuetify"
    ]
  }
}
```

## 參考資料

- [Vuetify - Questions](https://vuetifyjs.com/en/getting-started/frequently-asked-questions/#questions)
- [TypeScript - tsconfig.json](https://www.tslang.cn/docs/handbook/tsconfig-json.html)
