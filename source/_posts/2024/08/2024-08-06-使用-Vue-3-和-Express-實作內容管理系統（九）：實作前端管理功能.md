---
title: 使用 Vue 3 和 Express 實作內容管理系統（九）：實作前端管理功能
date: 2024-08-06 00:17:22
tags: ["Programming", "JavaScript", "Vue", "Bootstrap", "Node", "Express", "Firebase", "Firestore", "CMS"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

本文是前端工作坊的教學文件，介紹如何使用 Vue 3 和 Express 實作內容管理系統，並搭配 Firebase 實現持久化和認證。

## 開啟專案

開啟前端專案。

```bash
cd simple-cms-ui
code .
```

## 串接 API

### 修改列表頁面

修改 `CustomerListView.vue` 檔，將假資料移除，改為呼叫後端 API 取得真實資料。

```html
<script setup>
import { reactive } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const state = reactive({
  customers: [],
});

const createCustomer = () => {
  router.push({ name: 'customer-create' });
};

const updateCustomer = (id) => {
  router.push({ name: 'customer-edit', params: { id } });
};

const deleteCustomer = (id) => {
  const index = customers.value.findIndex(customer => customer.id === id);
  customers.value.splice(index, 1);
};

(async () => {
  try {
    const response = await fetch('http://localhost:3000/api/customers', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    const data = await response.json();
    state.customers = data;
  } catch (err) {
    console.error(err);
  }
})();
</script>

<template>
  <div class="d-flex justify-content-between align-items-end mb-3">
    <div class="fs-2">
      Customers
    </div>
    <div>
      <button
        type="button"
        class="btn btn-primary btn-sm"
        @click="createCustomer"
      >
        Create
      </button>
    </div>
  </div>
  <table class="table table-striped table-bordered align-middle">
    <thead>
      <tr>
        <th>
          ID
        </th>
        <th>
          Name
        </th>
        <th>
          Actions
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="customer in state.customers"
        :key="customer.id"
      >
        <td>
          {{ customer.id }}
        </td>
        <td>
          {{ customer.name }}
        </td>
        <td>
          <button
            type="button"
            class="btn btn-warning btn-sm me-3"
            @click="updateCustomer(customer.id)"
          >
            Edit
          </button>
          <button
            type="button"
            class="btn btn-danger btn-sm"
            @click="deleteCustomer(customer.id)"
          >
            Delete
          </button>
        </td>
      </tr>
    </tbody>
  </table>
</template>
```

### 修改刪除功能

修改 `CustomerListView.vue` 檔，改寫 `deleteCustomer` 方法，改為呼叫後端 API 刪除真實資料。

```js
const deleteCustomer = async (id) => {
  try {
    await fetch(`http://localhost:3000/api/customers/${id}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    state.customers = state.customers.filter((customer) => customer.id !== id);
  } catch (err) {
    console.error(err);
  }
};
```

### 修改表單元件

修改 `CustomerForm.vue` 檔，定義一個 `formData` 雙向綁定，並暴露給父層元件使用，然後將表單的欄位綁定到 `formData` 身上。

```html
<script setup>
import { ref } from 'vue';

// 定義雙向綁定
const formData = defineModel('formData', {
  type: Object,
  default: () => ({}),
});

const form = ref();

const validateField = (e) => {
  const { target } = e;
  target.classList.toggle('is-valid', target.checkValidity());
  target.classList.toggle('is-invalid', !target.checkValidity());
};

const validateForm = () => {
  form.value.classList.add('was-validated');
  return form.value.checkValidity();
};

// 暴露屬性
defineExpose({
  validateForm,
  formData,
});
</script>

<template>
  <form
    ref="form"
    class="border p-3"
  >
    <div class="mb-3">
      <label
        for="name"
        class="form-label"
      >
        Name
      </label>
      <input
        id="name"
        v-model="formData.name"
        type="text"
        class="form-control"
        required
        @input="validateField"
      >
      <div class="invalid-feedback">
        Please provide a valid name.
      </div>
    </div>
  </form>
