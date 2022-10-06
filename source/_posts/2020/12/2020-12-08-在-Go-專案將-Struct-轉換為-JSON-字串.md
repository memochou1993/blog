---
title: 在 Go 專案將 Struct 轉換為 JSON 字串
date: 2020-12-08 14:08:18
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "其他"]
---

## 做法

假設有以下結構體：

```go
type User struct {
	Name string `json:"name,omitempty"`
	Age  int    `json:"age,omitempty"`
}
```

### 方法一

使用 `json.Marshal()` 方法：

```go
func main() {
	v := User{
		Name: "Memo Chou",
		Age:  18,
	}

	b, err := json.Marshal(v)
	if err != nil {
		log.Fatal(err.Error())
	}

	fmt.Println(string(b))
}
```

輸出如下：

```bash
{"name":"Memo Chou","age":18}
```

### 方法二

使用 `json.NewEncoder()` 方法：

```go
func main() {
	v := User{
		Name: "Memo Chou",
		Age:  18,
	}

	b := &bytes.Buffer{}
	if err := json.NewEncoder(b).Encode(v); err != nil {
		log.Fatal(err.Error())
	}

	fmt.Println(b.String())
}
```

輸出如下：

```bash
{"name":"Memo Chou","age":18}
```

- 如果要避免 HTML 跳脫字元被轉譯，可以使用 `SetEscapeHTML()` 方法。
