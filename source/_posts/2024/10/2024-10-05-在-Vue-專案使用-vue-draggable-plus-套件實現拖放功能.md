---
title: 在 Vue 專案使用 vue-draggable-plus 套件實現拖放功能
date: 2024-10-05 17:08:43
tags: ["Programming", "JavaScript"]
categories: ["Programming", "JavaScript", "Others"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest vue-draggable-plus-example -- --template vue
```

安裝套件。

```bash
npm install vue-draggable-plus
```

修改 `main.js` 檔，全域註冊 `VueDraggable` 元件。

```js
import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import { VueDraggable } from 'vue-draggable-plus';

createApp(App)
  .component('VueDraggable', VueDraggable)
  .mount('#app')
```

修改 `App.vue` 檔。

```html
<script setup>
import { ref } from 'vue';

const items = ref(Array.from({ length: 10 }, (v, i) => ({
  id: i + 1,
  name: `Item ${i + 1}`
})));
</script>

<template>
  <div>
    <div style="display: flex; justify-content: center;">
      <ul>
        <VueDraggable
          v-model="items"
          :animation="250"
          direction="vertical"
          @end="() => console.log('end')"
          @start="() => console.log('start')"
        >
          <li v-for="item in items" :key="item.id">
            {{ item.name }}
          </li>
        </VueDraggable>
      </ul>
    </div>
  </div>
</template>
```

啟動本地伺服器。

```bash
npm run dev
```

前往 <http://localhost:5173/> 瀏覽。

## 程式碼

- [vue-draggable-plus-example](https://github.com/memochou1993/vue-draggable-plus-example)

## 參考資料

- [Alfred-Skyblue/vue-draggable-plus](https://github.com/Alfred-Skyblue/vue-draggable-plus)
