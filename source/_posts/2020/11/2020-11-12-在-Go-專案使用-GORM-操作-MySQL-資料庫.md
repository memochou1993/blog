---
title: 在 Go 專案使用 GORM 操作 MySQL 資料庫
date: 2020-11-12 22:56:28
tags: ["Programming", "Go", "GORM", "ORM", "MySQL"]
categories: ["Programming", "Go", "GORM"]
---

## 連線

建立連線：

```go
dsn := "root:root@tcp(127.0.0.1:3306)/table?charset=utf8mb4&parseTime=true"
db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})

if err != nil {
    log.Fatal(err.Error())
}
```

- 為了正確處理 `time.Time`，需要帶上 `parseTime=true` 參數。
- 為了支援完整的 UTF-8 編碼，需要帶上 `charset=utf8mb4` 參數。

## 模型

### 範例

以下是一個模型的範例：

```go
type User struct {
	ID           uint
	Name         string
	Email        *string
	Age          uint8
	Birthday     *time.Time
	MemberNumber sql.NullString
	ActivedAt    sql.NullTime
	CreatedAt    time.Time
	UpdatedAt    time.Time
}
```

- 使用指標做為型別，預設值會是 `null`，適合用在結構體屬性。

### 巢狀結構體

使用巢狀結構體定義模型：

```go
type User struct {
	gorm.Model
	Name string
}
```

使用 `gorm.Model` 會帶入以下屬性：

```go
type Model struct {
	ID        uint           `gorm:"primaryKey"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
}
```

### JSON

定義 JSON 標籤：

- 使用 `json:"-"` 隱藏屬性。
- 使用 `json:"column"` 重新定義屬性名稱。
- 使用 `json:",omitempty"` 隱藏空值屬性。

```go
type User struct {
	gorm.Model
	Name         string        `gorm:"size:255;not null;"`
	Email        string        `gorm:"size:255;not null;uniqueIndex;"`
	Password     string        `gorm:"size:255;not null;" json:"-"`
	Property     *Property     `gorm:"polymorphic:Owner;polymorphicValue:user;" json:",omitempty"`
	Entries      []Entry       `gorm:"polymorphic:Owner;polymorphicValue:user;" json:",omitempty"`
}
```

## 遷移

使用 `AutoMigrate()` 方法遷移資料表。

```go
err := db.AutoMigrate(
	&model.User{},
)
```

使用 `Migrator` 的 `DropTable()` 方法丟棄資料表。

```go
err := db.Migrator().DropTable(
	&model.User{},
)
```

## 參考資料

- [GORM Guides](https://gorm.io/docs/)
- [GORM 使用筆記](https://pjchender.github.io/2020/07/22/note-gorm-%E4%BD%BF%E7%94%A8%E7%AD%86%E8%A8%98/)
- [GORM 使用範例](https://pjchender.github.io/2020/09/20/note-gorm-%E4%BD%BF%E7%94%A8%E7%AF%84%E4%BE%8B/)
