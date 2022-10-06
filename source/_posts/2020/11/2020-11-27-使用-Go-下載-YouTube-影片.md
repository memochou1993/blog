---
title: 使用 Go 下載 YouTube 影片
date: 2020-11-27 20:48:13
tags: ["程式設計", "Go", "YouTube"]
categories: ["程式設計", "Go", "其他"]
---

## 前言

本文透過取得 YouTube 的影片資訊檔，解析出真實路徑，並進行下載。

## 流程

### 影片資訊檔

透過以下網址，取得指定 ID 的影片資訊檔。

```env
https://youtube.com/get_video_info?video_id=<ID>
```

### 解析影片資訊檔

得到的 `get_video_info` 檔是一個用「`&`」連接的 `key=value` 鍵值對，可以透過 URL Query Parser 來進行解碼。

### 影片資訊

其中 `player_response` 所對應的值，是一個 JSON 格式的資料，儲存該影片的詳細資訊、媒體形式，還有影片的真實路徑。

### 真實路徑

YouTube 的影片分為不需解密與需要解密兩種，前者會直接提供 `url`，這就是該影片的真實路徑；而後者會提供 `cipher`，需要透過一套流程進行解密。

## 實作

在 `app` 資料夾建立一個 `client.go` 檔，用來取得影片資訊檔：

```go
package app

import (
	"context"
	"github.com/memochou1993/youtube-downloader/app/model"
	"io/ioutil"
	"log"
	"net/http"
)

const (
	host = "https://youtube.com"
)

type Client struct {
	HTTPClient *http.Client
}

// 建立一個 HTTP 客戶端
func (c *Client) New() *http.Client {
	if c.HTTPClient == nil {
		c.HTTPClient = http.DefaultClient
	}

	return c.HTTPClient
}

// 發送 GET 請求
func (c *Client) Get(ctx context.Context, url string) (*http.Response, error) {
	client := c.New()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)

	if err != nil {
		return nil, err
	}

	return client.Do(req)
}

// 發送 GET 請求，並取得內容
func (c *Client) GetBody(ctx context.Context, url string) []byte {
	resp, err := c.Get(ctx, url)

	if err != nil {
		log.Println(err.Error())
		return nil
	}

	defer func() {
		if err := resp.Body.Close(); err != nil {
			log.Println(err.Error())
		}
	}()

	body, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		log.Println(err.Error())
		return nil
	}

	return body
}

// 發送 GET 請求，並解析影片資訊檔
func (c *Client) GetVideo(ctx context.Context, id string) *model.Video {
	body := c.GetBody(ctx, host+"/get_video_info?video_id="+id)

	video := &model.Video{}
	video.ParseVideoInfo(string(body))

	return video
}
```

在 `app/model` 資料夾建立一個 `video.go` 檔，用來定義一個影片的結構體並解析影片資訊檔：

```go
package model

import (
	"encoding/json"
	"log"
	"net/url"
)

type Video struct {
	VideoDetails struct {
		VideoID          string `json:"videoId"`
		Title            string `json:"title"`
		ShortDescription string `json:"shortDescription"`
		Author           string `json:"author"`
	} `json:"videoDetails"`
	StreamingData struct {
		Formats []Format `json:"formats"`
	} `json:"streamingData"`
}

type Format struct {
	URL              string `json:"url"`
	MimeType         string `json:"mimeType"`
	Bitrate          int    `json:"bitrate"`
	Width            int    `json:"width"`
	Height           int    `json:"height"`
	LastModified     string `json:"lastModified"`
	ContentLength    string `json:"contentLength"`
	Quality          string `json:"quality"`
	Fps              int    `json:"fps"`
	QualityLabel     string `json:"qualityLabel"`
	ProjectionType   string `json:"projectionType"`
	AverageBitrate   int    `json:"averageBitrate"`
	AudioQuality     string `json:"audioQuality"`
	ApproxDurationMs string `json:"approxDurationMs"`
	AudioSampleRate  string `json:"audioSampleRate"`
	AudioChannels    int    `json:"audioChannels"`
}

// 取得 player_response 資料，並反序列化到 Video 結構體
func (v *Video) ParseVideoInfo(info string) {
	data, err := url.ParseQuery(info)

	if err != nil {
		log.Println(err.Error())
		return
	}

	playerResponse := data.Get("player_response")

	if err := json.Unmarshal([]byte(playerResponse), v); err != nil {
		log.Println(err.Error())
	}
}
```

在 `app/controller` 資料夾建立一個 `main.go` 檔，做為控制器：

```go
package controller

import (
	"context"
	"fmt"
	"github.com/memochou1993/youtube-downloader/app"
	"github.com/memochou1993/youtube-downloader/app/model"
	"log"
	"net/http"
)

// 下載影片
func Download(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()
	client := &app.Client{}
	id := r.URL.Query().Get("id")

	if id == "" {
		return
	}

	// 發送 GET 請求，並解析影片資訊檔
	video := client.GetVideo(ctx, id)

	defer func() {
		if err := r.Body.Close(); err != nil {
			log.Println(err.Error())
		}
	}()

	formats := video.StreamingData.Formats

	if len(formats) == 0 {
		return
	}

	// 找出最高畫質的影片
	url := findBestFormat(video.StreamingData.Formats).URL

	if url == "" {
		return
	}

	// 向影片的真實路徑發起 GET 請求，取得影片檔案
	content := client.GetBody(ctx, url)

	// 下載
	download(w, video.VideoDetails.Title, content)
}

// 找出最高畫質的影片
func findBestFormat(formats []model.Format) model.Format {
	index := 0
	size := 0

	for i, format := range formats {
		s := format.Height * format.Width

		if s > size {
			index = i
			size = s
		}
	}

	return formats[index]
}

// 下載
func download(w http.ResponseWriter, filename string, data []byte) {
	w.Header().Set("Content-Type", "video/mp4")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s.mp4\"", filename))

	if _, err := w.Write(data); err != nil {
		log.Println(err.Error())
	}
}
```

在根目錄建立 `main.go` 檔，以提供服務：

```go
package main

import (
	"github.com/memochou1993/youtube-downloader/app/controller"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", controller.Download)

	log.Fatal(http.ListenAndServe(":8083", nil))
}
```

## 程式碼

- [youtube-downloader](https://github.com/memochou1993/youtube-downloader)

## 參考資料

- [如何抓取 Youtube 影片的相關資訊](https://www.evanlin.com/til-golang-youtube/)
