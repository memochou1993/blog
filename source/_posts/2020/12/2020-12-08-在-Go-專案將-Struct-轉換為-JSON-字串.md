---
title: 在 Go 專案將 Struct 轉換為 JSON 字串
permalink: 在-Go-專案將-Struct-轉換為-JSON-字串
date: 2020-12-08 14:08:18
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "其他"]
---

## 做法

假設有以下結構體：

```GO
type SearchArguments struct {
	After  string `json:"after,omitempty"`
	Before string `json:"before,omitempty"`
	First  int    `json:"first,omitempty"`
	Last   int    `json:"last,omitempty"`
	Query  string `json:"query,omitempty"`
	Type   string `json:"type,omitempty"`
}
```

### 方法一

使用 `json.Marshal()` 方法：

```GO
v := query.SearchArguments{
	First: 1,
	Query: "\"repos:>=5 followers:>=10\"",
	Type:  "USER",
}

b, err := json.Marshal(v)
if err != nil {
	log.Fatal(err.Error())
}

fmt.Println(string(b))
```

輸出如下：

```BASH
{"first":1,"query":"\"repos:\u003e=5 followers:\u003e=10\"","type":"USER"}
```

### 方法二

使用 `json.NewEncoder()` 方法：

```GO
v := query.SearchArguments{
	First: 1,
	Query: "\"repos:>=5 followers:>=10\"",
	Type:  "USER",
}

b := &bytes.Buffer{}
if err := json.NewEncoder(b).Encode(v); err != nil {
	log.Fatal(err.Error())
}

fmt.Println(b.String())
```

輸出如下：

```BASH
{"first":1,"query":"\"repos:\u003e=5 followers:\u003e=10\"","type":"USER"}
```

如果要避免 HTML 跳脫字元被轉譯，可以使用 `encoder.SetEscapeHTML()` 方法：

```GO
b := &bytes.Buffer{}
encoder := json.NewEncoder(b)
encoder.SetEscapeHTML(false)
if err := encoder.Encode(v); err != nil {
	log.Fatal(err.Error())
}

fmt.Println(b.String())
```

輸出如下：

```BASH
{"first":1,"query":"\"repos:>=5 followers:>=10\"","type":"USER"}
```
