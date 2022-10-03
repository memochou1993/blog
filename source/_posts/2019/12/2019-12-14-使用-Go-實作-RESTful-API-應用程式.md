---
title: 使用 Go 實作 RESTful API 應用程式
date: 2019-12-14 15:31:39
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "其他"]
---

## 環境

- macOS
- Go 1.13.1

## 建立專案

建立專案目錄。

```BASH
mkdir -p $GOPATH/src/github.com/memochou1993/api-example
```

目錄結構如下：

```BASH
|- bin/
|- pkg/
|- src/
  |- github.com/
    |- memochou1993/
      |- api-example/
```

進到專案目錄。

```BASH
cd $GOPATH/src/github.com/memochou1993/api-example/
```

## 安裝套件

安裝 `gorilla/mux` 套件。

```BASH
go get -u github.com/gorilla/mux
```

## 路由

定義路由並監聽在 `8000` 埠。

```GO
func main() {
	r := mux.NewRouter()

	r.HandleFunc("/api/books", getBooks).Methods("GET")
	r.HandleFunc("/api/books/{id}", getBook).Methods("GET")
	r.HandleFunc("/api/books", storeBook).Methods("POST")
	r.HandleFunc("/api/books/{id}", IndexHandler).Methods("PUT")
	r.HandleFunc("/api/books/{id}", IndexHandler).Methods("DELETE")

	log.Fatal(http.listenAndServe(":8000", r))
}
```

## 資料模型

定義資料模型的結構。

```GO
// Book struct
type Book struct {
	ID     string  `json:"id"`
	Isbn   string  `json:"isbn"`
	Titile string  `json:"titile"`
	Author *Author `json:"author"`
}

// Author struct
type Author struct {
	Firstname string `json:"firstname"`
	Lastname  string `json:"lastname"`
}
```

宣告一個元素型別為 `Book` 的陣列。

```GO
var books []Book
```

## 控制器

建立 `getBooks()` 方法，以取得所有項目。

```GO
func getBooks(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(books)
}
```

建立 `getBook()` 方法，以取得項目。

```GO
func getBook(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)

	// Find a Book
	for _, item := range books {
		if item.ID == params["id"] {
			json.NewEncoder(w).Encode(item)

			return
		}
	}

	// Return an Empty Book
	json.NewEncoder(w).Encode(&Book{})
}
```

建立 `storeBook()` 方法，以儲存項目。

```GO
func storeBook(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var book Book

	_ = json.NewDecoder(r.Body).Decode(&book)

	book.ID = strconv.Itoa(rand.Intn(1000000)) // Mock ID
	books = append(books, book)

	json.NewEncoder(w).Encode(book)
}
```

建立 `updateBook()` 方法，以更新項目。

```GO
func updateBook(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)

	for index, item := range books {
		if item.ID == params["id"] {
			var book Book

			_ = json.NewDecoder(r.Body).Decode(&book)

			book.ID = item.ID

			// Replace a Book
			books[index] = book

			json.NewEncoder(w).Encode(book)

			return
		}
	}

	json.NewEncoder(w).Encode(books)
}
```

建立 `destroyBook()` 方法，以刪除項目。

```GO
func destroyBook(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	params := mux.Vars(r)

	for index, item := range books {
		if item.ID == params["id"] {
			books = append(books[:index], books[index+1:]...)

			break
		}
	}

	json.NewEncoder(w).Encode(books)
}
```

## 啟動服務

執行應用。

```BASH
go run main.go
```

## 補充

使用 `append()` 方法可以將包含第二個參數以後的任意個參數添加到第一個參數的陣列裡，例如：

```GO
slice = append(slice, ele1, ele2)
```

或者可以使用 `...` 符號，將第一個參數的陣列與第二個參數的陣列拼接在一起，但這種方法只接收 2 個參數，例如：

```GO
slice = append(slice1, slice2...)
```

## 程式碼

- [go-api-example](https://github.com/memochou1993/go-api-example)

## 參考資料

- [Golang REST API With Mux](https://www.youtube.com/watch?v=SonwZ6MF5BE)
