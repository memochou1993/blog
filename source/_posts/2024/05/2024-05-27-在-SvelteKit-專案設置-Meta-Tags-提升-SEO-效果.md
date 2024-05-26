---
title: 在 SvelteKit 專案設置 Meta Tags 提升 SEO 效果
date: 2024-05-27 00:51:23
tags: ["Programming", "JavaScript", "Svelte", "SvelteKit", "HTML", "SEO"]
categories: ["Programming", "JavaScript", "Svelte"]
---

## 做法

修改 `+layout.svelte` 檔。

```html
<script lang="ts">
  const url = import.meta.env.VITE_APP_URL; // 加上網址
  const title = ''; // 加上標題
  const description = ''; // 加上描述
</script>

<svelte:head>
  <title>{title}</title>
  <meta name="description" content={description} />
  <!-- 加上關鍵字 -->
  <meta name="keywords" content="svelte" />
  <!-- 加上作者 -->
  <meta name="author" content="Memo Chou" /> 
  <meta name="robots" content="index, follow" />
  <meta name="og:title" content={title} />
  <meta name="og:description" content={description} />
  <meta name="og:type" content="website" />
  <meta name="og:url" content={url} />
  <!-- 加上封面 -->
  <meta name="og:image" content="{url}/cover.png" />
  <meta name="twitter:title" content={title} />
  <meta name="twitter:description" content={description} />
  <!-- 加上封面 -->
  <meta name="twitter:image" content="{url}/cover.png" />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<div class="app">
  <main>
    <slot />
  </main>
</div>
```

## 參考資料

- [Svelte Tutorial](https://learn.svelte.dev/tutorial/svelte-head)
