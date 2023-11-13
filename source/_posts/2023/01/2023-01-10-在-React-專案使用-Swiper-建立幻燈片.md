---
title: 在 React 專案使用 Swiper 建立幻燈片
date: 2023-01-10 02:35:00
tags: ["Programming", "JavaScript", "React"]
categories: ["Programming", "JavaScript", "React"]
---

## 前言

以下使用 Swiper 套件實作一個幻燈片，可以使用按鈕或是滑動的方式切換圖片。

## 建立專案

建立專案。

```bash
npx create-react-app swiper-react-example
```

安裝套件。

```bash
npm i swiper
```

## 實作

修改 `App.js` 檔。

```js
import { useRef } from 'react';
import { Swiper, SwiperSlide } from 'swiper/react';
import 'swiper/css';

const IMAGE_BASE_URL = 'https://raw.githubusercontent.com/memochou1993/nft-leopard-cat-images/main/output';

function App() {
  const swiperRef = useRef();
  return (
    <>
      <button onClick={() => swiperRef.current?.slidePrev()}>Prev</button>
      <button onClick={() => swiperRef.current?.slideNext()}>Next</button>
      <Swiper
        onBeforeInit={(swiper) => {
          swiperRef.current = swiper;
        }}
        onSwiper={(swiper) => console.log(swiper)}
      >
        {
          [...Array(10).keys()].map((n) => (
            <SwiperSlide key={n}>
              <img src={`${IMAGE_BASE_URL}/${n}.png`} alt={n} />
            </SwiperSlide>
          ))
        }
      </Swiper>
    </>
  );
}

export default App;
```

## 程式碼

- [swiper-react-example](https://github.com/memochou1993/swiper-react-example)

## 參考資料

- [Swiper React Components](https://swiperjs.com/react)
