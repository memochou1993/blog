---
title: 使用 Go 透過 GraphQL API 存取 GitHub 資料
date: 2020-12-03 20:53:42
tags: ["程式設計", "Go", "GitHub", "GraphQL"]
categories: ["程式設計", "Go", "其他"]
---

## 做法

### 申請令牌

先至 GitHub 的 [Personal access tokens](https://github.com/settings/tokens) 頁面申請一個存取令牌。根據需求選擇令牌的作用域，例如要存取公開的儲存庫，就將 `public_repo` 打勾。

### 探索

使用 [GitHub GraphQL API Explorer](https://developer.github.com/v4/explorer/) 進行探索。

### 實作

新增 `main.go` 檔：

```GO
package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// 根據查詢條件的回應結果定義一個回應結構體
type Response struct {
	Data struct {
		User struct {
			Repositories struct {
				Nodes []struct {
					Name       string `json:"name"`
				} `json:"nodes"`
			} `json:"repositories"`
		} `json:"user"`
	} `json:"data"`
}

func main() {
	// 獲取資源
	response, err := Fetch(context.Background())

	if err != nil {
		log.Println(err.Error())
	}

	fmt.Println(response)
}

// 獲取資源
func Fetch(ctx context.Context) (Response, error) {
	response := Response{}

	// 制定查詢條件
	q := struct {
		Query string `json:"query"`
	}{
		Query: `
			query {
			  user(login: "memochou1993") {
				repositories(first: 10) {
				  nodes {
					name
				  }
				}
			  }
			}
		`,
	}

	body := &bytes.Buffer{}

	// 序列化到 body 變數
	if err := json.NewEncoder(body).Encode(q); err != nil {
		return response, err
	}

	// 建立請求
	req, err := http.NewRequest(http.MethodPost, "https://api.github.com/graphql", body)

	if err != nil {
		return response, err
	}

	req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", "<TOKEN>"))

	// 發送請求
	resp, err := http.DefaultClient.Do(req.WithContext(ctx))

	if err != nil {
		return response, err
	}

	defer func() {
		if err := resp.Body.Close(); err != nil {
			log.Println(err.Error())
		}
	}()

	// 反序列化到 response 變數
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		return response, err
	}

	return response, nil
}
```

輸出結果：

```GO
{{{{[{kuntai} {portfolio} {surl} {memochou1993.github.io} {blog} {jwt-lumen} {doaj} {laravel-foundation-preset} {journal} {post}]}}}}
```

## 補充

回應的結構體可以使用 [JSON-to-Go](https://mholt.github.io/json-to-go/) 這個線上工具將 JSON 轉換成 Go 的結構體。

## 程式碼

- [github-graphql-api-example](https://github.com/memochou1993/github-graphql-api-example)

## 參考資料

- [GitHub Docs - Scopes for OAuth Apps](https://docs.github.com/en/free-pro-team@latest/developers/apps/scopes-for-oauth-apps)
- [Getting GitHub Stars with Go and GraphQL](https://www.youtube.com/watch?v=rxjJubDU80U)