</template>
```

### 實作新增表單

修改 `CustomerCreateView.vue` 檔，重寫 `createCustomer` 方法，改為呼叫後端 API 新增真實資料。

```js
const createCustomer = async () => {
  if (!form.value.validateForm()) return;

  try {
    await fetch('http://localhost:3000/api/customers', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(form.value.formData),
    });
    router.push({ name: 'customer-list' });
  } catch (err) {
    console.error(err);
  }
};
```

### 實作修改表單

修改 `CustomerEditView.vue` 檔，重寫 `updateCustomer` 方法，改為呼叫後端 API 修改真實資料。

```html
<script setup>
import CustomerForm from '@/components/CustomerForm.vue';
import { reactive, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();

const form = ref();

const state = reactive({
  customer: {},
});

const updateCustomer = async () => {
  if (!form.value.validateForm()) return;

  try {
    await fetch(`http://localhost:3000/api/customers/${route.params.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(form.value.formData),
    });
    router.push({ name: 'customer-list' });
  } catch (err) {
    console.error(err);
  }
};

(async () => {
  try {
    const response = await fetch(`http://localhost:3000/api/customers/${route.params.id}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    const data = await response.json();
    state.customer = data;
  } catch (err) {
    console.error(err);
  }
})();
</script>

<template>
  <div class="d-flex justify-content-between align-items-end mb-3">
    <div class="fs-2">
      Edit Customer
    </div>
    <div>
      <button
        type="button"
        class="btn btn-danger btn-sm me-3"
        @click="router.push({ name: 'customer-list' })"
      >
        Cancel
      </button>
      <button
        type="button"
        class="btn btn-success btn-sm"
        @click="updateCustomer"
      >
        Save
      </button>
    </div>
  </div>
  <CustomerForm
    ref="form"
    v-model:form-data="state.customer"
  />
</template>
```

提交修改。

```bash
git add .
git commit -m "Use api instead of fake data"
git push
```

## 管理 API

### 建立模組

在 `src` 資料夾，建立 `api` 資料夾。

```bash
mkdir src/api
```

在 `src/api` 資料夾，建立 `customer.js` 檔，將呼叫後端 API 的方法集中在此模組進行管理。

```js
const list = async () => {
  const response = await fetch('http://localhost:3000/api/customers', {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  return await response.json();
};

const create = async (data) => {
  const response = await fetch('http://localhost:3000/api/customers', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
  return await response.json();
};

const get = async (id) => {
  const response = await fetch(`http://localhost:3000/api/customers/${id}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  return await response.json();
};

const update = async (id, data) => {
  const response = await fetch(`http://localhost:3000/api/customers/${id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
  return await response.json();
};

const destroy = async (id) => {
  await fetch(`http://localhost:3000/api/customers/${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
    },
  });
};

export {
  create,
  destroy,
  get,
  list,
  update,
};
```

在 `src/api` 資料夾，建立 `index.js` 檔，匯出 `customer` 模組。

```js
export * as customer from './customer';
```

### 重構列表頁面

修改 `CustomerListView.vue` 檔，改成使用 `customer` 模組呼叫 API。

```html
<script setup>
import { customer } from '@/api';
import { reactive } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const state = reactive({
  customers: [],
});

const createCustomer = () => {
  router.push({ name: 'customer-create' });
};

const updateCustomer = (id) => {
  router.push({ name: 'customer-edit', params: { id } });
};

const deleteCustomer = async (id) => {
  try {
    await customer.destroy(id);
    state.customers = state.customers.filter((customer) => customer.id !== id);
  } catch (err) {
    console.error(err);
  }
};

(async () => {
  try {
    state.customers = await customer.list();
  } catch (err) {
    console.error(err);
  }
})();
</script>

<template>
  <!-- ... -->
</template>
```

### 重構新增表單

修改 `CustomerCreateView.vue` 檔，改成使用 `customer` 模組呼叫 API。

```html
<script setup>
import { customer } from '@/api';
import CustomerForm from '@/components/CustomerForm.vue';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

const form = ref();

const createCustomer = async () => {
  if (!form.value.validateForm()) return;

  try {
    await customer.create(form.value.formData);
    router.push({ name: 'customer-list' });
  } catch (err) {
    console.error(err);
  }
};
</script>

<template>
  <!-- ... -->
</template>
```

### 重構修改表單

修改 `CustomerEditView.vue` 檔，改成使用 `customer` 模組呼叫 API。

```html
<script setup>
import { customer } from '@/api';
import CustomerForm from '@/components/CustomerForm.vue';
import { reactive, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const route = useRoute();
const router = useRouter();

const form = ref();

const state = reactive({
  customer: {},
});

const updateCustomer = async () => {
  if (!form.value.validateForm()) return;

  try {
    await customer.update(route.params.id, form.value.formData);
    router.push({ name: 'customer-list' });
  } catch (err) {
    console.error(err);
  }
};

(async () => {
  try {
    state.customer = await customer.get(route.params.id);
  } catch (err) {
    console.error(err);
  }
})();
</script>

<template>
  <!-- ... -->
</template>
```

提交修改。

```bash
git add .
git commit -m "Add customer api module"
git push
```

## 建立環境變數

> Ref: <https://vitejs.dev/guide/env-and-mode>

建立 `.env.local` 檔，這個檔案會被版本控制忽略。以 `VITE_` 開頭的環境變數，會被 Vite 自動載入。以下新增 `VITE_API_URL` 環境變數，未來如果需要根據環境而有不同的 API URL，就可以靈活修改。

```env
VITE_API_URL=http://localhost:3000
```

建立 `.env.example` 檔，這個檔案會被版本控制紀錄。這是環境變數的模板。

```env
VITE_API_URL=
```

修改 `src/api/customer.js` 檔，使用 `VITE_API_URL` 環境變數，取代原先寫死的 API URL。

```js
const { VITE_API_URL } = import.meta.env;

const list = async () => {
  const response = await fetch(`${VITE_API_URL}/api/customers`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  return await response.json();
};

const create = async (data) => {
  const response = await fetch(`${VITE_API_URL}/api/customers`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
  return await response.json();
};

const get = async (id) => {
  const response = await fetch(`${VITE_API_URL}/api/customers/${id}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  return await response.json();
};

const update = async (id, data) => {
  const response = await fetch(`${VITE_API_URL}/api/customers/${id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
  return await response.json();
};

const destroy = async (id) => {
  await fetch(`${VITE_API_URL}/api/customers/${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
    },
  });
};

// ...
```

提交修改。

```bash
git add .
git commit -m "Use env for api url"
git push
```

## 使用 Axios 套件

> Ref: <https://github.com/axios/axios>

安裝依賴套件。Axios 提供更強大的 HTTP 請求功能，使得處理請求更加方便和靈活。

```bash
npm install axios
```

修改 `src/api/customer.js` 檔，使用 Axios 進行 HTTP 請求，而不是瀏覽器原生的 `fetch` 方法。

```js
import axios from 'axios';

const { VITE_API_URL } = import.meta.env;

const client = axios.create({
  baseURL: VITE_API_URL,
});

const list = async () => {
  const response = await client.get('/api/customers');
  return response.data;
};

const create = async (data) => {
  const response = await client.post('/api/customers', data);
  return response.data;
};

const get = async (id) => {
  const response = await client.get(`/api/customers/${id}`);
  return response.data;
};

const update = async (id, data) => {
  const response = await client.put(`/api/customers/${id}`, data);
  return response.data;
};

const destroy = async (id) => {
  await client.delete(`/api/customers/${id}`);
};

// ...
```

提交修改。

```bash
git add .
git commit -m "Use axios instead of fetch"
git push
```

## 建立資料模型

新增 `src/models/Customer.js` 檔，為客戶建立一個 `Customer` 類別。

```js
class Customer {
  constructor({
    id,
    name,
  }) {
    this.id = id;
    this.name = name;
  }
}

export default Customer;
```

新增 `src/models/index.js` 檔。

```js
import Customer from './Customer';

export {
  Customer,
};
```

修改 `src/api/customer.js` 檔，將後端返回的資料轉換為 `Customer` 實例。

```js
import { Customer } from '@/models';
import axios from 'axios';

const { VITE_API_URL } = import.meta.env;

const client = axios.create({
  baseURL: VITE_API_URL,
});

/**
 * @returns {Promise<Customer[]>}
 */
const list = async () => {
  const response = await client.get('/api/customers');
  return response.data.map((customer) => new Customer(customer));
};

/**
 * @returns {Promise<Customer>}
 */
const create = async (data) => {
  const response = await client.post('/api/customers', data);
  return new Customer(response.data);
};

/**
 * @returns {Promise<Customer>}
 */
const get = async (id) => {
  const response = await client.get(`/api/customers/${id}`);
  return new Customer(response.data);
};

/**
 * @returns {Promise<Customer>}
 */
const update = async (id, data) => {
  const response = await client.put(`/api/customers/${id}`, data);
  return new Customer(response.data);
};

const destroy = async (id) => {
  await client.delete(`/api/customers/${id}`);
};

export {
  create,
  destroy,
  get,
  list,
  update,
};
```

修改 `src/views/CustomerListView.vue` 檔，新增 JSDoc 註解以明確定義資料的類型，讓編輯器能夠產生提示的功能。

```js
// ...

const state = reactive({
  /**
   * @type {import('@/models').Customer[]}
   */
  customers: [],
});

// ...
```

修改 `src/components/CustomerForm.vue` 檔。

```js
/**
 * @type {import('@/models').Customer}
 */
const formData = defineModel('formData', {
  type: Object,
  default: () => ({}),
});
```

提交修改。

```bash
git add .
git commit -m "Add data models"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
