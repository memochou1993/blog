---
title: 使用 Yew 開發 WebAssembly 應用程式
date: 2022-10-08 21:04:49
tags: ["程式設計", "Rust", "WebAssembly", "Wasm", "JavaScript", "Yew"]
categories: ["程式設計", "Rust", "WebAssembly"]
---

## 建立專案

建立專案。

```bash
cargo new yew-web-app
cd yew-web-app
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

建立 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>
<body></body>
</html>

```

建立 `main.rs` 檔。

```rs
use yew_web_app::App;

fn main() {
    yew::start_app::<App>();
}
```

建立 `lib.rs` 檔。

```rs
use yew::prelude::*;

#[derive(Clone, PartialEq)]
struct Video {
    id: usize,
    title: String,
    speaker: String,
    url: String,
}

#[derive(Properties, PartialEq)]
struct VideosListProps {
    videos: Vec<Video>,
    on_click: Callback<Video>,
}

#[derive(Clone, Properties, PartialEq)]
struct VideosDetailsProps {
    video: Video,
}

#[function_component(VideoDetails)]
fn video_details(VideosDetailsProps { video }: &VideosDetailsProps) -> Html {
    html! {
        <div>
            <h3>{ video.title.clone() }</h3>
            <img src="https://via.placeholder.com/640x360.png?text=Video+Player+Placeholder" alt="video thumbnail" />
        </div>
    }
}

#[function_component(VideosList)]
fn videos_list(VideosListProps { videos, on_click }: &VideosListProps) -> Html {
    videos
        .iter()
        .map(|video| {
            let on_video_select = {
                let on_click = on_click.clone();
                let video = video.clone();
                Callback::from(move |_| on_click.emit(video.clone()))
            };
            html! {
                <p onclick={on_video_select} style="cursor: pointer;">{format!("{}: {}", video.speaker, video.title)}</p>
            }
        })
        .collect()
}

#[function_component(App)]
pub fn app() -> Html {
    let videos = vec![
        Video {
            id: 1,
            title: "Building and breaking things".to_string(),
            speaker: "John Doe".to_string(),
            url: "https://youtu.be/PsaFVLr8t4E".to_string(),
        },
        Video {
            id: 2,
            title: "The development process".to_string(),
            speaker: "Jane Smith".to_string(),
            url: "https://youtu.be/PsaFVLr8t4E".to_string(),
        },
        Video {
            id: 3,
            title: "The Web 7.0".to_string(),
            speaker: "Matt Miller".to_string(),
            url: "https://youtu.be/PsaFVLr8t4E".to_string(),
        },
        Video {
            id: 4,
            title: "Mouseless development".to_string(),
            speaker: "Tom Jerry".to_string(),
            url: "https://youtu.be/PsaFVLr8t4E".to_string(),
        },
    ];

    let selected_video = use_state(|| None);

    let on_video_select = {
        let selected_video = selected_video.clone();
        Callback::from(move |video: Video| selected_video.set(Some(video)))
    };

    let details = selected_video.as_ref().map(|video| {
        html! {
            <VideoDetails video={video.clone()} />
        }
    });

    html! {
        <>
            <h1>{ "RustConf Explorer" }</h1>
            <div>
                <h3>{ "Videos to watch" }</h3>
                <VideosList videos={videos} on_click={on_video_select} />
            </div>
            { for details }
        </>
    }
}
```

啟動服務。

```bash
trunk serve
```

前往 <http://localhost:8080> 瀏覽。

## 獲取遠端資料

安裝依賴套件

```bash
cargo add gloo-net@0.2
cargo add serde@1.0 --features "derive"
cargo add wasm-bindgen-futures@0.4
```

修改 `lib.rs` 檔。

```rs
use gloo_net::http::Request;
use serde::Deserialize;
use yew::prelude::*;

#[derive(Clone, PartialEq, Deserialize)]
struct Video {
    id: usize,
    title: String,
    speaker: String,
    url: String,
}

// ...

#[function_component(App)]
pub fn app() -> Html {
    let videos = use_state(|| vec![]);
    {
        let videos = videos.clone();
        use_effect_with_deps(
            move |_| {
                let videos = videos.clone();
                wasm_bindgen_futures::spawn_local(async move {
                    let fetched_videos: Vec<Video> = Request::get("/tutorial/data.json")
                        .send()
                        .await
                        .unwrap()
                        .json()
                        .await
                        .unwrap();
                    videos.set(fetched_videos);
                });
                || ()
            },
            (),
        );
    }

    let selected_video = use_state(|| None);

    let on_video_select = {
        let selected_video = selected_video.clone();
        Callback::from(move |video: Video| selected_video.set(Some(video)))
    };

    let details = selected_video.as_ref().map(|video| {
        html! {
            <VideoDetails video={video.clone()} />
        }
    });

    html! {
        <>
            <h1>{ "RustConf Explorer" }</h1>
            <div>
                <h3>{ "Videos to watch" }</h3>
                <VideosList videos={(*videos).clone()} on_click={on_video_select} />
            </div>
            { for details }
        </>
    }
}
```

啟動服務。

```bash
trunk serve --proxy-backend=https://yew.rs/tutorial
```

前往 <http://localhost:8080> 瀏覽。

## 補充

如果 Trunk 熱更新的速度很慢，有可能是 VS Code 的 rust-analyzer 套件的問題，修改 `settings.json` 檔，並套用以下設定。

```json
{
    "rust-analyzer.checkOnSave.extraArgs": [
        "--target-dir", "/tmp/rust-analyzer-check"
    ]
}
```

## 程式碼

- [yew-example](https://github.com/memochou1993/yew-example)

## 參考資料

- [Yew - Tutorial](https://yew.rs/docs/tutorial#fetching-data-using-external-rest-api)
