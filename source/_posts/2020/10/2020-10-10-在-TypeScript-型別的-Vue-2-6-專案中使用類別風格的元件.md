---
title: 在 TypeScript 型別的 Vue 2.6 專案中使用類別風格的元件
date: 2020-10-10 16:12:42
tags: ["程式設計", "JavaScript", "Vue", "TypeScript"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 前言

Vue 對 TypeScript 已經有了很好的支援，可以使用兩種書寫方式，一種是基礎的寫法，另一種是類別風格的元件寫法。

### 基礎的寫法

基礎的寫法是使用 `Vue.component` 或 `Vue.extend` 方法，與原先的寫法沒有太大差異。

```js
import Vue from 'vue'

const Component = Vue.extend({
  // type inference enabled
})

const Component = {
  // this will NOT have type inference,
  // because TypeScript can't tell this is options for a Vue component.
}
```

### 類別風格的元件

使用類別風格的元件需要搭配 `vue-class-component` 套件，以及 `@` 裝飾器來使用。

```js
import Vue from 'vue'
import Component from 'vue-class-component'

// The @Component decorator indicates the class is a Vue component
@Component({
  // All component options are allowed in here
  template: '<button @click="onClick">Click!</button>'
})
export default class MyComponent extends Vue {
  // Initial data can be declared as instance properties
  message: string = 'Hello!'

  // Component methods can be declared as instance methods
  onClick (): void {
    window.alert(this.message)
  }
}
```

## 安裝套件

安裝以下套件。社群所開發的 `vue-property-decorator` 套件是基於官方所開發的 `vue-class-component` 套件的擴展。

```bash
yarn add vue-class-component
yarn add vue-property-decorator
```

## 範例

首先建立一個 TypeScript 型別的 Vue 專案。

```bash
vue create example
```

修改 `tsconfig.json` 檔，開啟編輯器對裝飾器的支援：

```json
{
  "compilerOptions": {
    "experimentalDecorators": true
  }
}
```

原先 `HelloWorld` 元件大致上如下：

```html
<template>
  <div>
    {{ msg }}
  </div>
</template>

<script lang="ts">
import Vue from 'vue';

export default Vue.extend({
  name: 'HelloWorld',
  props: {
    msg: String,
  },
});
</script>
```

改寫 `HelloWorld` 元件，修改為裝飾器的寫法：

```html
<template>
  <div>
    {{ msg }}
  </div>
</template>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator';

@Component
export default class HelloWorld extends Vue {
  @Prop() private msg!: string;
}
</script>
```

原先的 `Home` 視圖大致上如下：

```ts
<template>
  <div>
    <HelloWorld
      msg="Hello"
    />
  </div>
</template>

<script lang="ts">
import Vue from 'vue';
import HelloWorld from '@/components/HelloWorld.vue';

export default Vue.extend({
  name: 'Home',
  components: {
    HelloWorld,
  },
});
</script>
```

改寫 `Home` 視圖，修改為裝飾器的寫法：

```html
<template>
  <div>
    <HelloWorld
      msg="Hello"
    />
  </div>
</template>

<script lang="ts">
import { Vue, Component } from 'vue-property-decorator';
import HelloWorld from '@/components/HelloWorld.vue';

@Component({
  components: {
    HelloWorld,
  },
})

export default class Home extends Vue {}
</script>
```

## 參考資料

- [Vue - TypeScript Support](https://vuejs.org/v2/guide/typescript.html)
