---
title: 使用 CSS 在 RWD 網頁固定 iframe 的長寬比例
date: 2023-01-02 17:17:10
tags: ["Programming", "CSS", "JavaScript", "React", "styled-components", "RWD"]
categories: ["Programming", "CSS"]
---

## 前言

以下實作一個比例為 16:9 的 CSS 容器，並固定其長寬比例。

## 做法

### 使用 CSS 處理

新增 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
    .video-container {
      position: relative;
      width: 100%;
      padding-bottom: 56.25%;
    }
    .video {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      border: 0;
    }
    </style>
</head>
<body>
    <div class="video-container">
        <iframe class="video" src="https://www.youtube.com/embed/lxchSHUVS5w" allowfullscreen></iframe>
    </div>
</body>
</html>
```

### 使用 styled-components 處理

新增 `index.js` 檔。

```js
const Card = (props) => {
    return (
        <StyledIframeContainer>
            <StyledIframe
                src="https://www.youtube.com/embed/lxchSHUVS5w"
            />
        </StyledIframeContainer>
    );
};

const StyledIframeContainer = styled.div`
  position: relative;
  width: 100%;
  padding-bottom: 56.25%;
`;

const StyledIframe = styled.iframe`
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border: 0;
`;

export default Card;
```

## 參考資料

- [Embed a YouTube video with 16:9 aspect ratio and full-width](https://www.ankursheel.com/blog/full-width-you-tube-video-embed)
