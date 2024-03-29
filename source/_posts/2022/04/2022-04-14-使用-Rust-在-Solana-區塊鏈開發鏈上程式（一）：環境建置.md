---
title: 使用 Rust 在 Solana 區塊鏈開發鏈上程式（一）：環境建置
date: 2022-04-14 15:16:51
tags: ["Blockchain", "Solana", "Rust", "JavaScript", "Smart Contract", "DApp"]
categories: ["Blockchain", "Solana"]
---

## 前言

本文為「Solana 開發者的入門指南」影片的學習筆記。

## 安裝 Rust

安裝 Rust 語言。

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

查看版本。

```bash
rustup --version
rustup 1.24.3 (ce5817a94 2021-05-31)
```

## 安裝 Solana

安裝 Solana 命令列工具。

```bash
sh -c "$(curl -sSfL https://release.solana.com/v1.10.0/install)"
```

將執行檔路徑添加至環境變數。

```bash
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
```

查看版本。

```bash
solana --version
solana-cli 1.10.0 (src:7dbde224; feat:275730699)
```

## 啟動節點

使用 `solana-keygen` 指令建立一個錢包（一組公私鑰）。

```bash
solana-keygen new
```

將命令列設定的 `url` 參數設置成 `localhost`。

```bash
solana config set --url localhost
```

開啟一個新的終端視窗，使用 `solana-test-validator` 指令，啟動一個本地的 Solana 節點。

```bash
solana-test-validator
```

## 充值

為錢包充值 1 SOL。

```bash
solana airdrop 1
```

## 使用範例專案

下載 `example-helloworld` 範例專案。

```bash
git clone https://github.com/solana-labs/example-helloworld.git solana-example
cd solana-example
```

安裝依賴套件。

```bash
npm ci
```

安裝 TypeScript Node 執行環境。

```bash
npm i -g ts-node
```

編譯 `helloworld` 鏈上程式。

```bash
npm run build:program-rust
```

部署 `helloworld` 鏈上程式。

```bash
solana program deploy dist/program/helloworld.so
```

啟動客戶端。

```bash
npm run start
```

輸出訊息如下：

```bash
Let's say hello to a Solana account...
Connection to cluster established: http://localhost:8899 { 'feature-set': 275730699, 'solana-core': '1.10.0' }
Using account C4pPW8ZmWFYsAUNcFzEUA7mgdS6ABV9Z3sBobPvVthgi containing 499999998.6475557 SOL to pay for fees
Using program 2pCXRB6zESaghdN17WNeBgCjQwgfWK4MZNNK2YkfavPW
Creating account 5kgQAzrAn4M274sypVbXx6s6xFNkYChyfSrxCQkekTNf to say hello to
Saying hello to 5kgQAzrAn4M274sypVbXx6s6xFNkYChyfSrxCQkekTNf
5kgQAzrAn4M274sypVbXx6s6xFNkYChyfSrxCQkekTNf has been greeted 1 time(s)
Success
```

## 參考資料

- [example-helloworld](https://github.com/solana-labs/example-helloworld)
- [A Starter Kit for New Solana Developer](https://book.solmeet.dev/notes/solana-starter-kit)
- [Solana 開發者的入門指南](https://youtu.be/OIjsPrcPe8s)
