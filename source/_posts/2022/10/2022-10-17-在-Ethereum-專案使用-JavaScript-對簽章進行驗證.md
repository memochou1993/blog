---
title: 在 Ethereum 專案使用 JavaScript 對簽章進行驗證
date: 2022-10-17 01:33:06
tags: ["區塊鏈", "Ethereum", "JavaScript", "Node", "Ethers", "Web3", "MetaMask"]
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

新增 `recover.js` 檔。

```js
import ethSigUtil from 'eth-sig-util';

const account = '0x521ec61eb00a45fa2a17e92762dd1d43de9ffe26';
const data = '0x68656c6c6f'; // hello
const sig = '0x7c4f5f867466a9244d9c5e59d7b0f0a57b56209789f13997cff86485875eb6bc2e7e802ed7c05c6dc6f5bf27735e43a0240d3404571fbbb222c769f56488e77f1c';

const recovered = ethSigUtil.recoverPersonalSignature({
    data,
    sig,
});

console.log('account', account);
console.log('recovered', recovered); // 0x521ec61eb00a45fa2a17e92762dd1d43de9ffe26
```

執行腳本。

```bash
node recover.js
```

## 程式碼

- [eth-message-signing](https://github.com/memochou1993/eth-message-signing)
