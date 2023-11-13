---
title: 使用 JavaScript 和 MetaMask 擴充功能發送-Ethereum-區塊鏈交易
date: 2022-03-06 23:20:02
tags: ["Blockchain", "Ethereum", "JavaScript", "Web3", "MetaMask"]
categories: ["Blockchain", "Ethereum"]
---

## 實作

新增 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <button>Send ETH</button>
    <script src="app.js"></script>
</body>
</html>
```

新增 `app.js` 檔。

```js
if (typeof window.ethereum !== 'undefined') {
  console.log('MetaMask is installed!');
}

const button = document.querySelector('button');

button.addEventListener('click', async () => {
  const [from] = await ethereum.request({
    method: 'eth_requestAccounts',
  });
  const to = '0x31B98D14007bDEe637298086988A0bBd31184523';
  try {
    const txHash = await ethereum.request({
      method: 'eth_sendTransaction',
      params: [
        {
          from, // 轉出錢包地址
          to, // 轉入錢包地址
          gas: (30000).toString(16), // Gas 上限
          gasPrice: (1500000000).toString(16), // Gas 價格（約 1.5 到 3.0 Gwei）
          value: (1000000000000000).toString(16), // 交易金額
        },
      ],
    });
    console.log(txHash);
  } catch {
    //
  }
});
```

啟動網頁。

```bash
live-server
```

## 參考資料

- [MetaMask Docs](https://docs.metamask.io/guide/)
