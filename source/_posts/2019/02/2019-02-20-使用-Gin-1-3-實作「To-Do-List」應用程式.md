---
title: 使用 Gin 1.3 實作「To-Do List」應用程式
date: 2019-02-20 17:29:41
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "Gin"]
---

## 環境

- macOS

## 做法

安裝 `gin-gonic/gin` 包。

```bash
go get -u github.com/gin-gonic/gin
```

新增 `main.go` 檔。

```go
package main

import (
    "net/http"

    "./helpers"
    "github.com/gin-gonic/gin"
    "github.com/jinzhu/gorm"
    _ "github.com/jinzhu/gorm/dialects/sqlite"
)

var db *gorm.DB
var err error

type (
    Todo struct {
        gorm.Model
        Title     string `json:"title"`
        Completed int    `json:"completed"`
    }
)

func main() {
    // 資料庫連線
    db, err = gorm.Open("sqlite3", "./gorm.db")
    if err != nil {
        panic(err)
    }
    defer db.Close()

    // 自動遷移
    db.AutoMigrate(&Todo{})

    // 創建應用
    app := gin.Default()

    // 定義路由
    app.GET("/", fetchTodos)
    app.POST("/", storeTodo)
    app.GET("/:id", fetchTodo)
    app.PATCH("/:id", updateTodo)
    app.DELETE("/:id", destroyTodo)

    // 啟動服務
    app.Run(":3000")
}

func fetchTodos(c *gin.Context) {
    var todos []Todo

    db.Find(&todos)

    if len(todos) == 0 {
        c.JSON(http.StatusNotFound, gin.H{
            "status":  http.StatusNotFound,
            "message": "No todo found.",
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "status": http.StatusOK,
        "data":   todos,
    })
}

func storeTodo(c *gin.Context) {
    todo := Todo{
        Title:     c.PostForm("title"),
        Completed: helpers.StringToBinary(c.PostForm("completed")),
    }

    db.Save(&todo)

    c.JSON(http.StatusCreated, gin.H{
        "status": http.StatusCreated,
        "data":   todo,
    })
}

func fetchTodo(c *gin.Context) {
    var todo Todo

    db.First(&todo, c.Param("id"))

    if todo.ID == 0 {
        c.JSON(http.StatusNotFound, gin.H{
            "status":  http.StatusNotFound,
            "message": "No todo found.",
        })
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "status": http.StatusOK,
        "data":   todo,
    })
}

func updateTodo(c *gin.Context) {
    var todo Todo

    db.First(&todo, c.Param("id"))

    if todo.ID == 0 {
        c.JSON(http.StatusNotFound, gin.H{
            "status":  http.StatusNotFound,
            "message": "No todo found.",
        })
        return
    }

    db.Model(&todo).Updates(map[string]interface{}{
        "title":     c.PostForm("title"),
        "completed": helpers.StringToBinary(c.PostForm("completed")),
    })

    c.JSON(http.StatusOK, gin.H{
        "status": http.StatusOK,
        "data":   todo,
    })
}

func destroyTodo(c *gin.Context) {
    var todo Todo

    db.First(&todo, c.Param("id"))

    if todo.ID == 0 {
        c.JSON(http.StatusNotFound, gin.H{
            "status":  http.StatusNotFound,
            "message": "No todo found.",
        })
        return
    }

    db.Delete(&todo)

    c.JSON(http.StatusNoContent, gin.H{
        "status": http.StatusOK,
        "data":   todo,
    })
}
```

在 `helpers` 資料夾新增 `cast.go` 檔。

```go
package helpers

import (
    "strconv"
)

// 將字串轉型為 0 或 1 數字
func StringToBinary(str string) int {
    bin, _ := strconv.Atoi(str)
    if bin > 0 {
        bin = 1
    }
    return bin
}
```

執行應用。

```bash
go run main.go
```
