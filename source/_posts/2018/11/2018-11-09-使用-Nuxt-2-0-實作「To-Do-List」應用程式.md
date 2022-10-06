---
title: 使用 Nuxt 2.0 實作「To-Do List」應用程式
date: 2018-11-09 00:27:53
tags: ["程式設計", "JavaScript", "Vue", "Nuxt"]
categories: ["程式設計", "JavaScript", "Nuxt"]
---

## 環境

- Windows 7
- node 8.11.1
- npm 5.6.0
- npx 9.7.1

## 前言

本文為「[Vue.js Todo App](https://www.youtube.com/watch?v=A5S23KS_-bU&list=PLEhEHUEU3x5q-xB1On4CsLPts0-rZ9oos)」教學影片的學習筆記。

## 建立專案

建立專案。

```bash
npx create-nuxt-app nuxt-todo-list
```

## 首頁

修改 `pages\index.vue` 檔。

```html
<template>
  <v-layout>
    <div class="container">
      <logo class="logo"/>
      <todo-list/>
    </div>
  </v-layout>
</template>

<script>
import Logo from '../components/Logo.vue';
import TodoList from '../components/TodoList.vue';

export default {
  components: {
    Logo,
    TodoList,
  },
};
</script>

<style lang="scss">
* {
  box-sizing: border-box;
}
#app {
  color: #2c3e50;
  font-size: 18px;
  padding-top: 40px;
}
.container {
  max-width: 600px;
  text-align: center;
}
.logo {
  height: 100px;
}
</style>
```

## 布局

修改 `pages\index.vue` 檔。

```html
<template>
  <v-app>
    <v-content>
      <v-container>
        <nuxt />
      </v-container>
    </v-content>
  </v-app>
</template>
```

## 元件

建立 `components\TodoList.vue` 檔。

```html
<template>
  <div>
    <input
      v-model="todoCreated"
      type="text"
      class="todo-input"
      placeholder="請輸入代辦事項……"
      @keyup.enter="createTodo">
    <transition-group
      name="fade"
      enter-active-class="animated fadeIn"
      leave-active-class="animated fadeOut">
      <todo-item
        v-for="(todo, index) in filteredTodos"
        :key="todo.id"
        :todo="todo"
        :index="index"
        :check-all="!anyRemaining"
        class="todo-item"/>
    </transition-group>
    <div>
      <v-layout
        align-center>
        <todo-check-all/>
        <todo-item-remaining/>
      </v-layout>
    </div>
    <div>
      <v-layout>
        <v-flex
          xs8
          text-xs-left>
          <todo-filter/>
        </v-flex>
        <v-flex
          xs4
          text-xs-right>
          <todo-clear-completed
            :show-clear-completed-todo="showClearCompletedTodo"/>
        </v-flex>
      </v-layout>
    </div>
  </div>
</template>

<script>
import TodoItem from './TodoItem.vue';
import TodoItemRemaining from './TodoItemRemaining.vue';
import TodoCheckAll from './TodoCheckAll.vue';
import TodoFilter from './TodoFilter.vue';
import TodoClearCompleted from './TodoClearCompleted.vue';

export default {
  components: {
    TodoItem,
    TodoItemRemaining,
    TodoCheckAll,
    TodoFilter,
    TodoClearCompleted,
  },
  data() {
    return {
      todoCreated: '',
      idForTodo: 3,
    };
  },
  computed: {
    anyRemaining() {
      return this.$store.getters.anyRemaining;
    },
    filteredTodos() {
      return this.$store.getters.filteredTodos;
    },
    showClearCompletedTodo() {
      return this.$store.getters.showClearCompletedTodo;
    },
  },
  methods: {
    createTodo() {
      if (this.todoCreated.trim().length === 0) {
        return;
      }
      this.$store.dispatch('createTodo', {
        id: this.idForTodo,
        title: this.todoCreated,
      });
      this.todoCreated = '';
      this.idForTodo += 1;
    },
  },
};
</script>

<style lang="scss">
@import url('https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.7.0/animate.css');
.todo-item {
  animation-duration: 0.5s;
}
.todo-input {
  width: 100%;
  padding: 12px 12px;
  margin: 16px 0;
  border: 1px solid #eeeeee;
  &:focus {
    outline: none;
  }
}
.todo-item-label {
  padding: 10px;
  border: 1px solid #fafafa;
}
.todo-item-edit {
  width: 100%;
  padding: 10px;
  border: 1px solid #eeeeee;
  &:focus {
    outline: none;
  }
}
.remove-item {
  cursor: pointer;
  &:hover {
    color: #000000;
  }
}
.completed {
  text-decoration: line-through;
}
.extra-container {
  padding: 10px;
}
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s;
}
.fade-enter,
.fade-leave-to {
  opacity: 0;
}
</style>
```

建立 `components\TodoItemRemaining.vue` 檔。

```html
<template>
  <v-flex
    xs6
    text-xs-right>
    <div>
      剩餘 {{ remaining }} 件未完成事項
    </div>
  </v-flex>
</template>

<script>
export default {
  computed: {
    remaining() {
      return this.$store.getters.remaining;
    },
  },
};
</script>
```

建立 `components\TodoItem.vue` 檔。

```html
<template>
  <div>
    <v-layout
      wrap
      align-center>
      <v-flex
        xs1>
        <input
          v-model="completed"
          type="checkbox"
          @change="doneEditTodo">
      </v-flex>
      <v-flex
        xs10
        text-xs-left>
        <div
          v-if="!editing"
          :class="{ completed : completed }"
          class="todo-item-label"
          @dblclick="startEditTodo">
          {{ title }}
        </div>
        <input
          v-focus
          v-else
          v-model="title"
          type="text"
          class="todo-item-edit"
          @blur="doneEditTodo"
          @keyup.enter="doneEditTodo"
          @keyup.esc="cancelEditTodo">
      </v-flex>
      <v-flex
        xs1>
        <div
          class="remove-item"
          @click="destroyTodo(index)">
          &times;
        </div>
      </v-flex>
    </v-layout>
  </div>
</template>

<script>
export default {
  directives: {
    focus: {
      inserted(el) {
        el.focus();
      },
    },
  },
  props: {
    todo: {
      type: Object,
      requited: true,
      default() {
        return {};
      },
    },
    index: {
      type: Number,
      requited: true,
      default: 0,
    },
    checkAll: {
      type: Boolean,
      requited: true,
      default: false,
    },
  },
  data() {
    return {
      id: this.todo.id,
      title: this.todo.title,
      completed: this.todo.completed,
      editing: this.todo.editing,
      todoBeforeEdit: '',
    };
  },
  watch: {
    checkAll() {
      this.completed = this.checkAll ? true : this.todo.completed;
    },
  },
  methods: {
    startEditTodo() {
      this.todoBeforeEdit = this.title;
      this.editing = true;
    },
    doneEditTodo() {
      if (this.title.trim().length === 0) {
        this.title = this.todoBeforeEdit;
      }
      this.editing = false;
      this.$store.dispatch('doneEditTodo', {
        id: this.id,
        title: this.title,
        completed: this.completed,
        editing: this.editing,
      });
    },
    cancelEditTodo() {
      this.title = this.todoBeforeEdit;
      this.editing = false;
    },
    destroyTodo(index) {
      this.$store.dispatch('destroyTodo', index);
    },
  },
};
</script>
```

建立 `components\TodoFilter.vue` 檔。

```html
<template>
  <div>
    <v-btn
      :input-value="filter == 'all'"
      @click="changeFilter('all')">
      所有
    </v-btn>
    <v-btn
      :input-value="filter == 'active'"
      @click="changeFilter('active')">
      進行中
    </v-btn>
    <v-btn
      :input-value="filter == 'completed'"
      @click="changeFilter('completed')">
      已完成
    </v-btn>
  </div>
</template>

<script>
export default {
  computed: {
    filter() {
      return this.$store.state.filter;
    },
  },
  methods: {
    changeFilter(filter) {
      this.$store.dispatch('changeFilter', filter);
    },
  },
};
</script>
```

建立 `components\TodoClearCompleted.vue` 檔。

```html
<template>
  <transition name="fade">
    <v-btn
      v-if="showClearCompletedTodo"
      @click="clearCompletedTodo">
      清除
    </v-btn>
  </transition>
</template>

<script>
export default {
  computed: {
    showClearCompletedTodo() {
      return this.$store.getters.showClearCompletedTodo;
    },
  },
  methods: {
    clearCompletedTodo() {
      this.$store.dispatch('clearCompletedTodo');
    },
  },
};
</script>
```

建立 `components\TodoCheckAll.vue` 檔。

```html
<template>
  <v-flex
    xs6>
    <v-layout
      align-center>
      <v-flex
        xs2>
        <div>
          <input
            id="checkAllTodos"
            :checked="!anyRemaining"
            type="checkbox"
            @change="checkAllTodos">
        </div>
      </v-flex>
      <v-flex
        xs10
        text-xs-left>
        <div
          class="extra-container">
          <label
            for="checkAllTodos">
            全選
          </label>
        </div>
      </v-flex>
    </v-layout>
  </v-flex>
</template>

<script>
export default {
  computed: {
    anyRemaining() {
      return this.$store.getters.anyRemaining;
    },
  },
  methods: {
    checkAllTodos() {
      this.$store.dispatch('checkAllTodos', window.event.target.checked);
    },
  },
};
</script>
```

## 建立 Vuex 倉庫

建立 `store\index.js` 檔。

```js
import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

const store = new Vuex.Store({
  state: {
    filter: 'all',
    todos: [
      {
        id: 1,
        title: '完成作業',
        completed: false,
        editing: false,
      },
      {
        id: 2,
        title: '繳交費用',
        completed: false,
        editing: false,
      },
    ],
  },
  getters: {
    remaining(state) {
      return state.todos.filter((todo) => !todo.completed).length;
    },
    anyRemaining(state, getters) {
      return getters.remaining !== 0;
    },
    filteredTodos(state) {
      switch (state.filter) {
        case 'all':
          return state.todos;
        case 'active':
          return state.todos.filter((todo) => !todo.completed);
        case 'completed':
          return state.todos.filter((todo) => todo.completed);
        default:
          return state.todos;
      }
    },
    showClearCompletedTodo(state) {
      const completedTodo = state.todos.filter((todo) => todo.completed);
      return completedTodo.length > 0;
    },
  },
  mutations: {
    createTodo(state, todo) {
      state.todos.push({
        id: todo.id,
        title: todo.title,
      });
    },
    clearCompletedTodo(state) {
      state.todos = state.todos.filter((todo) => !todo.completed);
    },
    changeFilter(state, filter) {
      state.filter = filter;
    },
    checkAllTodos(state, checked) {
      state.todos.forEach((todo) => {
        todo.completed = checked;
      });
    },
    doneEditTodo(state, todo) {
      const index = state.todos.findIndex((item) => item.id === todo.id);
      state.todos.splice(index, 1, {
        id: todo.id,
        title: todo.title,
        completed: todo.completed,
        editing: todo.editing,
      });
    },
    destroyTodo(state, index) {
      state.todos.splice(index, 1);
    },
  },
  actions: {
    createTodo(context, todo) {
      setTimeout(() => {
        context.commit('createTodo', todo);
      }, 0);
    },
    clearCompletedTodo(context) {
      setTimeout(() => {
        context.commit('clearCompletedTodo');
      }, 0);
    },
    changeFilter(context, filter) {
      setTimeout(() => {
        context.commit('changeFilter', filter);
      }, 0);
    },
    checkAllTodos(context, checked) {
      setTimeout(() => {
        context.commit('checkAllTodos', checked);
      }, 0);
    },
    doneEditTodo(context, todo) {
      setTimeout(() => {
        context.commit('doneEditTodo', todo);
      }, 0);
    },
    destroyTodo(context, index) {
      setTimeout(() => {
        context.commit('destroyTodo', index);
      }, 0);
    },
  },
});

export default () => store;
```

## 程式碼

- [nuxt-todo-list](https://github.com/memochou1993/nuxt-todo-list)
