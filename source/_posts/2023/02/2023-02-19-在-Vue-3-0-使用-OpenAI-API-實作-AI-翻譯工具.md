---
title: 在 Vue 3.0 使用 OpenAI API 實作 AI 翻譯工具
date: 2023-02-19 15:08:34
tags: ["Programming", "JavaScript", "Vue", "GPT", "AI", "OpenAI"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest gpt-translator -- --template vue
cd gpt-translator
```

安裝 ESLint 套件。

```bash
npm i @vue/eslint-config-airbnb \
  eslint-import-resolver-typescript \
  -D
```

在專案根目錄新增 `.eslintrc.cjs` 檔：

```js
module.exports = {
  extends: [
    '@vue/airbnb',
  ],
  settings: {
    'import/resolver': {
      typescript: {},
    },
  },
  rules: {
  },
};
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

## 實作

安裝 Axios 套件。

```bash
npm i axios
```

新增 `api/index.js` 檔。

```js
import axios from 'axios';

export const PARTICIPANT_AI = 'AI';
export const PARTICIPANT_HUMAN = 'Human';

export const FINISH_REASON_STOP = 'stop';
export const FINISH_REASON_LENGTH = 'length';

const newClient = (key) => axios.create({
  baseURL: 'https://api.openai.com',
  headers: {
    Authorization: `Bearer ${key}`,
  },
});

const createCompletion = (client) => ({
  model = 'text-davinci-003',
  prompt,
  temperature = 0.9,
  maxTokens = 160,
  frequencyPenalty = 0,
  presencePenalty = 0.6,
  stop = [
    ` ${PARTICIPANT_AI}:`,
    ` ${PARTICIPANT_HUMAN}:`,
  ],
}) => client.post('/v1/completions', {
  model,
  prompt,
  temperature: Number(temperature),
  max_tokens: Number(maxTokens),
  frequency_penalty: Number(frequencyPenalty),
  presence_penalty: Number(presencePenalty),
  stop,
});

export {
  newClient,
  createCompletion,
};
```

修改 `App.vue` 檔。

```js
<template>
  <v-app>
    <v-main class="d-flex align-center bg-blue-grey-lighten-1">
      <v-container>
        <TheTranslator title="GPT Translator" />
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup>
import TheTranslator from './components/TheTranslator.vue';
</script>
```

新增 `TheTranslator.vue` 檔。

```html
<script setup>
import { reactive, computed } from 'vue';
import {
  createCompletion, newClient, PARTICIPANT_AI, PARTICIPANT_HUMAN,
} from '../api';

defineProps({
  title: {
    type: String,
    default: '',
  },
});

const data = reactive({
  key: '',
  question: '',
  answer: '',
});

const prompt = computed(() => `${PARTICIPANT_HUMAN}: 請將以下內容翻譯成英文：「${data.question}」。\n${PARTICIPANT_AI}:`);

const translate = async () => {
  const client = newClient(data.key);
  const res = await createCompletion(client)({
    prompt: prompt.value,
    maxTokens: data.key.length * 4,
  });
  const { choices } = res.data;
  const [choice] = choices;
  const { text } = choice;
  data.answer = text.trim();
};
</script>

<template>
  <v-card>
    <v-card-title>
      {{ title }}
    </v-card-title>
    <v-card-item>
      <v-textarea
        v-model="data.question"
        variant="outlined"
      />
      <v-textarea
        v-model="data.answer"
        variant="outlined"
      />
      <v-text-field
        v-model="data.key"
        label="Key"
        type="password"
        variant="outlined"
      />
    </v-card-item>
    <v-card-actions class="text-center">
      <v-spacer />
      <v-btn
        @click="translate"
      >
        Translate
      </v-btn>
    </v-card-actions>
  </v-card>
</template>
```

## 程式碼

- [gpt-translator](https://github.com/memochou1993/gpt-translator)
