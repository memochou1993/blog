---
title: 使用 JavaScript 透過 Moralis API 存取 NFT 智能合約資料
permalink: 使用-JavaScript-透過-Moralis-API-存取-NFT-智能合約資料
date: 2022-09-03 21:32:51
tags: ["區塊鏈", "NFT", "JavaScript"]
categories: ["區塊鏈", "其他"]
---

## 做法

新增 `.env` 檔。

```ENV
VITE_ERC721_CONTRACT_ADDRESS=0x...
VITE_ERC1155_CONTRACT_ADDRESS=0x...
VITE_MORALIS_API_URL=https://deep-index.moralis.io/api/v2
VITE_MORALIS_API_KEY=your-api-key
```

新增 `api.js` 檔。

```JS
const {
  VITE_ERC721_CONTRACT_ADDRESS,
  VITE_ERC1155_CONTRACT_ADDRESS,
  VITE_MORALIS_API_URL,
  VITE_MORALIS_API_KEY,
} = import.meta.env;

const request = (url, method) => {
  return fetch(url, { method, headers: { 'X-API-Key': VITE_MORALIS_API_KEY } });
};

// 同步特定合約的 NFT 資訊
const syncContract = (contract) => {
  console.log('Syncing contract...');
  const url = `${VITE_MORALIS_API_URL}/nft/${contract}/sync?chain=goerli`;
  return request(url, 'PUT');
};

// 取得特定帳號的 NFT 列表
const fetchTokens = async (account) => {
  console.log('Fetching tokens...');
  const url = `${VITE_MORALIS_API_URL}/${account}/nft?chain=goerli&token_addresses=${VITE_ERC721_CONTRACT_ADDRESS}&token_addresses=${VITE_ERC1155_CONTRACT_ADDRESS}`;
  const r = await request(url, 'GET');
  return await r.json();
};

// 重新同步特定合約的特定 NFT 資訊
const resyncToken = async (contract, tokenId) => {
  console.log('Resyncing token...');
  const url = `${VITE_MORALIS_API_URL}/nft/${contract}/${tokenId}/metadata/resync?chain=goerli&flag=metadata&mode=sync`;
  const r = await request(url, 'GET');
  return await r.json();
};

export default {
  syncContract,
  fetchTokens,
  resyncToken,
};
```

## 參考資料

- [Moralis - Documentation](https://docs.moralis.io/)
