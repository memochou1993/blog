---
title: 使用 Go 操作 MongoDB
permalink: 使用-Go-操作-MongoDB
date: 2019-12-15 23:55:05
tags: ["程式寫作", "Go", "MongoDB", "資料庫"]
categories: ["程式寫作", "Go"]
---

## 環境

- macOS
- Go 1.13.4
- MongoDB

## 建立專案

建立專案目錄。

```BASH
mkdir -p $GOPATH/src/github.com/memochou1993/mongo-example
```

進到專案目錄。

```BASH
cd $GOPATH/src/github.com/memochou1993/mongo-example/
```

在專案目錄底下初始化 Go Modules。

```BASH
go mod init github.com/memochou1993/mongo-example
```

## 安裝套件

安裝 `gorilla/mux` 套件。

```BASH
go get github.com/gorilla/mux
```

安裝 `mongodb/mongo-go-driver` 套件。

```BASH
go get github.com/mongodb/mongo-go-driver/mongo
```

## 做法

新增 `main()` 方法，建立連線，並啟動服務。

```GO
func main() {
	fmt.Println("Starting the application...")

	// 設置請求的超時時間
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	// 超時則釋放資源
	defer cancel()

	// 建立資料庫連線
	clientOptions := options.Client().ApplyURI("mongodb://localhost:27017")
	client, _ = mongo.Connect(ctx, clientOptions)

	// 建立路由
	router := mux.NewRouter()
	router.HandleFunc("/api/books", getBook).Methods("GET")
	router.HandleFunc("/api/books", storeBook).Methods("POST")

	// 啟動服務
	http.ListenAndServe(":8080", router)
}
```

定義資料模型的結構。

```GO
// Book struct
type Book struct {
	ID     primitive.ObjectID `json:"_id,omitempty" bson:"_id,omitempty"`
	Title  string             `json:"title,omitempty" bson:"title,omitempty"`
	Author string             `json:"author,omitempty" bson:"author,omitempty"`
}
```

宣告 `client` 變數為 MongoDB 客戶端。

```GO
var client *mongo.Client
```

建立 `getBooks()` 方法，以取得所有項目。

```GO
func getBooks(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Content-Type", "application/json")

	var books []bson.M

	collection := client.Database("mongo").Collection("books")

	// 設置請求的超時時間
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// 查詢並取得指標物件
	cursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		log.Fatal(err)
	}
	defer cursor.Close(ctx)

	// 分批迭代結果
	for cursor.Next(ctx) {
		var book bson.M
		if err = cursor.Decode(&book); err != nil {
			log.Fatal(err)
		}
		books = append(books, book)
	}

	json.NewEncoder(w).Encode(books)
}
```

建立 `storeBook()` 方法，以儲存項目。

```GO
func storeBook(w http.ResponseWriter, r *http.Request) {
	w.Header().Add("Content-Type", "application/json")

	var book Book
	json.NewDecoder(r.Body).Decode(&book)

	// 建立集合
	collection := client.Database("mongo").Collection("books")

	// 設置請求的超時時間
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// 插入資料並取得結果
	result, err := collection.InsertOne(ctx, book)

	if err != nil {
		log.Fatal(err)
	}

	json.NewEncoder(w).Encode(result)
}
```

## 程式碼

[go-mongo-example](https://github.com/memochou1993/go-mongo-example)

## 參考資料

- [Developing a RESTful API with Golang and a MongoDB NoSQL Database](https://www.youtube.com/watch?v=SonwZ6MF5BE)
- [Quick Start: Golang & MongoDB - How to Read Documents](https://www.mongodb.com/blog/post/quick-start-golang--mongodb--how-to-read-documents)
