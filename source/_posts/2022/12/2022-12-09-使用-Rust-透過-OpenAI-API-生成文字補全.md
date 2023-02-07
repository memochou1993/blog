---
title: 使用 Rust 透過 OpenAI API 生成文字補全
date: 2022-12-09 00:17:05
tags: ["程式設計", "Rust", "GPT", "AI", "OpenAI"]
categories: ["程式設計", "Rust", "其他"]
---

## 前置作業

在 [OpenAI](https://openai.com/api/) 註冊一個帳號，並且在 [API keys](https://beta.openai.com/account/api-keys) 頁面產生一個 API 金鑰。

## 建立專案

建立專案。

```bash
cargo new gpt-cli-rust
cd gpt-cli-rust
```

安裝依賴套件。

```toml
[dependencies]
reqwest = { version = "0.11", features = ["json"] }
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.23", features = ["full"] }
dotenvy = { version = "0.15" }
```

新增 `.env` 檔。

```env
OPENAI_API_URL=https://api.openai.com/v1
OPENAI_API_KEY=
```

新增 `.gitignore` 檔。

```env
/target
.env
```

## 實作

新增 `src/lib.rs` 檔。

```rs
use reqwest::header::HeaderMap;
use serde::{Deserialize, Serialize};
use std::{env, error::Error};

pub async fn fetch() -> Result<Response, Box<dyn Error>> {
    let api_url = env::var("OPENAI_API_URL").unwrap();
    let api_key = env::var("OPENAI_API_KEY").unwrap();

    let mut headers = HeaderMap::new();
    headers.insert("Content-Type", "application/json".parse().unwrap());
    headers.insert(
        "Authorization",
        format!("Bearer {}", api_key).parse().unwrap(),
    );

    let body = Request{
        model: String::from("text-davinci-003"),
        prompt: String::from("\n\nHuman: Hello, who are you?\nAI: I am an AI created by OpenAI. How can I help you today?\nHuman: Hello, who are you?"),
        temperature: 0.9,
        max_tokens: 150,
        top_p: 1.0,
        frequency_penalty: 0.0,
        presence_penalty: 0.6,
        stop: vec![String::from(" Human:"), String::from(" AI:")],
    };

    let client = reqwest::Client::new();
    let res = client
        .post(format!("{}/completions", api_url))
        .headers(headers)
        .json(&body)
        .send()
        .await?
        .json::<Response>()
        .await?;

    return Ok(res);
}

#[derive(Deserialize, Debug)]
pub struct Response {
    pub id: Option<String>,
    pub object: Option<String>,
    pub created: Option<usize>,
    pub model: Option<String>,
    pub choices: Option<Vec<Choice>>,
    pub usage: Option<Usage>,
}

#[derive(Deserialize, Debug)]
pub struct Choice {
    pub text: Option<String>,
    pub index: Option<usize>,
    pub logprobs: Option<usize>,
    pub finish_reason: Option<String>,
}

#[derive(Deserialize, Debug)]
pub struct Usage {
    pub prompt_tokens: Option<usize>,
    pub completion_tokens: Option<usize>,
    pub total_tokens: Option<usize>,
}

#[derive(Serialize)]
struct Request {
    model: String,
    prompt: String,
    temperature: f32,
    max_tokens: usize,
    top_p: f32,
    frequency_penalty: f32,
    presence_penalty: f32,
    stop: Vec<String>,
}
```

新增 `src/main.rs` 檔。

```rs
use dotenvy::dotenv;
use openai_cli_rust::fetch;
use std::error::Error;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    dotenv().ok();

    let resp = fetch().await?;
    if let Some(choices) = resp.choices {
        for choice in choices.iter() {
            println!("{:?}", choice.text);
        }
    }

    Ok(())
}
```

執行程式。

```bash
cargo run
```

## 程式碼

- [gpt-cli-rust](https://github.com/memochou1993/gpt-cli-rust)

## 參考資料

- [OpenAI - Documentation](https://beta.openai.com/docs)
