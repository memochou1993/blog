---
title: 使用 Solidity 和 Hardhat 開發 Ethereum 智能合約（四）：建立分散式應用程式
permalink: 使用-Solidity-和-Hardhat-開發-Ethereum-智能合約（四）：建立分散式應用程式
date: 2022-02-28 14:02:58
tags: ["區塊鏈", "Ethereum", "Web3", "JavaScript", "Node", "Solidity", "Hardhat", "Smart Contract", "DApp"]
categories: ["區塊鏈", "Ethereum"]
---

## 前言

本文參考 Alchemy 的[範例](https://docs.alchemy.com/alchemy/)進行實作，Alchemy 是一個區塊鏈開發者平台，能夠讓開發者訪問以太坊區塊鏈上的 API 端點，並且可以讀寫交易。

本文採用的區塊鏈測試網路與範例文章不同，使用的是 `rinkeby` 測試網路。

## 建立專案

將 `hello-world-part-four-tutorial` 範例專案克隆下來，並建立一個 React 前端專案。

```BASH
git clone https://github.com/alchemyplatform/hello-world-part-four-tutorial.git
cp -R hello-world-part-four-tutorial/starter-files smart-contract-ui-example
cd smart-contract-ui-example
```

安裝依賴套件。

```BASH
npm i
```

安裝 `@alch/alchemy-web3` 套件。

```BASH
npm install @alch/alchemy-web3
```

安裝 `dot-env` 套件。

```BASH
npm install dotenv --save
```

啟動服務。

```BASH
npm start
```

前往 UI 頁面：<http://localhost:3000/>

## 建立合約實例

新增 `.env` 檔。

```ENV
REACT_APP_ALCHEMY_KEY=wss://eth-rinkeby.ws.alchemyapi.io/v2/your-api-key
```

更新 `src/util/interact.js` 檔。

```JS
require("dotenv").config();
const alchemyKey = process.env.REACT_APP_ALCHEMY_KEY;
const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(alchemyKey);

// export const helloWorldContract;
```

前往 [Etherscan](https://rinkeby.etherscan.io/address/0x6839691078Ef669589F65Fca9968f6430D509812#code) 將合約的 ABI 複製起來，更新 `contract-abi.json` 檔。

```JSON
[{"inputs":[{"internalType":"string","name":"initMsg","type":"string"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"oldStr","type":"string"},{"indexed":false,"internalType":"string","name":"newStr","type":"string"}],"name":"UpdatedMessages","type":"event"},{"inputs":[],"name":"message","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"newMsg","type":"string"}],"name":"update","outputs":[],"stateMutability":"nonpayable","type":"function"}]
```

在 `src/util/interact.js` 檔中引入 ABI 並建立合約實例。

```JS
const contractABI = require("../contract-abi.json")
const contractAddress = "0x6839691078Ef669589F65Fca9968f6430D509812";

export const helloWorldContract = new web3.eth.Contract(
  contractABI,
  contractAddress
);
```

## 印出當前訊息

實作 `src/util/interact.js` 檔中的 `loadCurrentMessage()` 方法。

```JS
export const loadCurrentMessage = async () => { 
    const message = await helloWorldContract.methods.message().call(); 
    return message;
};
```

更新 `src/HelloWorld.js` 檔中的 `useEffect` 方法，在一開始將當前的合約訊息印出來。

```JS
async function fetchMessage() {
  const message = await loadCurrentMessage();
  setMessage(message);
}

useEffect(() => {
  fetchMessage();
}, []);
```

## 監聽合約事件

實作 `src/HelloWorld.js` 檔中的 `addSmartContractListener()` 方法。當合約中的 `UpdatedMessages` 事件被觸發時，取得合約的最新訊息。

```JS
function addSmartContractListener() {
  helloWorldContract.events.UpdatedMessages({}, (error, data) => {
    if (error) {
      setStatus(`😥 ${error.message}`);
    } else {
      const [before, after] = data.returnValues;
      setMessage(after);
      setNewMessage("");
      setStatus("🎉 Your message has been updated!");
    }
  });
}
```

更新 `src/HelloWorld.js` 檔中的 `useEffect` 方法，在一開始監聽合約事件。

```JS
useEffect(() => {
  fetchMessage();
  addSmartContractListener();
}, []);
```

## 連接錢包

實作 `src/util/interact.js` 檔中的 `connectWallet()` 方法。

```JS
export const connectWallet = async () => {
  if (window.ethereum) {
    try {
      const addressArray = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      const obj = {
        status: "👆🏽 Write a message in the text-field above.",
        address: addressArray[0],
      };
      return obj;
    } catch (err) {
      return {
        address: "",
        status: `😥 ${err.message}`,
      };
    }
  } else {
    return {
      address: "",
      status: (
        <span>
          <p>
            {" "}
            🦊{" "}
            <a target="_blank" href={`https://metamask.io/download.html`} rel="noreferrer">
              You must install Metamask, a virtual Ethereum wallet, in your
              browser.
            </a>
          </p>
        </span>
      ),
    };
  }
};
```

實作 `src/HelloWorld.js` 檔中的 `connectWalletPressed()` 方法。當按下連接錢包的按鈕時，連接錢包。

```JS
const connectWalletPressed = async () => {
  const walletResponse = await connectWallet();
  setStatus(walletResponse.status);
  setWallet(walletResponse.address);
};
```

接著再實作 `src/util/interact.js` 檔中的 `getCurrentWalletConnected()` 方法，避免重新整理頁面後，錢包的連接狀態消失。

```JS
export const getCurrentWalletConnected = async () => {
  if (window.ethereum) {
    try {
      const addressArray = await window.ethereum.request({
        method: "eth_accounts",
      });
      if (addressArray.length > 0) {
        return {
          address: addressArray[0],
          status: "👆🏽 Write a message in the text-field above.",
        };
      } else {
        return {
          address: "",
          status: "🦊 Connect to Metamask using the top right button.",
        };
      }
    } catch (err) {
      return {
        address: "",
        status: `😥 ${err.message}`,
      };
    }
  } else {
    return {
      address: "",
      status: (
        <span>
          <p>
            {" "}
            🦊{" "}
            <a target="_blank" href={`https://metamask.io/download.html`} rel="noreferrer">
              You must install Metamask, a virtual Ethereum wallet, in your
              browser.
            </a>
          </p>
        </span>
      ),
    };
  }
};
```

更新 `src/HelloWorld.js` 檔中的 `useEffect` 方法，在一開始取得錢包資訊。

```JS
async function fetchWallet() {
  const {address, status} = await getCurrentWalletConnected();
  setWallet(address);
  setStatus(status); 
}

