---
title: 在 SvelteKit 專案建立深色模式切換器
date: 2024-06-21 01:27:40
tags: ["Programming", "JavaScript", "Svelte", "SvelteKit", "PWA"]
categories: ["Programming", "JavaScript", "Svelte"]
---

## 實作

建立 `AppThemeSwitch.svelte` 檔。

```ts
<script lang="ts">
  import { onMount } from 'svelte';
  import AppIcon from './AppIcon.svelte';

  const THEME_LIGHT = 'light';
  const THEME_DARK = 'dark';
  const THEME_STORAGE_KEY = 'theme';

  let theme: string;

  $: isDarkTheme = theme === THEME_DARK;

  onMount(() => {
    const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)');

    setTheme(localStorage.getItem(THEME_STORAGE_KEY) || (prefersDarkScheme.matches ? THEME_DARK : THEME_LIGHT));

    prefersDarkScheme.addEventListener('change', (event) => {
      setTheme(event.matches ? THEME_DARK : THEME_LIGHT);
    });
  });

  const setTheme = (v: string) => {
    theme = v;
    document.documentElement.setAttribute('data-bs-theme', theme);
    localStorage.setItem(THEME_STORAGE_KEY, theme);
  };

  const toggleTheme = () => {
    setTheme(isDarkTheme ? THEME_LIGHT : THEME_DARK);
  };
</script>

<button type="button" class="btn btn-dark-variant px-2" on:click={toggleTheme}>
  <AppIcon icon={isDarkTheme ? 'light_mode' : 'dark_mode'} />
</button>
```

使用。

```ts
<AppThemeSwitch />
```
