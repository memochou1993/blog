---
title: 使用 nft-art-generator 套件產生 NFT 組合圖片
permalink: 使用-nft-art-generator-套件產生-NFT-組合圖片
date: 2022-08-29 22:25:55
tags: ["程式設計", "JavaScript", "NFT"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 做法

建立專案。

```BASH
mkdir nft-art-generator-example
cd nft-art-generator-example
```

下載素材圖片。

```BASH
git clone https://github.com/BelleShih/Leopard-cat.git images
```

安裝套件。

```BASH
npm install -g nft-art-generator
```

產生圖片。

```BASH
nft-generate --save-config

? Where are your images located? In the current directory
? Where should the generated images be exported? In the current
 directory
? Should duplicated images be deleted? (Might result in less im
ages then expected) Yes
? Should metadata be generated? Yes
? What should be the name? (Generated format is NAME#ID) 
? What should be the description? 
? What should be the image url? (Generated format is URL/ID) 
? Should JSON metadata be split in multiple files? Yes
✔ Loading traits
? Which trait is the background? BG
? Which trait should be on top of that? SKIN
? Which trait should be on top of that? STREAK
? Which trait should be on top of that? MOUTH
? Which trait should be on top of that? EYES
? Which trait should be on top of that? DECORATE
? How should be constructed the names of the traits? Use filena
mes as traits names
? How many bg-01 bg should there be? 10
? How many bg-02 bg should there be? 10
? How many bg-03 bg should there be? 10
? How many bg-04 bg should there be? 10
? How many bg-05 bg should there be? 10
? How many bg-06 bg should there be? 10
? How many decorate-01 decorate should there be? 10
? How many decorate-02 decorate should there be? 10
? How many decorate-03 decorate should there be? 10
? How many decorate-04 decorate should there be? 10
? How many decorate-05 decorate should there be? 10
? How many eyes-01 eyes should there be? 10
? How many eyes-02 eyes should there be? 10
? How many eyes-03 eyes should there be? 10
? How many eyes-04 eyes should there be? 10
? How many eyes-05 eyes should there be? 10
? How many eyes-06 eyes should there be? 10
? How many mouth-01 mouth should there be? 10
? How many mouth-02 mouth should there be? 10
? How many mouth-03 mouth should there be? 10
? How many mouth-04 mouth should there be? 10
? How many mouth-05 mouth should there be? 10
? How many mouth-06 mouth should there be? 10
? How many skin-01 skin should there be? 10
? How many skin-02 skin should there be? 10
? How many skin-03 skin should there be? 10
? How many skin-04 skin should there be? 10
? How many skin-05 skin should there be? 10
? How many skin-06 skin should there be? 10
? How many streak-01 streak should there be? 10
? How many streak-02 streak should there be? 10
? How many streak-03 streak should there be? 10
? How many streak-04 streak should there be? 10
? How many streak-05 streak should there be? 10
? How many streak-06 streak should there be? 10
⠴ Generating images
✔ All images generated!
✔ Exported metadata successfully
✔ Saved configuration successfully
```

## 程式碼

- [nft-art-generator-example](https://github.com/memochou1993/nft-art-generator-example)

## 參考資料

- [nft-art-generator](https://github.com/NotLuksus/nft-art-generator)
