---
title: 使用 Yew 和 WebAssembly 實作「視訊串流」應用程式
permalink: 使用-Yew-和-WebAssembly-實作「視訊串流」應用程式
date: 2022-09-26 19:58:08
tags: ["程式設計", "Rust", "WebAssembly", "Wasm", "JavaScript", "Canvas", "Yew"]
categories: ["程式設計", "Rust", "WebAssembly"]
---

## 前言

本文為「[Let's Build a RUST WebAssembly Frontend App With Yew](https://www.youtube.com/watch?v=lJllt5X6ELg)」教學影片的學習筆記。

## 前置作業

使用 Cargo 安裝 `trunk` 套件，用來打包 WebAssembly 和靜態檔案。

```BASH
cargo install trunk
```

為 Rust 添加 `wasm32-unknown-unknown` 編譯目標，讓 Rust 能夠編譯 WebAssembly 檔案。

```BASH
rustup target add wasm32-unknown-unknown
```

## 建立專案

建立專案。

```BASH
cargo new yew-video-streaming
```

安裝依賴套件。

```BASH
cargo add yew
```

新增 `index.html` 檔。

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
</body>
</html>
```

修改 `main.rs` 檔。

```RS
use yew::prelude::*;

#[function_component(App)]
fn app() -> Html {
    html!(
        <div>
            {"Hello, World!"}
        </div>
    )
}

fn main() {
    yew::start_app::<App>();
}
```

啟動服務。

```BASH
trunk serve
```

## 新增樣式

新增 `style.scss` 檔。

```SCSS
body {
    margin: 0;
}

.grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
}

.consumer {
    background-color: #0057B7;
    color: white;
    padding: 10px;
}

.producer {
    background-color: #FFD700;
    color: black;
    padding: 10px;
}
```

修改 `index.html` 檔。

```HTML
<!DOCTYPE html>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link data-trunk rel="scss" href="style.scss">
</head>
<body>
</body>
</html>
```

修改 `main.rs` 檔。

```RS
use yew::prelude::*;

#[function_component(Producer)]
fn producer() -> Html {
    html!(
        <div class="producer">
            <h3>
                {"Producer"}
            </h3>
        </div>
    )
}

#[function_component(Consumer)]
fn consumer() -> Html {
    html!(
        <div class="consumer">
            <h3>
                {"Consumer"}
            </h3>
        </div>
    )
}

#[function_component(App)]
fn app() -> Html {
    html!(
        <div class={"grid"}>
            <Producer />
            <Consumer />
        </div>
    )
}

fn main() {
    yew::start_app::<App>();
}
```

## 連接視訊

安裝依賴套件。

```BASH
cargo add js-sys
cargo add wasm-bindgen
cargo add wasm-bindgen-futures
cargo add web-sys --features "console, EncodedVideoChunk, HtmlVideoElement, MediaDevices, MediaStream, MediaStreamConstraints, MediaStreamTrack, MediaStreamTrackProcessor, MediaStreamTrackProcessorInit, Navigator, ReadableStream, ReadableStreamGetReaderOptions, ReadableStreamDefaultReader, VideoEncoder, VideoEncoderConfig, VideoEncoderInit, VideoFrame, VideoTrack"
```

修改 `main.rs` 檔。

```RS
use js_sys::Boolean;
use wasm_bindgen::JsCast;
use wasm_bindgen_futures::JsFuture;
use web_sys::{window, HtmlVideoElement, MediaStream, MediaStreamConstraints};
use yew::prelude::*;

#[function_component(Producer)]
fn producer() -> Html {
    wasm_bindgen_futures::spawn_local(async move {
        let navigator = window().unwrap().navigator();
        let media_devices = navigator.media_devices().unwrap();
        let video_element = window()
            .unwrap()
            .document()
            .unwrap()
            .get_element_by_id("webcam")
            .unwrap()
            .unchecked_into::<HtmlVideoElement>();
        let mut constraints = MediaStreamConstraints::new();
        constraints.video(&Boolean::from(true));
        let device_query = media_devices
            .get_user_media_with_constraints(&constraints)
            .unwrap();
        let device = JsFuture::from(device_query)
            .await
            .unwrap()
            .unchecked_into::<MediaStream>();
        video_element.set_src_object(Some(&device));
    });

    html!(
        <div class="producer">
            <h3>
                {"Producer"}
                <video autoplay=true id="webcam"></video>
            </h3>
        </div>
    )
}

