---
title: 在 Vue 3.0 使用 Vuetify UI 框架
date: 2023-02-18 14:52:45
tags: ["Programming", "JavaScript", "Vue", "Vuetify"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 做法

建立專案。

```bash
npm create vite@latest my-app -- --template vue
cd my-app
```

安裝 Vuetify 框架。

```bash
npm i vuetify@^3.1.5
```

修改 `main.js` 檔。

```js
import { createApp } from 'vue';
import './style.css';
import 'vuetify/styles';
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';
import App from './App.vue';

const vuetify = createVuetify({
  components,
  directives,
});

createApp(App).use(vuetify).mount('#app');
```

修改 `HelloWorld.vue` 檔。

```html
<script setup>
import { ref } from 'vue';

defineProps({
  msg: {
    type: String,
    default: '',
  },
});

const count = ref(0);
</script>

<template>
  <h1>{{ msg }}</h1>
  <v-btn type="button" @click="count++">count is {{ count }}</v-btn>
</template>

<style scoped>
.read-the-docs {
  color: #888;
}
</style>
```

## 參考資料

- [Vuetify](https://next.vuetifyjs.com/en/getting-started/installation/)