useEffect(() => {
  fetchMessage();
  addSmartContractListener();
  fetchWallet();
}, []);
```

## 監聽錢包狀態

實作 `src/HelloWorld.js` 檔中的 `addWalletListener()` 方法。當錢包斷開時，更新狀態。

```JS
function addWalletListener() {
  if (window.ethereum) {
    window.ethereum.on("accountsChanged", (accounts) => {
      if (accounts.length > 0) {
        setWallet(accounts[0]);
        setStatus("👆🏽 Write a message in the text-field above.");
      } else {
        setWallet("");
        setStatus("🦊 Connect to Metamask using the top right button.");
      }
    });
  } else {
    setStatus(
      <p>
        {" "}
        🦊{" "}
        <a target="_blank" href={`https://metamask.io/download.html`} rel="noreferrer">
          You must install Metamask, a virtual Ethereum wallet, in your
          browser.
        </a>
      </p>
    );
  }
}
```

更新 `src/HelloWorld.js` 檔中的 `useEffect` 方法，在一開始監聽錢包狀態。

```JS
useEffect(() => {
  fetchMessage();
  addSmartContractListener();
  fetchWallet();
  addWalletListener(); 
}, []);
```

## 建立交易

實作 `src/util/interact.js` 檔中的 `updateMessage()` 方法。透過 Metamask 傳送交易請求。

```JS
export const updateMessage = async (address, message) => {
  if (!window.ethereum || address === null) {
    return {
      status: "💡 Connect your Metamask wallet to update the message on the blockchain.",
    };
  }

  if (message.trim() === "") {
    return {
      status: "❌ Your message cannot be an empty string.",
    };
  }

  // 設置交易參數
  const transactionParameters = {
    to: contractAddress, // 合約地址
    from: address, // 用戶錢包地址
    data: helloWorldContract.methods.update(message).encodeABI(),
  };

  // 建立交易
  try {
    const txHash = await window.ethereum.request({
      method: "eth_sendTransaction",
      params: [transactionParameters],
    });
    return {
      status: (
        <span>
          ✅{" "}
          <a target="_blank" href={`https://rinkeby.etherscan.io/tx/${txHash}`} rel="noreferrer">
            View the status of your transaction on Etherscan!
          </a>
          <br />
          ℹ️ Once the transaction is verified by the network, the message will
          be updated automatically.
        </span>
      ),
    };
  } catch (error) {
    return {
      status: `😥 ${error.message}`,
    };
  }
};
```

實作 `src/HelloWorld.js` 檔中的 `onUpdatePressed()` 方法。當按下更新訊息的按鈕時，更新訊息。

```JS
const onUpdatePressed = async () => {
  const { status } = await updateMessage(walletAddress, newMessage);
  setStatus(status);
};
```

回到 UI 頁面，打上合約的新訊息，按下更新訊息的按鈕，並且完成交易。前往 [Etherscan](https://rinkeby.etherscan.io/address/0x6839691078Ef669589F65Fca9968f6430D509812) 查看，即可看到多了一筆交易。

## 程式碼

- [smart-contract-example](https://github.com/memochou1993/smart-contract-example)
- [smart-contract-client-example](https://github.com/memochou1993/smart-contract-client-example)

## 參考資料

- [Alchemy - Interacting with a Smart Contract](https://docs.alchemy.com/alchemy/tutorials/hello-world-smart-contract/interacting-with-a-smart-contract)
