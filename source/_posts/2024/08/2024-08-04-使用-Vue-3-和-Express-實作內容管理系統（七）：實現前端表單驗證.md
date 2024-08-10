---
title: 使用 Vue 3 和 Express 實作內容管理系統（七）：實現前端表單驗證
date: 2024-08-04 00:08:37
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

## 實作

修改 `CustomerForm` 檔，實作驗證欄位和驗證表單的方法，並將驗證表單的方法暴露給父層元件使用。

```html
<script setup>
import { ref } from 'vue';

// 綁定表單引用
const form = ref();

// 驗證欄位
const validateField = (e) => {
  const { target } = e;
  target.classList.toggle('is-valid', target.checkValidity());
  target.classList.toggle('is-invalid', !target.checkValidity());
};

// 驗證表單
const validateForm = () => {
  if (form.value.checkValidity()) {
    form.value.classList.remove('was-validated');
    return true;
  }
  form.value.classList.add('was-validated');
  return false;
};

// 暴露屬性
defineExpose({
  validateForm,
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

修改 `CustomerCreateView.vue` 檔，在點擊提交按鈕時，呼叫元件暴露的驗證表單的方法。

```html
<script setup>
import CustomerForm from '@/components/CustomerForm.vue';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 綁定表單引用
const form = ref();

const createCustomer = () => {
  // TODO
  console.log(form.value.validateForm());
};
</script>

<template>
  <div class="d-flex justify-content-between align-items-end mb-3">
    <div class="fs-2">
      Create Customer
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
        @click="createCustomer"
      >
        Save
      </button>
    </div>
  </div>
  <CustomerForm ref="form" />
</template>
```

修改 `CustomerCreateEdit.vue` 檔，在點擊提交按鈕時，呼叫元件暴露的驗證表單的方法。

```html
<script setup>
import CustomerForm from '@/components/CustomerForm.vue';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 綁定表單引用
const form = ref();

const updateCustomer = () => {
  // TODO
  console.log(form.value.validateForm());
};
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
  <CustomerForm ref="form" />
</template>
```

提交修改。

```bash
git add .
git commit -m "Add form validation"
git push
```

## 程式碼

- [simple-cms-ui](https://github.com/memochou1993/simple-cms-ui)
- [simple-cms-api](https://github.com/memochou1993/simple-cms-api)
