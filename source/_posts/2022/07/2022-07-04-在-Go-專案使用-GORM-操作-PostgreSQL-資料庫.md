---
title: 在 Go 專案使用 GORM 操作 PostgreSQL 資料庫
date: 2022-07-04 00:57:48
tags: ["Programming", "Go", "GORM", "ORM", "PostgreSQL"]
categories: ["Programming", "Go", "GORM"]
---

## 前言

由於 PostgreSQL 的 `numeric` 型別可以處理非常大的數字，因此在處理加密貨幣金額時，可以使用 PostgreSQL 來儲存。

以 Solidity 的 `uint256` 型別為例，可以使用數字型別的 `numeric(78,0)` 來儲存。

常用的數字型別如下：

| Type | Storage Size | Range |
| --- | --- | --- |
| `smallint` | 2 bytes | -32768 到 +32767 |
| `integer` | 4 bytes | -2147483648 到 +2147483647 |
| `bigint` | 8 bytes | -9223372036854775808 到 +9223372036854775807 |
| `numeric` | variable | 小數點前 131,072 位，小數點後 16,383 位 |

## 安裝套件

安裝套件。

```bash
go get github.com/joho/godotenv
go get gorm.io/gorm
go get gorm.io/driver/postgres
go get github.com/jackc/pgtype
```

## 連線

在 `database.go` 檔建立一個 `DB()` 方法，以建立連線並初始化一個 `DB` 實例。

```go
package database

import (
	"fmt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"os"
)

func DB() *gorm.DB {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USERNAME"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_DATABASE"),
	)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}
	return db
}
```

## 定義模型

在 `model/log.go` 檔定義資料模型。

```go
package model

import (
	"github.com/jackc/pgtype"
	"time"
)

type Log struct {
	TransactionHash    string         `gorm:"not null;type:char(66);primaryKey;" json:"transactionHash"`
	BlockNumber        uint64         `gorm:"not null;" json:"blockNumber"`
	EventName          string         `gorm:"not null;type:varchar(255);" json:"eventName"`
	Amount             pgtype.Numeric `gorm:"not null;type:numeric(78,0);" json:"amount"`
	CreatedAt          time.Time      `gorm:"not null;" json:"createdAt"`
	UpdatedAt          time.Time      `gorm:"not null;" json:"updatedAt"`
}
```

- `TransactionHash` 為 64 個固定字元再加上 `0x` 前綴，因此使用 `char(66)` 來儲存。
- `EventName` 為一個簡短的可變字串，因此使用 `varchar(255)` 來儲存。
- `Amount` 為一個龐大數字（`uint256`），因此使用 `numeric(78,0)` 來儲存。

## 數字轉型

轉換 `big.Int` 型別到 `pgtype.Numeric` 型別。

```go
import (
	"github.com/jackc/pgtype"
)

func ToNumeric(v interface{}) *pgtype.Numeric {
	n := pgtype.Numeric{}
	if err := n.Set(v); err != nil {
		log.Fatal(err)
	}
	return &n
}
```

## 新增資料

新增多資料。

```go
database.DB().Create(logs)
```

批次新增資料。

```go
database.DB().CreateInBatches(logs, 100)
```

## 型別擴充

如果需要將 `Numeric` 序列化或反序列化，需要改用 `shopspring-numeric` 包。

```go
package model

import (
	"github.com/jackc/pgtype/ext/shopspring-numeric"
)

type Log struct {
	// ...
	Amount             pgtype.Numeric `gorm:"not null;type:numeric(78,0);" json:"amount"`
	// ...
}
```

## 遷移

在 `database.go` 檔建立一個 `Migrate()` 方法，以新增資料表。

```go
func Migrate() {
	if err := DB().AutoMigrate(
		&model.Log{},
	); err != nil {
		log.Fatal(err)
	}
}
```

## 參考資料

- [GORM Guides](https://gorm.io/docs/)
- [PostgreSQL 正體中文使用手冊](https://docs.postgresql.tw/)
