---
title: 在 SvelteKit 專案使用 Bootstrap UI 框架
date: 2024-05-19 17:47:55
tags: ["Programming", "JavaScript", "Svelte", "SvelteKit", "Bootstrap"]
categories: ["Programming", "JavaScript", "Svelte"]
---

## 做法

建立專案。

```bash
bun create vite           

✔ Project name: … svelte-bootstrap-example
✔ Select a framework: › Svelte
✔ Select a variant: › SvelteKit ↗

create-svelte version 6.1.2

┌  Welcome to SvelteKit!
│
◇  Which Svelte app template?
│  Skeleton project
│
◇  Add type checking with TypeScript?
│  Yes, using TypeScript syntax
│
◇  Select additional options (use arrow keys/space bar)
│  Add ESLint for code linting, Add Prettier for code formatting, Add Playwright for browser testing, Add Vitest for unit testing
│
└  Your project is ready!
```

初始化專案。

```bash
cd svelte-bootstrap-example
bun install
git init && git add -A && git commit -m "Initial commit"
```

安裝依賴套件。

```bash
bun add bootstrap @types/bootstrap sass -D
```

新增 `.vscode/settings.json` 檔。

```json
{
  "editor.tabSize": 2,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true
}
```

新增 `main.scss` 檔。

```scss
@import 'bootstrap/scss/bootstrap';
```

修改 `src/routes/+page.svelte` 檔。

```html
<script lang="ts">
  import type { Tooltip } from 'bootstrap';
  import { onMount } from 'svelte';
  import './main.scss';

  let bootstrap: typeof import('bootstrap');

  // enable Bootstrap tooltips
  onMount(async () => {
    bootstrap = await import('bootstrap');
  });

  const handleCopy = () => {
    // do something
    tooltip.show();
    setTimeout(() => tooltip.hide(), 1000);
  };

  $: tooltip = bootstrap?.Tooltip.getOrCreateInstance('#tooltip') as Tooltip;
</script>

<button type="button" class="btn btn-primary">Hello, World!</button>

<button
  class="btn btn-block btn-warning"
  data-bs-placement="bottom"
  data-bs-toggle="tooltip"
  data-bs-trigger="manual"
  id="tooltip"
  on:click={handleCopy}
  title="Clicked Successfully!"
  type="button"
>
  Click!
</button>
```

啟動專案。

```bash
npm run dev
```

前往 <http://localhost:5174> 瀏覽。

## 程式碼

- [svelte-bootstrap-example](https://github.com/memochou1993/svelte-bootstrap-example)

## 參考資料

- [Bootstrap](https://getbootstrap.com/)
