---
title: 使用 Yew 開發 WebAssembly 應用程式
date: 2022-09-26 21:32:40
tags: ["程式設計", "Rust", "WebAssembly", "Wasm", "JavaScript", "Yew"]
categories: ["程式設計", "Rust", "WebAssembly"]
---

## 建立專案

建立專案。

```bash
cargo new yew-counter
cd yew-counter
```

使用 Cargo 安裝 `trunk` 套件，用來打包 WebAssembly 和靜態檔案。

```bash
cargo install trunk
```

為 Rust 添加 `wasm32-unknown-unknown` 編譯目標，讓 Rust 能夠編譯 WebAssembly 檔案。

```bash
rustup target add wasm32-unknown-unknown
```

安裝依賴套件。

```bash
cargo add yew
```

## 實作

修改 `main.rs` 檔。

```rs
use yew::prelude::*;

#[function_component(App)]
fn app() -> Html {
    let count = use_state(|| 0);
    let onclick = {
        let count = count.clone();
        move |_| {
            count.set(*count + 1);
        }
    };

    html! {
        <div>
            <button {onclick}>{ "+1" }</button>
            <p>{ *count }</p>
        </div>
    }
}

fn main() {
    yew::start_app::<App>();
}
```

啟動服務。

```bash
trunk serve
```

前往 <http://localhost:8080> 瀏覽。

## 後記

如果發現 Trunk 熱更新的速度很慢，有可能是 VS Code 的 rust-analyzer 套件的問題。使用以下設定，可以避免每次更新程式碼都觸發檢查。

```json
{
    "rust-analyzer.checkOnSave.enable": false
}
```

## 程式碼

- [yew-counter](https://github.com/memochou1993/yew-counter)

## 參考資料

- [Yew - Docs](https://yew.rs/docs/next/getting-started/build-a-sample-app)
