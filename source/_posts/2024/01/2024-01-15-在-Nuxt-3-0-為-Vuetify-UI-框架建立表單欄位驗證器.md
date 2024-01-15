---
title: 在 Nuxt 3.0 為 Vuetify UI 框架建立表單欄位驗證器
date: 2024-01-15 23:10:26
tags: ["Programming", "JavaScript", "Nuxt", "Vue", "Vuetify"]
categories: ["Programming", "JavaScript", "Nuxt"]
---

## 建立專案

建立專案。

```bash
npx nuxi@latest init nuxt-vuetify-validator
cd nuxt-vuetify-validator
```

安裝 Vuetify 框架。

```bash
npm i -D vuetify vite-plugin-vuetify sass
```

建立 `plugins/vuetify.js` 檔。

```js
import { createVuetify } from 'vuetify';
import 'vuetify/styles';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';
import '@mdi/font/css/materialdesignicons.css';

export default defineNuxtPlugin((nuxtApp) => {
  const vuetify = createVuetify({
    ssr: true,
    components,
    directives,
  });
  nuxtApp.vueApp.use(vuetify);
});
```

修改 `nuxt.config.js` 檔。

```js
// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: {
    enabled: true,
  },
  build: {
    transpile: ['vuetify'],
  },
});
```

## 實作

建立 `validator` 資料夾。

```bash
mkdir validator
```

建立 `validator/rules/index.js` 檔。

```js
const isEmpty = (v) => v === '' || v === null || v === undefined || (Array.isArray(v) && !v.length);

const required = () => (v) => !isEmpty(v);

const email = () => (v) => isEmpty(v) || /.+@.+\..+/.test(v);

const alphaDash = () => (v) => isEmpty(v) || /^[a-zA-Z0-9-_]+$/.test(v);

const alphaDashDot = () => (v) => isEmpty(v) || /^[a-zA-Z0-9-_.]+$/.test(v);

const lowercaseNumUnderscore = () => (v) => isEmpty(v) || /^[a-z0-9_]+$/.test(v);

const uppercaseNumUnderscore = () => (v) => isEmpty(v) || /^[A-Z0-9_]+$/.test(v);

const min = (minValue) => (v) => isEmpty(v) || parseFloat(v) >= minValue;

const max = (maxValue) => (v) => isEmpty(v) || parseFloat(v) <= maxValue;

const minLength = (length) => (v) => isEmpty(v) || v.length >= length;

const maxLength = (length) => (v) => isEmpty(v) || v.length <= length;

const minFileSize = (minValue) => (v) => isEmpty(v) || v.every((file) => file.size >= minValue * 1024 * 1024);

const maxFileSize = (maxValue) => (v) => isEmpty(v) || v.every((file) => file.size <= maxValue * 1024 * 1024);

const url = () => (v) => isEmpty(v) || /^(http|https):\/\/.+$/.test(v);

const unique = (items, ignored) => (v) => isEmpty(v) || (v === ignored) || !items.includes(v);

const json = () => (v) => {
  if (isEmpty(v)) return true;
  try {
    JSON.parse(v);
    return true;
  } catch (e) {
    return false;
  }
};

export default {
  required,
  email,
  alphaDash,
  alphaDashDot,
  lowercaseNumUnderscore,
  uppercaseNumUnderscore,
  min,
  max,
  minLength,
  maxLength,
  minFileSize,
  maxFileSize,
  url,
  unique,
  json,
};
```

建立 `validator/field-validator.js` 檔。

