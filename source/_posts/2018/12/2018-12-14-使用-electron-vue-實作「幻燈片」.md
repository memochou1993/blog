---
title: 使用 electron-vue 實作「幻燈片」
permalink: 使用-electron-vue-實作「幻燈片」
date: 2018-12-14 00:30:38
tags: ["程式設計", "JavaScript", "Vue", "Electron"]
categories: ["程式設計", "JavaScript", "Vue"]
---

## 環境

- macOS

## 安裝套件

```BASH
npm install -g vue-cli
vue init simulatedgreg/electron-vue electron-vue
```

## 新增路由

修改 `src\renderer\router\index.js` 檔：

```JS
import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'landing-page',
      component: require('@/components/LandingPage').default
    },
    {
      path: '/slide',
      name: 'slide',
      component: () => import('@/components/Slide')
    }
  ]
})
```

## 新增狀態管理

新增 `src/renderer/store/modules/Slide.js` 狀態管理。

```JS
const state = {
  api_url: 'http://www.splashbase.co/api/v1/images/random'
}

export default {
  state
}
```

## 新增元件

新增 `src/renderer/components/Slide.vue` 元件。

```HTML
<template>
  <div class="container">
    <Transition
      name="fade"
      enter-active-class="animated fadeIn"
      leave-active-class="animated fadeOut"
    >
      <img
        v-show="loaded"
        :src="img_url"
        class="image center"
        @load="isLoaded"
      >
    </Transition>
    <div v-show="!loaded">
      <img
        class="center"
        src="../assets/loading.gif"
      >
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      img_url: '',
      loaded: false
    }
  },
  created () {
    this.fetch()
  },
  methods: {
    fetch () {
      setInterval(function () {
        this.$http.get(this.$store.state.Slice.api_url)
          .then(({ data }) => {
            this.img_url = data.url
          })
      }.bind(this), 3000)
    },
    isLoaded () {
      this.loaded = true
    }
  }
}
</script>

<style lang="scss">
@import url('https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.7.0/animate.css');
.container {
  width: 100%;
  height: 100%;
}
.center {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}
.image {
  animation-duration: 0.25s;
  height: 100vh;
}
</style>
```

## 生成執行檔

```BASH
npm run build
```

## 程式碼

[GitHub](https://github.com/memochou1993/slide-electron-vue)
