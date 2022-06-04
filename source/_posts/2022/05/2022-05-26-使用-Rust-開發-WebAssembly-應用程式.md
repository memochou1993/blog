---
title: 使用 Rust 開發 WebAssembly 應用程式
permalink: 使用-Rust-開發-WebAssembly-應用程式
date: 2022-05-26 21:17:52
tags: ["程式設計", "WebAssembly", "Rust"]
categories: ["程式設計", "WebAssembly"]
---

## 前言

本文為「[Rust and WebAssembly](https://rustwasm.github.io/docs/book/)」教學指南的學習筆記。

## 前置作業

安裝 Rust 語言。

```BASH
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

安裝 `wasm-pack` 工具。

```BASH
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
```

安裝 `cargo-generate` 套件。

```BASH
cargo install cargo-generate
```

安裝 `npm` 套件管理工具。

```BASH
npm install npm@latest -g
```

## 建立專案

建立專案。

```BASH
cargo generate --git https://github.com/rustwasm/wasm-pack-template --name rust-webassembly-example
```

## 後端實作

進入專案。

```BASH
cd rust-webassembly-example
```

查看 `src/lib.rs` 檔，如下：

```RS
mod utils;

use wasm_bindgen::prelude::*;

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet() {
    alert("Hello, rust-webassembly-example!");
}
```

使用 `wasm-pack` 指令進行編譯，產生 WebAssembly 二進位檔和 JavaScript 中介層。

```BASH
wasm-pack build
```

產生的檔案如下：

- `pkg/rust_webassembly_example_bg.wasm`：這是由 Rust 編譯後產生的 WebAssembly 二進位檔，它包含了 Rust 函式以及資料，比如 `greet` 函式。
- `pkg/wasm_game_of_life.js`：這是由 `wasm-bindgen` 依賴套件編譯後產生的 JavaScript 中介層，用來暴露 WebAssembly 的函式給 JavaScript 程式。
- `pkg/rust_webassembly_example.d.ts`：包含了 `wasm_game_of_life.js` 檔的 TypeScript 型別提示。

例如，以下有一個 JavaScript 函式，封裝從 WebAssembly 模組匯出的 `greet` 函式。

```JS
import * as wasm from './wasm_game_of_life_bg';

// ...

export function greet() {
    return wasm.greet();
}
```

## 前端實作

在專案目錄建立一個前端專案。

```BASH
npm init wasm-app www
```

其中 `www` 資料夾的 `index.js` 檔是前端應用程式的入口，引入了 `hello-wasm-pack` 套件，裡面包含了預設的 WebAssembly 二進位檔和 JavaScript 中介層。

```JS
import * as wasm from "hello-wasm-pack";

wasm.greet();
```

進到 `www` 資料夾。

```BASH
cd www
```

再來，使用本地建立的 `rust-webassembly-example` 套件，而不是預設的 `hello-wasm-pack` 套件，因此需要將 `www/package.json` 檔修改如下：

```JSON
{
  // ...
  "dependencies": {
    "rust-webassembly-example": "file:../pkg"
  },
  // ...
}
```

安裝依賴套件。

```BASH
npm install
```

修改 `www/index.js` 檔。

```JS
import * as wasm from "rust-webassembly-example";

wasm.greet();
```

## 啟動服務

啟動服務。

```BASH
npm run start
```

## 練習

修改 `src/lib.rs` 檔，讓 `alert` 函式接受一個 `name` 參數。

```JS
mod utils;

use wasm_bindgen::prelude::*;

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern {
    fn alert(s: &str);
}

#[wasm_bindgen]
pub fn greet(name: &str) {
    alert(&format!("Hello, {}", name));
}
```

修改 `www/index.js` 檔。

```JS
import * as wasm from "rust-webassembly-example";

wasm.greet("World");
```

使用 `wasm-pack` 指令再一次進行編譯。

```BASH
wasm-pack build
```

## 程式碼

- [rust-webassembly-example](https://github.com/memochou1993/rust-webassembly-example)

## 參考資料

- [Rust and WebAssembly](https://rustwasm.github.io/docs/book/)
