---
title: 使用 Metaplex 標準在 Solana 區塊鏈上建立 NFT 非同質化代幣
permalink: 使用-Metaplex-標準在-Solana-區塊鏈上建立-NFT-非同質化代幣
date: 2022-04-27 23:11:16
tags: ["區塊鏈", "Solana", "Rust", "Web3", "JavaScript", "Smart Contract", "NFT", "DApp", "Metaplex"]
categories: ["區塊鏈", "Solana"]
---

## 前言

本文為「Solana 開發者的入門指南」影片的學習筆記。

## 建立專案

建立專案。

```BASH
mkdir solana-nft-example
cd solana-nft-example
```

## 前置作業

### 建立錢包

到 [Arweave Faucet](https://faucet.arweave.net/) 頁面進行身份驗證，再下載[錢包](https://chrome.google.com/webstore/detail/arweave/iplppiggblloelhoglpmkmbinggcaaoc)，匯入 keyfile 檔案。

### 下載素材

安裝 `gdown` 下載工具。

```BASH
pip install gdown
```

建立資料夾。

```BASH
mkdir sandbox
```

下載素材。

```BASH
gdown --folder https://drive.google.com/drive/folders/1RLz4J7TTh9cnXKWJlUb6_SC5dSnDYiBL -O sandbox/background
gdown --folder https://drive.google.com/drive/folders/1jj4V7GNvFqc2UROZhaEvoaF1t8vP53TF -O sandbox/base
gdown --folder https://drive.google.com/drive/folders/1FXuztlvSfIsStFXu4_dInXwV9xz_b-gz -O sandbox/clothes
gdown --folder https://drive.google.com/drive/folders/1TM5zK9pHm73oSO1U8hpg6G1An14cyagU -O sandbox/faces
gdown --folder https://drive.google.com/drive/folders/1GKYw77k0gQRX-AbtTtNChzpGsCBNL1bJ -O sandbox/hats
```

### 安裝素材引擎

下載 `hashlips_art_engine` 專案。

```BASH
git clone https://github.com/HashLips/hashlips_art_engine.git
cd hashlips_art_engine
```

安裝依賴套件。

```BASH
yarn
```

回到專案目錄。

```BASH
cd ..
```

### 安裝上傳工具

下載 `arweave-image-uploader` 專案。

```BASH
git clone https://github.com/thuglabs/arweave-image-uploader.git
cd arweave-image-uploader
```

安裝依賴套件。

```BASH
yarn
```

回到專案目錄。

```BASH
cd ..
```

### 安裝鑄造工具

安裝 `metaboss` 指令，是一個 Solana Metaplex NFT 鑄造工具。

```BASH
cargo install --locked metaboss
```

查看版本。

```BASH
metaboss --version
Metaboss 0.6.1
```

### 安裝 Proxy 工具

安裝 [Proxyman](https://proxyman.io/release/osx/Proxyman_latest.dmg) 應用程式。

## 建立圖片

修改 `hashlips_art_engine/src/main.js` 檔。

```JS
// ...
let traits = layerConfigurations[0].layersOrder.map(o => o.name);
let metadataListCsv = [`Name,${traits.join(",")}`];

// ...
metadataListCsv.push(`${tempMetadata.name.split('#')[1]},${attributesList.map(o => o.value).join(",")}`);

// ...
const writeMetaDataCsv = (_data) => {
  fs.writeFileSync(`${buildDir}/_metadata.csv`, _data);
};

// ...
writeMetaDataCsv(metadataListCsv.join('\n'));
```

修改 `hashlips_art_engine/src/config.js` 檔。

```JS
// ...
const network = NETWORK.sol;

// ...
const namePrefix = "";

// ...
const layerConfigurations = [
  {
    growEditionSizeTo: 10,
    layersOrder: [
      { name: "background" },
      { name: "base" },
      { name: "clothes" },
      { name: "faces" },
      { name: "hats" },
    ],
  },
];
```

刪除預設的 `hashlips_art_engine/layers` 資料夾。

```BASH
rm -rf hashlips_art_engine/layers
```

將素材複製到 `hashlips_art_engine/layers` 資料夾。

```BASH
cp -r sandbox ./hashlips_art_engine/layers
```

修改素材的檔案名稱，使用 `#` 符號代表機率的權重。

```BASH
mv hashlips_art_engine/layers/background/bg1.png hashlips_art_engine/layers/background/bg1#1.png
mv hashlips_art_engine/layers/background/bg2.png hashlips_art_engine/layers/background/bg2#1.png
mv hashlips_art_engine/layers/background/bg3.png hashlips_art_engine/layers/background/bg3#1.png
mv hashlips_art_engine/layers/background/bg4.png hashlips_art_engine/layers/background/bg4#1.png
mv hashlips_art_engine/layers/background/bg5.png hashlips_art_engine/layers/background/bg5#1.png

mv hashlips_art_engine/layers/base/base1.png hashlips_art_engine/layers/base/base1#1.png
mv hashlips_art_engine/layers/base/base2.png hashlips_art_engine/layers/base/base2#1.png

mv hashlips_art_engine/layers/clothes/clothes1.png hashlips_art_engine/layers/clothes/clothes1#1.png
mv hashlips_art_engine/layers/clothes/clothes2.png hashlips_art_engine/layers/clothes/clothes2#1.png
mv hashlips_art_engine/layers/clothes/clothes3.png hashlips_art_engine/layers/clothes/clothes3#1.png
mv hashlips_art_engine/layers/clothes/clothes4.png hashlips_art_engine/layers/clothes/clothes4#1.png
mv hashlips_art_engine/layers/clothes/clothes5.png hashlips_art_engine/layers/clothes/clothes5#1.png

mv hashlips_art_engine/layers/faces/face1.png hashlips_art_engine/layers/faces/face1#1.png
mv hashlips_art_engine/layers/faces/face2.png hashlips_art_engine/layers/faces/face2#1.png
mv hashlips_art_engine/layers/faces/face3.png hashlips_art_engine/layers/faces/face3#1.png
mv hashlips_art_engine/layers/faces/face4.png hashlips_art_engine/layers/faces/face4#1.png
mv hashlips_art_engine/layers/faces/face5.png hashlips_art_engine/layers/faces/face5#1.png

mv hashlips_art_engine/layers/hats/hat1.png hashlips_art_engine/layers/hats/hat1#1.png
mv hashlips_art_engine/layers/hats/hat2.png hashlips_art_engine/layers/hats/hat2#1.png
mv hashlips_art_engine/layers/hats/hat3.png hashlips_art_engine/layers/hats/hat3#1.png
mv hashlips_art_engine/layers/hats/hat4.png hashlips_art_engine/layers/hats/hat4#1.png
mv hashlips_art_engine/layers/hats/hat5.png hashlips_art_engine/layers/hats/hat5#1.png
```

產生圖片。

```BASH
cd hashlips_art_engine
yarn run build
```

輸出結果如下。

```BASH
Created edition: 0, with DNA: b3f8f58560a52473411e20f051744158840d84c0
Created edition: 1, with DNA: 87be6ad0e0c0ef2f89656f80dd2d2ebf3e6a25bf
Created edition: 2, with DNA: 870f9eab44a52ef451620af3a64a63c1b2cd7d56
Created edition: 3, with DNA: 6185f2ea510864598d596605ec3fa0b02c6de9c6
Created edition: 4, with DNA: 3defed1126a819cf902e17c8e7a4d8a043def190
Created edition: 5, with DNA: a5e8a5350759927c767fdcd39a87b17f8acadf02
Created edition: 6, with DNA: 87ae064d71915f56ee555bcf8e26ae868af4cf3f
Created edition: 7, with DNA: 6410d947ce4583c8cb7ac87af8f89c317bc50538
Created edition: 8, with DNA: 5aaf1ecd6d2fe25091734b03f6cf105da61114d0
Created edition: 9, with DNA: 2f8877d1b472da2ad18f9aca09bca0e30fdf6baf
```

查看產生各個配件的機率，可以執行以下指令。

```BASH
yarn rarity
```

## 上傳圖片

進到 `arweave-image-uploader` 資料夾。

```BASH
cd arweave-image-uploader
```

安裝 `dotenv` 套件。

```BASH
yarn add dotenv
```

新增 `.env` 檔，將 Arweave 錢包的 keyfile 檔案的內容貼上。

```ENV
KEY={"kty":"RSA","e":"...","n":"..."}
```

查看本地錢包地址。

```BASH
solana address
```

更新 `arweave-image-uploader/uploader.js` 檔，並且修改 `address` 參數為自己的錢包地址。

```JS
import fs from "fs";
import path, { dirname } from "path";
import { fileURLToPath } from "url";
import Arweave from "arweave";
import csv from "csv-parser";
import dotenv from "dotenv";

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const results = [];

const initOptions = {
  host: "arweave.net", // Hostname or IP address for a Arweave host
  port: 443, // Port
  protocol: "https", // Network protocol http or https
  timeout: 20000, // Network request timeouts in milliseconds
  logging: false, // Enable network request logging
};

const getNftName = (name) => `ART #${name}`;

const getMetadata = (name, imageUrl, attributes) => ({
  name: getNftName(name),
  symbol: "SMT",
  description: "My Art Work",
  seller_fee_basis_points: 100,
  external_url: "https://solmeet.dev",
  attributes,
  collection: {
    name: "SolMeet",
    family: "Dev",
  },
  properties: {
    files: [
      {
        uri: imageUrl,
        type: "image/png",
      },
    ],
    category: "image",
    maxSupply: 0,
    creators: [
      {
        address: "C4pPW8ZmWFYsAUNcFzEUA7mgdS6ABV9Z3sBobPvVthgi",
        share: 100,
      },
    ],
  },
  image: imageUrl,
});

// run localy
// npx @textury/arlocal
const initOptionsLocal = {
  host: "localhost", // Hostname or IP address for a Arweave host
  port: 1984, // Port
  protocol: "http", // Network protocol http or https
  timeout: 20000, // Network request timeouts in milliseconds
  // logging: false,     // Enable network request logging
};

const arweave = Arweave.init(initOptions);
let key = JSON.parse(process.env.KEY);

const runUpload = async (data, contentType, isUploadByChunk = false) => {
  const tx = await arweave.createTransaction({ data: data }, key);

  tx.addTag(...contentType);

  await arweave.transactions.sign(tx, key);

  if (isUploadByChunk) {
    const uploader = await arweave.transactions.getUploader(tx);

    while (!uploader.isComplete) {
      await uploader.uploadChunk();
      console.log(
        `${uploader.pctComplete}% complete, ${uploader.uploadedChunks}/${uploader.totalChunks}`
      );
    }
  }

  //   Do we need to post with uploader?
  await arweave.transactions.post(tx);

  //   console.log("url", `http://localhost:1984/${tx.id}`);
  //   console.log("url", `https://arweave.net/${tx.id}`);
  return tx;
};

const folder = "./public/images/";
let metadataCollection = {};

let metadataUri = [];

const getAttributes = (props) => {
  // map attributes to the proper key/value objects
  const attrs = Object.keys(props).map((key) => {
    return {
      trait_type: key,
      value: props[key],
    };
  });

  return attrs;
};

const iterateOverItems = async () => {
  try {
    for (const row of results) {
      // get separately name and props
      const { Name: name, ...props } = row;
      console.log("name", name);
      const nameByNumber = Number.parseInt(name);

      const filePath = folder + nameByNumber + ".png";
      console.log("filePath", filePath);

      let newItem = {};

      try {
        const data = fs.readFileSync(filePath);
        // if (!data) console.warn(`Can't find file: ${filePath}`);

        const contentType = ["Content-Type", "image/png"];
        const { id } = await runUpload(data, contentType, true);
        const imageUrl = id ? `https://arweave.net/${id}` : undefined;
        console.log("imageUrl", imageUrl);

        const attributes = getAttributes(props);

        const metadata = getMetadata(name, imageUrl, attributes);
        const metaContentType = ["Content-Type", "application/json"];
        const metadataString = JSON.stringify(metadata);
        const { id: metadataId } = await runUpload(
          metadataString,
          metaContentType
        );
        const metadataUrl = id
          ? `https://arweave.net/${metadataId}`
          : undefined;

        metadataUri.push(metadataUrl);

        console.log("metadataUrl", metadataUrl);
        newItem = {
          [nameByNumber]: {
            name: getNftName(name),
            uri: metadataUrl,
          },
        };
      } catch (error) {
        newItem = {
          [nameByNumber]: undefined,
        };
      }

      //   update collection with new item
      metadataCollection = { ...metadataCollection, ...newItem };
    }

    // All images iterated
    console.log(metadataCollection);

    // Save data to json in /public/
    const data = JSON.stringify(metadataCollection);
    fs.writeFileSync("./public/arweave-images.json", data);
    const uris = JSON.stringify(metadataUri);
    fs.writeFileSync("./public/arweave-uris.json", uris);
  } catch (e) {
    // Catch anything bad that happens
    console.error("We've thrown! Whoops!", e);
  }
};

const readCsv = async () => {
  //   Consider to use local wallet instead of generated one.
  //.  I'm not sure how this works, since newly generated wallet have 0 balance. 🤷🏻‍♂️
  //.  So, I comment out this line for now.
  //   key = await arweave.wallets.generate();

  fs.createReadStream(path.resolve(__dirname, "public", "data.csv"))
    .pipe(csv())
    .on("data", (data) => results.push(data))
    .on("end", () => {
      //   console.log(results);
      //   {
      //     Name: '0000',
      //     'Background Color': 'palegreen',
      //     'Head Color': 'lightblue',
      //     'Neck Color': 'lightslategray',
      //      ...
      //   },

      iterateOverItems();
    });
};

readCsv();
```

刪除預設圖片。

```BASH
rm -rf public/images
```

複製生成圖片。

```BASH
cp -r ../hashlips_art_engine/build/images/ public/images/
```

複製 `_metadata.csv` 檔。

```BASH
cp ../hashlips_art_engine/build/_metadata.csv public/data.csv
```

上傳圖片。

```BASH
yarn upload
```

輸出結果如下：

```JSON
{
  '0': {
    name: 'ART #0',
    uri: 'https://arweave.net/mph4r2j1yaMKdxOIYI9VWYdAC2Vtpr26gGQfn6A_N5Q'
  },
  '1': {
    name: 'ART #1',
    uri: 'https://arweave.net/ELf4G6Y1Kpvx4HTvbr5XoIDdZYHU7xcfb_xYwVxrQE8'
  },
  '2': {
    name: 'ART #2',
    uri: 'https://arweave.net/DHTri_WX3ZFhiMSrNM5TDgsPmKWhjI_svzFMsd9aP24'
  },
  '3': {
    name: 'ART #3',
    uri: 'https://arweave.net/y10tzH7fRfQcPs-tJQ447legbpc6yyPp1hlJnHjIYmc'
  },
  '4': {
    name: 'ART #4',
    uri: 'https://arweave.net/CJ-FT3YhNlFnqesu5NEg4rQtK-hKCZGZsCLlca9BfZo'
  },
  '5': {
    name: 'ART #5',
    uri: 'https://arweave.net/mxJxDsoXihGQ8qGboDF2Obp53R_BumtcV3-4u71y3_o'
  },
  '6': {
    name: 'ART #6',
    uri: 'https://arweave.net/xie1vd_7Es1OhPG_Va2ZKqn6nBW7MJE17aYPP4HWVxw'
  },
  '7': {
    name: 'ART #7',
    uri: 'https://arweave.net/WUkMGPGPOpQ-7sIHS0sFxuqgxdl8zfG-X2DJsWUa__4'
  },
  '8': {
    name: 'ART #8',
    uri: 'https://arweave.net/ix_qbKOPHDJGZKnRT86AcDnJJ7GbH5yLjw_NnnB6G3U'
  },
  '9': {
    name: 'ART #9',
    uri: 'https://arweave.net/NX8eGxe_a1LSBYmp4_FZSj00p5UFKQUsUUTQ6t5P1NE'
  }
}
```

## 鑄造

使用 `mainnet-fork` 網路測試。

```BASH
solana config set --url https://rpc-mainnet-fork.epochs.studio
solana config set --ws wss://rpc-mainnet-fork.epochs.studio/ws
```

```BASH
mkdir mint
cd mint
```

新增 `mint.js` 檔。

```JS
const fs = require("fs");
const { exec } = require("child_process");

// Use metaboss to interact with Metaplex

const main = () => {
  const content = fs.readFileSync(
    "../arweave-image-uploader/public/arweave-uris.json",
    "utf-8"
  );
  const parsed = JSON.parse(content);
  const nftUris = parsed;

  nftUris.forEach((uri) => {
    console.log("uri", uri);
    // Mint
    exec(
      `metaboss mint one --external-metadata-uri ${uri} --keypair ${process.env.KEYPAIR} --receiver ${process.env.RECEIVER} --immutable --primary-sale-happened`,
      (error, stdout, stderr) => {
        if (error) {
          console.error(`${error}`);
          return;
        }
        console.log(`${stdout}`);
        console.error(`${stderr}`);

        // Extract mint
        const regex = /[A-HJ-NP-Za-km-z1-9]{40,50}/g;
        const nftMint = stdout.match(regex)[1];
        console.log(`nftMint: ${nftMint}`);
      }
    );
  });
};

main();
```

執行以下指令。

```BASH
KEYPAIR=~/.config/solana/id.json RECEIVER=<RECEIVER_ADDRESS> AUTHORITY=<RECEIVER_ADDRESS> node mint.js 
```

## 參考資料

- [A Complete Guide to Mint Solana NFTs with Metaplex](https://book.solmeet.dev/notes/complete-guide-to-mint-solana-nft)
- [Solana 開發者的入門指南](https://youtu.be/6SiQq-9J7lU)