// ...
```

## 處理編碼

修改 VS Code 的 `settings.json` 檔。

```JSON
{
  "rust-analyzer.server.extraEnv": {
    "RUSTFLAGS": "--cfg=web_sys_unstable_apis"
  }
}
```

修改 `main.rs` 檔。

```RS
use js_sys::{Array, Boolean, JsString, Reflect};
use wasm_bindgen::{prelude::Closure, JsCast, JsValue};
use wasm_bindgen_futures::JsFuture;
use web_sys::{
    console, window, HtmlVideoElement, MediaStream, MediaStreamConstraints, MediaStreamTrack,
    MediaStreamTrackProcessor, MediaStreamTrackProcessorInit, ReadableStreamDefaultReader,
    VideoEncoder, VideoEncoderConfig, VideoEncoderInit, VideoFrame, VideoTrack,
};
use yew::prelude::*;

static VIDEO_CODEC: &str = "vp09.00.10.08";
static VIDEO_HEIGHT: u32 = 1280;
static VIDEO_WIDTH: u32 = 720;

#[function_component(Producer)]
fn producer() -> Html {
    wasm_bindgen_futures::spawn_local(async move {
        let navigator = window().unwrap().navigator();
        let media_devices = navigator.media_devices().unwrap();
        let video_element = window()
            .unwrap()
            .document()
            .unwrap()
            .get_element_by_id("webcam")
            .unwrap()
            .unchecked_into::<HtmlVideoElement>();
        let mut constraints = MediaStreamConstraints::new();
        constraints.video(&Boolean::from(true));
        let device_query = media_devices
            .get_user_media_with_constraints(&constraints)
            .unwrap();
        let device = JsFuture::from(device_query)
            .await
            .unwrap()
            .unchecked_into::<MediaStream>();
        video_element.set_src_object(Some(&device));
        let video_track = Box::new(
            device
                .get_video_tracks()
                .find(&mut |_: JsValue, _: u32, _: Array| true)
                .unchecked_into::<VideoTrack>(),
        );
        let error_handler = Closure::wrap(Box::new(move |e: JsValue| {
            console::log_1(&JsString::from("error"));
            console::log_1(&e);
        }) as Box<dyn FnMut(JsValue)>);
        let output_handler =
            Closure::wrap(Box::new(move |chunk| console::log_1(&chunk)) as Box<dyn FnMut(JsValue)>);
        let video_encoder_init = VideoEncoderInit::new(
            error_handler.as_ref().unchecked_ref(),
            output_handler.as_ref().unchecked_ref(),
        );
        let video_encoder = VideoEncoder::new(&video_encoder_init).unwrap();
        let video_encoder_config = VideoEncoderConfig::new(&VIDEO_CODEC, VIDEO_HEIGHT, VIDEO_WIDTH);
        video_encoder.configure(&video_encoder_config);
        let processor = MediaStreamTrackProcessor::new(&MediaStreamTrackProcessorInit::new(
            &video_track.unchecked_into::<MediaStreamTrack>(),
        ))
        .unwrap();
        let reader = processor
            .readable()
            .get_reader()
            .unchecked_into::<ReadableStreamDefaultReader>();
        loop {
            let result = JsFuture::from(reader.read()).await.map_err(|e| {
                console::log_1(&e);
            });
            match result {
                Ok(js_frame) => {
                    let video_frame = Reflect::get(&js_frame, &JsString::from("value"))
                        .unwrap()
                        .unchecked_into::<VideoFrame>();
                    video_encoder.encode(&video_frame);
                    video_frame.close();
                }
                Err(_e) => {
                    console::log_1(&JsString::from("error"));
                }
            }
        }
    });

    // ...
}

// ...
```

啟動服務。

```BASH
RUSTFLAGS=--cfg=web_sys_unstable_apis trunk serve
```

## 實作畫格

TODO

## 程式碼

- [yew-video-streaming](https://github.com/memochou1993/yew-video-streaming)

## 參考資料

- [Let's Build a RUST WebAssembly Frontend App With Yew](https://www.youtube.com/watch?v=lJllt5X6ELg)
