---
title: 在 Go 專案使用 MongoDB 批量操作
date: 2020-01-08 22:33:24
tags: ["Programming", "Go", "MongoDB", "NoSQL", "Database", "ORM"]
categories: ["Programming", "Go", "Others"]
---

## 環境

- macOS
- Go 1.13.4
- MongoDB 4.2.2

## 前言

對 MongoDB 有多個操作時，可以使用 `bulkWrite()` 方法提高效能。此方法將每 100,000 個請求做為一個批次發送至服務器，而不是每一次發送一個請求。

## 建立專案

建立專案目錄。

```bash
mkdir -p $GOPATH/src/github.com/memochou1993/mongo-bulk-example
```

進到專案目錄。

```bash
cd $GOPATH/src/github.com/memochou1993/mongo-bulk-example
```

初始化 Go Modules。

```bash
go mod init github.com/memochou1993/mongo-bulk-example
```

## 安裝套件

安裝 `go.mongodb.org/mongo-driver` 套件。

```bash
go get go.mongodb.org/mongo-driver
```

## 做法

新增 `main.go` 檔：

```go
package main

import (
	"context"
	"fmt"
	"log"
	"strconv"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

const (
	uri        = "mongodb://localhost:27017"
	database   = "mongo"
	collection = "items"
)

var (
	err      error
	client   *mongo.Client
	item     Item
	duration time.Duration // 經過時間
	times    int64 = 10 // 測試次數
	amount   int   = 100 // 資料筆數
	method   int // 使用方法
)

// Item struct
type Item struct {
	Value string
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
	defer cancel()

	opts := options.Client().ApplyURI(uri)
	if client, err = mongo.Connect(ctx, opts); err != nil {
		log.Fatalln(err.Error())
	}

	// TODO

	// 印出平均執行時間
	fmt.Println(duration / (time.Duration(times) * time.Millisecond) * time.Millisecond)
}
```

新增一個 `upsert()` 方法，用來更新或新增記錄。

```go
func upsert(ctx context.Context, c *mongo.Collection, amount int) {
	defer measure(time.Now())

	for i := 0; i <= amount; i++ {
		query := bson.M{"id": i}
		update := bson.M{"$set": Item{Value: "New Item " + strconv.Itoa(i)}}

		opts := options.Update().SetUpsert(true)
		_, err := c.UpdateOne(ctx, query, update, opts)

		if err != nil {
			log.Fatalln(err.Error())
		}
	}

	// 刪除資料庫
	if err := c.Drop(ctx); err != nil {
		log.Fatalln(err.Error())
	}
}
```

新增一個 `bulkUpsert()` 方法，用來批量更新或新增記錄。

```go
func bulkUpsert(ctx context.Context, c *mongo.Collection, amount int) {
	defer measure(time.Now())

	models := []mongo.WriteModel{}

	for i := 0; i <= amount; i++ {
		query := bson.M{"id": i}
		update := bson.M{"$set": Item{Value: "New Item " + strconv.Itoa(i)}}
		model := mongo.NewUpdateOneModel()
		models = append(models, model.SetFilter(query).SetUpdate(update).SetUpsert(true))
	}

	// 批量寫入
	opts := options.BulkWrite().SetOrdered(false)
	_, err := c.BulkWrite(ctx, models, opts)

	if err != nil {
		log.Fatalln(err.Error())
	}

	// 刪除資料庫
	if err = c.Drop(ctx); err != nil {
		log.Fatalln(err.Error())
	}
}
```

新增一個 `measure` 方法，用來計算經過時間：

```go
func measure(start time.Time) {
	duration += time.Since(start)
	// 印出執行時間
	log.Printf("Execution time: %s", time.Since(start))
	// 印出經過時間
	log.Printf("Elapsed time: %s ", duration)
}
```

## 測試

將 `main()` 方法修改如下：

```go
func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
	defer cancel()

	opts := options.Client().ApplyURI(uri)
	if client, err = mongo.Connect(ctx, opts); err != nil {
		log.Fatalln(err.Error())
	}

	c := client.Database(database).Collection(collection)

	// 取得方法
	fmt.Scan(&method)

	var i int64
	for i = 0; i < times; i++ {
		if method == 1 {
			upsert(ctx, c, amount)
			continue
		}
		if method == 2 {
			bulkUpsert(ctx, c, amount)
			continue
		}
		break
	}

	log.Printf("Average time: %s", duration/(time.Duration(times)*time.Millisecond)*time.Millisecond)
}
```

測試 `upsert()` 方法：

```go
go run main.go
1
```

測試 `bulkUpsert()` 方法：

```go
go run main.go
2
```

## 結果

執行時間比較如下：

| 測試次數 | 資料筆數 | 非批量寫入（秒） | 批量寫入（秒） |
| --- | --- | --- | --- |
| 10 | 10 | 0.024 | 0.016 |
| 10 | 100 | 0.088 | 0.029 |
| 10 | 1,000 | 1.1 | 0.424 |
| 5 | 10,000 | 42.3 | 34.8 |
| 3 | 5,0000 | 478.3 | 415.6 |

寫入速度比較如下：

| 測試次數 | 資料筆數 | 非批量寫入（筆/秒） | 批量寫入（筆/秒） |
| --- | --- | --- | --- |
| 10 | 10 | 416.7 | 625.0 |
| 10 | 100 | 1136.4 | 3448.3 |
| 10 | 1,000 | 909.0 | 2358.5 |
| 5 | 10,000 | 236.4 | 287.4 |
| 3 | 5,0000 | 104.529 | 120.3 |

## 程式碼

- [mongo-bulk-write](https://github.com/memochou1993/mongo-bulk-write)

## 參考資料

- [MongoDB Documentation](https://docs.mongodb.com/manual/reference/method/db.collection.bulkWrite/index.html)
- [GoDoc: mongo-driver/mongo](https://godoc.org/go.mongodb.org/mongo-driver/mongo)
