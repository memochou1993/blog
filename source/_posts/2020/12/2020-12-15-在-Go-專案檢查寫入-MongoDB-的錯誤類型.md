---
title: 在 Go 專案檢查寫入 MongoDB 的錯誤類型
date: 2020-12-15 00:21:39
tags: ["Programming", "Go", "MongoDB", "NoSQL", "Database", "ORM"]
categories: ["Programming", "Go", "Others"]
---

## 做法

使用以下方式檢查寫入資料庫的錯誤類型，並且使用錯誤代碼 `11000` 來檢查是否儲存重複資料。

```go
const ErrorDuplicateKey = 11000

opts := options.InsertMany().SetOrdered(false)
_, err := u.GetCollection().InsertMany(ctx, users, opts)

if err, ok := err.(mongo.BulkWriteException); ok {
	for _, err := range err.WriteErrors {
		if err.Code != ErrorDuplicateKey {
			log.Fatalln(err.Error())
		}
		logger.Warning(err.WriteError.Error())
	}
}
```

- `SetOrdered` 表示即使儲存重複鍵名的資料，也不會中斷後續其他資料的儲存。