```js
import rules from './rules';

class FieldValidator {
  constructor(name, messages) {
    this.name = name.toLowerCase();
    this.messages = messages;
    this.rules = [];
    this.isPassed = false;
  }

  getRule(name, ...args) {
    return (v) => rules[name](...args)(v) || this.messages[name](this.name, ...args);
  }

  getRules() {
    return this.isPassed ? [] : this.rules;
  }

  pushRule(name, ...args) {
    const rule = this.getRule(name, ...args);
    this.rules.push(rule);
    return this;
  }

  when(condition) {
    if (!condition) {
      this.isPassed = true;
    }
    return this;
  }

  required() {
    return this.pushRule('required');
  }

  email() {
    return this.pushRule('email');
  }

  alphaDash() {
    return this.pushRule('alphaDash');
  }

  alphaDashDot() {
    return this.pushRule('alphaDashDot');
  }

  lowercaseNumUnderscore() {
    return this.pushRule('lowercaseNumUnderscore');
  }

  uppercaseNumUnderscore() {
    return this.pushRule('uppercaseNumUnderscore');
  }

  min(minValue) {
    return this.pushRule('min', minValue);
  }

  max(maxValue) {
    return this.pushRule('max', maxValue);
  }

  minLength(length) {
    return this.pushRule('minLength', length);
  }

  maxLength(length) {
    return this.pushRule('maxLength', length);
  }

  minFileSize(length) {
    return this.pushRule('minFileSize', length);
  }

  maxFileSize(length) {
    return this.pushRule('maxFileSize', length);
  }

  url() {
    return this.pushRule('url');
  }

  unique(items, ignored) {
    return this.pushRule('unique', items, ignored);
  }

  json() {
    return this.pushRule('json');
  }
}

export default FieldValidator;
```

建立 `validator/locales/en.js` 檔。

```js
export default {
  required: (field) => `The ${field} field is required.`,
  email: (field) => `The ${field} field must be a valid email address.`,
  alphaDash: (field) => `The ${field} field must only contain letters, digits and underscores.`,
  alphaDashDot: (field) => `The ${field} field must only contain letters, digits, underscores and dots.`,
  lowercaseNumUnderscore: (field) => `The ${field} field must only contain lowercase letters, digits and underscores.`,
  uppercaseNumUnderscore: (field) => `The ${field} field must only contain uppercase letters, digits and underscores.`,
  min: (field, value) => `The ${field} field must be at least ${value}.`,
  max: (field, value) => `The ${field} field must not be greater than ${value}.`,
  minLength: (field, length) => `The ${field} field must be at least ${length} characters.`,
  maxLength: (field, length) => `The ${field} field must not be greater than ${length} characters.`,
  minFileSize: (field, value) => `The ${field} field must be at least ${value} megabytes.`,
  maxFileSize: (field, value) => `The ${field} field must not be greater than ${value} megabytes.`,
  url: (field) => `The ${field} field must be a valid URL.`,
  unique: (field) => `The ${field} has already been taken.`,
  json: (field) => `The ${field} field must be a valid JSON string.`,
};
```

建立 `validator/locales/index.js` 檔。

```js
import en from './en';

export default {
  en,
};
```

建立 `validator/validator.js` 檔。

```js
import FieldValidator from './field-validator';
import locales from './locales';

class Validator {
  constructor() {
    this.locale = 'en';
  }

  get messages() {
    return locales[this.locale];
  }

  setLocale(locale) {
    this.locale = locale;
    return this;
  }

  createField(name) {
    return new FieldValidator(name, this.messages);
  }
}

const validator = new Validator();

export default validator;
```

建立 `validator/validator.js` 檔。

```js
import validator from './validator';

export default validator;
```

## 註冊

在 `plugins` 資料夾，建立 `validator.js` 檔。

```js
import validator from '~/validator';

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.provide('validator', validator);
});
```

## 使用

修改 `app.vue` 檔。

```html
<template>
  <div>
    <v-form>
      <v-text-field
        :rules="(
          $validator
            .createField('email')
            .required()
            .email()
            .getRules()
        )"
      />
    </v-form>
  </div>
</template>
```

啟動服務。

```bash
npm run dev
```

## 程式碼

- [nuxt-vuetify-validator](https://github.com/memochou1993/nuxt-vuetify-validator)
