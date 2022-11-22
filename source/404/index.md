---
title: Memo's Blog
date: 2022-11-22 15:56:03
comments: false
permalink: /404.html
---

## 404 Not Found

很抱歉，您目前存取的頁面並不存在。

<br>

<img src="/images/cactus.png" width="150">

<script>
const { pathname } = location;
const r = (new URLSearchParams(location.search)).get('r')
if (!r && !isNaN(Date.parse(pathname.slice(1, 11)))) {
    location.href = `${pathname.slice(0, 9) + pathname.slice(12)}?r=true`;
}
</script>
