---
title: 使用 Yew 開發 WebAssembly 應用程式
date: 2022-09-26 21:32:40
tags: ["程式設計", "Rust", "WebAssembly", "Wasm", "JavaScript", "Yew"]
categories: ["程式設計", "Rust", "WebAssembly"]
---

## 做法

建立專案。

```bash
cargo new yew-counter
cd yew-counter
```

修改 `Cargo.toml` 檔，安裝依賴套件。

```rs
[dependencies]
yew = { git = "https://github.com/yewstack/yew/", features = ["csr"] }
```

修改 `main.rs` 檔。

```rs
use yew::prelude::*;

#[function_component]
fn App() -> Html {
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
    yew::Renderer::<App>::new().render();
}
```

啟動服務。

```bash
trunk serve
```

前往 <http://localhost:8080> 瀏覽。

## 程式碼

- [yew-counter](https://github.com/memochou1993/yew-counter)

## 參考資料

- [Yew - Docs](https://yew.rs/docs/next/getting-started/build-a-sample-app)
