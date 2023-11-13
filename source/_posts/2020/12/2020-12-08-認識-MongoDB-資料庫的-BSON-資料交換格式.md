---
title: 認識 MongoDB 資料庫的 BSON 資料交換格式
date: 2020-12-08 12:06:47
tags: ["BSON", "MongoDB"]
categories: ["Database", "MongoDB"]
---

## 前言

BSON 是一種電腦資料交換格式，主要被用做 MongoDB 資料庫中的資料儲存和網路傳輸格式。它是一種二進位表示形式，能用來表示簡單資料結構、關聯陣列（MongoDB 中稱為「物件」或「文件」），以及 MongoDB 中的各種資料類型。BSON 之名緣於 JSON，含義為 Binary JSON（二進位 JSON）。

## 文件結構

MongoDB 的文件（documents）由鍵值對（field-and-value pairs）組成。

```bash
{
   field1: value1,
   field2: value2,
   field3: value3,
   ...
   fieldN: valueN
}
```

欄位值可以是任何 BSON 資料型別，例如：

```bash
var mydoc = {
    _id: ObjectId("5099803df3f4948bd2f98391"),
    name: { first: "Alan", last: "Turing" },
    birth: new Date('Jun 23, 1912'),
    death: new Date('Jun 07, 1954'),
    contribs: [ "Turing machine", "Turing test", "Turingery" ],
    views : NumberLong(1250000)
}
```

- `_id` 欄位為 `ObjectId` 型別。
- `name` 欄位為包含 first 和 last 欄位的文件型別。
- `birth` 欄位和 `death` 欄位為 `Date` 型別。
- `contrib` 欄位為字串陣列型別。
- `views` 欄位為 `NumberLong` 型別。

## 欄位名

文件的欄位名包含以下限制：

- `_id` 做為保留欄位，當作主鍵，其值必須唯一、不可變，可以是除了陣列之外的任何型別。
- 不可以是 `null` 字串。
- 不可以包含 `$` 或 `.` 字元。

## 文件限制

最大的 BSON 格式文件大小為 16MB。

## 資料型別

| Type | Number | Alias | Notes
| --- | --- | --- | --- |
| Double | 1 | “double” |
| String | 2 | “string” |
| Object | 3 | “object” |
| Array | 4 | “array” |
| Binary data | 5 | “binData” |
| Undefined | 6 | “undefined” | Deprecated.
| ObjectId | 7 | “objectId” |
| Boolean | 8 | “bool” |
| Date | 9 | “date” |
| Null | 10 | “null” |
| Regular Expression | 11 | “regex” |
| DBPointer | 12 | “dbPointer” | Deprecated.
| JavaScript | 13 | “javascript” |
| Symbol | 14 | “symbol” | Deprecated.
| JavaScript code with scope | 15 | “javascriptWithScope” | Deprecated in MongoDB 4.4.
| 32-bit integer | 16 | “int” |
| Timestamp | 17 | “timestamp” |
| 64-bit integer | 18 | “long” |
| Decimal128 | 19 | “decimal” | New in version 3.4.
| Min key | -1 | “minKey” |
| Max key | 127 | “maxKey” |

## 參考資料

- [MongoDB - Documents](https://docs.mongodb.com/manual/core/document/)
