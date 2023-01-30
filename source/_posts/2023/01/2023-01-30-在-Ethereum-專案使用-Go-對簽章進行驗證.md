---
title: 在 Ethereum 專案使用 Go 對簽章進行驗證
date: 2023-01-30 17:14:22
tags: ["區塊鏈", "Ethereum", "Go", "Ethers", "Web3", "MetaMask"]
categories: ["區塊鏈", "Ethereum"]
---

## 前端

### 使用 Ethers.js 套件

新增 `main.js` 檔。

```js
import { ethers } from 'ethers';

const message = 'hello';
const hexMessage = ethers.utils.hexlify(ethers.utils.toUtf8Bytes(message));
const web3Provider = new ethers.providers.Web3Provider(window.ethereum, 'any');
const [account] = await web3Provider.send('eth_requestAccounts');
const sig = await web3Provider.getSigner().signMessage(message);
const recovered = ethers.utils.verifyMessage(message, sig);

console.log('message', message);
console.log('hexMessage', hexMessage);
console.log('account', account);
console.log('sig', sig);
console.log('recovered', recovered);
```

### 使用 Web3.js 套件

新增 `main.js` 檔。

```js
import Web3 from 'web3';

const web3 = new Web3(window.ethereum);
const [account] = await web3.eth.getAccounts();
const message = 'hello';
const hexMessage = web3.utils.utf8ToHex(message);
const sig = await web3.eth.personal.sign(hexMessage, account, '');
const recovered = await web3.eth.personal.ecRecover('hello', sig);

console.log('message', message);
console.log('hexMessage', hexMessage);
console.log('account', account);
console.log('sig', sig);
console.log('recovered', recovered);
```

## 後端

新增 `main.go` 檔。

```go
package main

import (
	"github.com/ethereum/go-ethereum/accounts"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	"log"
	"strings"
)

func main() {
	hexStr := "0x68656c6c6f" // hello
	sig := "0x7c4f5f867466a9244d9c5e59d7b0f0a57b56209789f13997cff86485875eb6bc2e7e802ed7c05c6dc6f5bf27735e43a0240d3404571fbbb222c769f56488e77f1c"
	data, err := hexutil.Decode(hexStr)
	if err != nil {
		log.Fatal(err)
	}
	recovered := recoverPubKey(data, sig)
	log.Println(recovered) // 0x521ec61eb00a45fa2a17e92762dd1d43de9ffe26
}

func recoverPubKey(data []byte, sig string) string {
	hash := accounts.TextHash(data)
	s, err := hexutil.Decode(sig)
	if err != nil {
		return ""
	}
	if s[crypto.RecoveryIDOffset] == 27 || s[crypto.RecoveryIDOffset] == 28 {
		s[crypto.RecoveryIDOffset] -= 27
	}
	recovered, err := crypto.SigToPub(hash, s)
	if err != nil {
		return ""
	}
	addr := crypto.PubkeyToAddress(*recovered)
	return strings.ToLower(addr.Hex())
}
```

執行程式。

```bash
go run main.go
```

## 參考資料

- [dcb9/eth_sign_verify.go](https://gist.github.com/dcb9/385631846097e1f59e3cba3b1d42f3ed)
