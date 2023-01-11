---
title: 使用 Ethers.js 與 Ethereum 區塊鏈互動
date: 2022-06-14 00:23:25
tags: ["區塊鏈", "Ethereum", "JavaScript", "Ethers", "MetaMask"]
categories: ["區塊鏈", "Ethereum"]
---

## 做法

安裝 `ethers` 套件。

```js
npm install ethers --save
```

引入 `ethers` 套件和合約介面。

```js
import { ethers } from 'ethers';
import ERC20Mock from '../build/contracts/ERC20Mock.json';
import MyStake from '../build/contracts/MyStake.json';
```

建立 Web3 提供者。

```js
// 注入 MetaMask 提供的 window.ethereum 物件
const web3Provider = new ethers.providers.Web3Provider(window.ethereum);
// 監聽錢包帳戶切換
web3Provider.provider.on('accountsChanged', () => {});
```

建立合約實例。

```js
// 取得簽章者
const signer = web3Provider.getSigner();
// 建立 ERC20Mock 合約實例
const ERC20Mock = new ethers.Contract(import.meta.env.VITE_ERC20MOCK_ADDRESS, ERC20Mock.abi, signer);
// 建立 MyStake 合約實例
const MyStake = new ethers.Contract(import.meta.env.VITE_MYSTAKE_ADDRESS, MyStake.abi, signer);
```

取得錢包帳戶。

```js
const [account] = await web3Provider.send('eth_requestAccounts');
```

取得合約中的資料。

```js
// 取得 ERC20Mock 合約所使用的小數點位數
const decimals = await ERC20Mock.decimals();
// 取得使用者授權給 MyStake 合約使用 ERC20Mock 代幣的額度
const allowance = await ERC20Mock.allowance(account, MyStake.address);
// 取得使用者的 ERC20Mock 代幣餘額
const balanceOf = await ERC20Mock.balanceOf(account);
```

授權 `MyStake` 合約使用 `ERC20Mock` 合約中的代幣。

```js
const amount = ethers.BigNumber.from(2).pow(256).sub(1); // 使用 BigNumber 處理金額
const res = await ERC20Mock.approve(MyStake.address, amount);
await res.wait();
```
