---
title: 在 Vue 2.5 使用 Firebase 實現認證機制
permalink: 在-Vue-2-5-使用-Firebase-實現認證機制
date: 2018-12-19 14:06:01
tags: ["程式寫作", "JavaScript", "Vue", "Firebase"]
categories: ["程式寫作", "JavaScript", "Vue"]
---

## 環境

- macOS

## 建立專案

```BASH
vue create firebase-auth-vue
```

## 安裝套件

```BASH
npm install ——save firebase
```

## 建立應用程式

在 Firebase 建立應用程式，啟用「登入方式」的「電子郵件/密碼」。

## 設定

新增 `.env.development.local` 檔：

```ENV
VUE_APP_FIREBASE_API_KEY=YOUR_API_KEY
VUE_APP_FIREBASE_AUTH_DOMAIN=YOUR_AUTH_DOMAIN
VUE_APP_FIREBASE_DATABASE_URL=YOUR_DATABASE_URL
VUE_APP_FIREBASE_PROJECT_ID=YOUR_PROJECT_ID
VUE_APP_FIREBASE_STORAGE_BUCKET=YOUR_STORAGE_BUCKET
VUE_APP_FIREBASE_MESSAGING_SENDER_ID=YOUR_MESSAGING_SENDER_ID
```

修改 `src/main.js` 檔：

```JS
import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";
import firebase from "firebase";

Vue.config.productionTip = false;

let app = null;

// Initialize Firebase
firebase.initializeApp({
  apiKey: process.env.VUE_APP_FIREBASE_API_KEY,
  authDomain: process.env.VUE_APP_FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.VUE_APP_FIREBASE_DATABASE_URL,
  projectId: process.env.VUE_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.VUE_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.VUE_APP_FIREBASE_MESSAGING_SENDER_ID
});

firebase.auth().onAuthStateChanged(() => {
  if (!app) {
    app = new Vue({
      router,
      store,
      render: h => h(App)
    }).$mount("#app");
  }
});
```

## 新增路由

修改 `src/router.js` 檔：

```JS
import Vue from "vue";
import Router from "vue-router";
import firebase from "firebase";

Vue.use(Router);

const router = new Router({
  routes: [
    {
      path: "*",
      redirect: {
        name: "Login"
      }
    },
    {
      path: "/",
      redirect: {
        name: "Login"
      }
    },
    {
      path: "/home",
      name: "Home",
      component: () => import("./views/Home.vue"),
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/login",
      name: "Login",
      component: () => import("./views/Login.vue")
    },
    {
      path: "/register",
      name: "Register",
      component: () => import("./views/Register.vue")
    }
  ]
});

router.beforeEach((to, from, next) => {
  const currentUser = firebase.auth().currentUser;
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);

  if (requiresAuth && !currentUser) {
    next({ name: "Login" });
  } else if (!requiresAuth && currentUser) {
    next({ name: "Home" });
  } else {
    next();
  }
});

export default router;
```

## 建立元件

新增 `src/views/Login.vue` 檔。

```HTML
<template>
  <div class="login">
    <h3>Sign In</h3>
    <form
      @submit.prevent="login()">
      <input
        v-model="email"
        type="text"
        name="email"><br>
      <input
        v-model="password"
        type="password"
        name="password"><br>
      <input
        type="submit"><br>
      {{ message }}
    </form>
  </div>
</template>

<script>
import firebase from "firebase";

export default {
  name: "Login",
  data() {
    return {
      email: "",
      password: "",
      message: ""
    };
  },
  methods: {
    login() {
      firebase
        .auth()
        .signInWithEmailAndPassword(this.email, this.password)
        .then(() => {
          this.$router.replace({ name: "Home" });
        })
        .catch(({ message }) => {
          this.message = message;
        });
    }
  }
};
</script>
```

新增 `src/views/Register.vue` 檔。

```HTML
<template>
  <div
    class="register">
    <h3>Sign Up</h3>
    <form
      @submit.prevent="register()">
      <input
        v-model="email"
        type="text"
        name="email"><br>
      <input
        v-model="password"
        type="password"
        name="password"><br>
      <input
        type="submit"><br>
      {{ message }}
    </form>
  </div>
</template>

<script>
import firebase from "firebase";

export default {
  name: "Register",
  data() {
    return {
      email: "",
      password: "",
      message: ""
    };
  },
  methods: {
    register() {
      firebase
        .auth()
        .createUserWithEmailAndPassword(this.email, this.password)
        .then(() => {
          this.$router.replace({ name: "Home" });
        })
        .catch(({ message }) => {
          this.message = message;
        });
    }
  }
};
</script>
```

新增 `src/components/Toolbar.vue` 檔。

```HTML
<template>
  <div id="nav">
    <RouterLink :to="{ name:'Home' }">Home</RouterLink> |
    <RouterLink :to="{ name:'Login' }">Login</RouterLink> |
    <RouterLink :to="{ name:'Register' }">Register</RouterLink> |
    <a href="#" @click.prevent="logout()">Logout</a>
  </div>
</template>

<script>
import firebase from "firebase";

export default {
  methods: {
    logout() {
      firebase
        .auth()
        .signOut()
        .then(() => {
          this.$router.push({ name: "Login" });
        });
    }
  }
};
</script>
```

修改 `src/App.vue` 檔：

```HTML
<template>
  <div id="app">
    <Toolbar/>
    <RouterView/>
  </div>
</template>

<script>
import Toolbar from "@/components/Toolbar";

export default {
  components: {
    Toolbar
  }
};
</script>
```

## 參考資料

[Vue 2 + Firebase: How to build a Vue app with Firebase authentication system in 15 minutes](vue-2-firebase-how-to-build-a-vue-app-with-firebase-authentication-system-in-15-minutes-fdce6f289c3c)
