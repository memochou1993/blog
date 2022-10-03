---
title: 在 Ubuntu 上建立 LikeCoin 驗證者節點
date: 2022-04-30 01:03:32
tags: ["區塊鏈", "LikeCoin"]
categories: ["區塊鏈", "LikeCoin"]
---

## 前言

本文會在 Ubuntu 主機內建立一個網路為 mainnet 的 LikeCoin 驗證者節點。

## 環境

- Ubuntu 20.04 LTS

## 建立節點

下載 `likecoin-chain` 專案。

```
cd ~
git clone https://github.com/likecoin/likecoin-chain.git --branch release/v1.x --single-branch
```

安裝 `make` 命令列工具。

```
sudo apt update
sudo apt install make -y
```

修改 `~/.bashrc` 檔，添加環境變數。

```ENV
export MONIKER='My Validator'
export GENESIS_URL='https://raw.githubusercontent.com/likecoin/mainnet/master/genesis.json'
export LIKED_SEED_NODES='913bd0f4bea4ef512ffba39ab90eae84c1420862@34.82.131.35:26656,e44a2165ac573f84151671b092aa4936ac305e2a@nnkken.dev:26656'
export LIKED_VERSION='1.2.0'
```

重新加載啟動文件。

```BASH
source ~/.bashrc
```

進到專案。

```BASH
cd likecoin-chain
```

執行 `setup-node` 腳本，初始化節點。

```BASH
make -C deploy setup-node
```

## 同步資料

同步資料有許多種方法，可以挑選一種方法進行。

### fastsync

執行 `initialize-systemctl` 腳本，將服務註冊到 `systemd` 管理程式。

```BASH
make -C deploy initialize-systemctl
```

執行 `start-node` 腳本，開始與其他節點同步資料。

```BASH
make -C deploy start-node
```

使用 `systemctl` 指令查看 `liked` 服務狀態。

```BASH
sudo systemctl status liked
```
### statesync

選擇一個已知的區塊開始同步資料，而不是從創世區塊開始。使用以下指令查詢當前的區塊高度和區塊雜湊。

```BASH
curl -s https://fotan-node-1.like.co:443/rpc/block | jq '{ height: .result.block.header.height, hash: .result.block_id.hash }'
```

結果如下：

```BASH
{
  "height": "3623287",
  "hash": "971C8A324E956A5ECE29A2CB37F28432D5C2C031A35E8975CD8386A957B32FCE"
}
```

修改 `~/.liked/config/config.toml` 檔，設定服務端點、區塊高度和區塊雜湊。

```TOML
enable = true

rpc_servers = "https://fotan-node-1.like.co:443/rpc/,https://fotan-node-2.like.co:443/rpc/"
trust_height = 3623287
trust_hash = "971C8A324E956A5ECE29A2CB37F28432D5C2C031A35E8975CD8386A957B32FCE"
trust_period = "168h0m0s"
```

修改 `~/.liked/config/app.toml` 檔，設定最低手續費。

```TOML
minimum-gas-prices = "1.0nanolike"
```

執行 `initialize-systemctl` 腳本，將服務註冊到 `systemd` 管理程式。

```BASH
make -C deploy initialize-systemctl
```

執行 `start-node` 腳本，開始與其他節點同步資料。

```BASH
make -C deploy start-node
```

使用 `systemctl` 指令查看 `liked` 服務狀態。

```BASH
sudo systemctl status liked
```

### snapshot

安裝 `zstd` 命令列工具。

```BASH
sudo apt-get update
sudo apt install zstd
```

從社群的驗證者所提供的[快照列表](https://public.nnkken.dev/liked-data-archive/)下載快照檔案。

```BASH
wget https://public.nnkken.dev/liked-data-archive/liked-data-2022-04-30.tar.zst
```

解壓縮。

```BASH
tar --use-compress-program=unzstd -xvf liked-data-2022-04-30.tar.zst
```

覆蓋快照檔案。

```BASH
mv data ~/.liked/data
```

執行 `initialize-systemctl` 腳本，將服務註冊到 `systemd` 管理程式。

```BASH
make -C deploy initialize-systemctl
```

執行 `start-node` 腳本，開始與其他節點同步資料。

```BASH
make -C deploy start-node
```

使用 `systemctl` 指令查看 `liked` 服務狀態。

```BASH
sudo systemctl status liked
```

## 檢查狀態

使用 `journalctl` 指令檢查 `liked` 服務日誌。

```BASH
journalctl -u liked -f -n 100
```

使用以下指令查看節點的同步狀態。

```BASH
curl -s localhost:26657/status
```

## 參考資料

- [LikeCoin - Setup a node](https://docs.like.co/validator/likecoin-chain-node/setup-a-node)
