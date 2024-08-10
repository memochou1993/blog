---
title: 使用 Vue 3 和 Express 實作內容管理系統（九）：實作前端管理功能
date: 2024-08-10 00:17:22
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

## 實作管理功能

### 修改列表頁面

修改 `CustomerListView.vue` 檔，將假資料移除，改為呼叫 API 取得真實資料。

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

修改 `CustomerForm.vue` 檔，重寫 `deleteCustomer` 方法，改為呼叫 API 刪除真實資料。

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

修改 `CustomerCreateView.vue` 檔，重寫 `createCustomer` 方法，改為呼叫 API 新增真實資料。

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

### 串接 API

修改 `CustomerEditView.vue` 檔，重寫 `updateCustomer` 方法，改為呼叫 API 修改真實資料。然後在元件一開始被掛載的時候，呼叫 API 取得真實資料。

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

TODO

## 使用 Axios 套件

TODO

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
