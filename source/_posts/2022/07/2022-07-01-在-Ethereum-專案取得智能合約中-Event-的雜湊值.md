---
title: 在 Ethereum 專案取得智能合約中 Event 的雜湊值
date: 2022-07-01 10:44:26
tags: ["Blockchain", "Ethereum", "JavaScript", "Ethers"]
categories: ["Blockchain", "Ethereum"]
---

## 前言

在 Ethereum 區塊鏈中查看 Event Log 時，所有的 Event 會被使用 Keccak 雜湊函式雜湊後並存放在 Topics 欄位中，因此要對特定 Event 進行查詢時，需要先將 Event 的 Keccak 雜湊值找出來，再對 Topics 進行查詢。

## 做法

### 方法一

使用 `ethers` 套件的 `utils.id` 方法，取得 Event 的 Keccak 雜湊值。

```js
const topic = ethers.utils.id('Transfer(address,address,uint256)');
console.log(topic);
// 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
```

### 方法二

使用 `ethers` 套件的 `interface.getEventTopic` 方法，取得 Event 的雜湊值。

```js
const web3Provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = web3Provider.getSigner();
const contract = new ethers.Contract(import.meta.env.VITE_ERC20MOCK_ADDRESS, ERC20Mock.abi, signer)
const event = 'Transfer';
const topic = contract.interface.getEventTopic(event);
console.log(topic);
// 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
```

### 方法三

直接使用 Keccak 雜湊函式將 Event 的方法簽章進行雜湊，以 Go 語言為例。

```go
package main

import (
	"fmt"
	"github.com/ethereum/go-ethereum/crypto"
)

func main() {
    event := "Transfer(address,address,uint256)"
    topic := crypto.Keccak256Hash([]byte(event)).String()
    fmt.Println(topic)
    // 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
}
```
