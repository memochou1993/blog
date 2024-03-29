---
title: 使用 Go 操作 MongoDB 資料庫
date: 2020-01-01 21:55:05
tags: ["Programming", "Go", "MongoDB", "NoSQL", "Database", "ORM"]
categories: ["Programming", "Go", "Others"]
---

## 環境

- macOS
- Go 1.13.4
- MongoDB 4.2.2

## 建立專案

建立專案目錄。

```bash
mkdir -p $GOPATH/src/github.com/memochou1993/mongo-example
```

進到專案目錄。

```bash
cd $GOPATH/src/github.com/memochou1993/mongo-example
```

初始化 Go Modules。

```bash
go mod init github.com/memochou1993/mongo-example
```

## 安裝套件

安裝 `gorilla/mux` 套件。

```bash
go get github.com/gorilla/mux
```

安裝 `globalsign/mgo` 套件。

```bash
go get github.com/globalsign/mgo
```

## 路由

首先新增 `main.go` 檔：

```go
package main

import (
	"github.com/memochou1993/movies-api/routes"
	"net/http"
)

func main() {
	router := routes.NewRouter()
	http.ListenAndServe(":8080", router)
}
```

新增 `routes/api.go` 檔，並定義相關路由：

```go
package routes

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/memochou1993/movies-api/controllers"
)

// Route struct
type Route struct {
	Method     string
	Pattern    string
	Handler    http.HandlerFunc
	Middleware mux.MiddlewareFunc
}

var routes []Route

func init() {
	register("GET", "/movies", controllers.Index, nil)
	register("GET", "/movies/{id}", controllers.Show, nil)
	register("POST", "/movies", controllers.Store, nil)
	register("PUT", "/movies/{id}", controllers.Update, nil)
	register("DELETE", "/movies/{id}", controllers.Destroy, nil)
}

// NewRouter func
func NewRouter() *mux.Router {
	router := mux.NewRouter()

	for _, route := range routes {
		router.Methods(route.Method).Path(route.Pattern).Handler(route.Handler)

		if route.Middleware != nil {
			router.Use(route.Middleware)
		}
	}

	return router
}

// 註冊路由
func register(method string, pattern string, handler http.HandlerFunc, middleware mux.MiddlewareFunc) {
	routes = append(routes, Route{method, pattern, handler, middleware})
}
```

## 定義控制器

新增 `controllers/movie.go` 檔，並定義相關方法，待之後實作：

```go
package controllers

import (
	"fmt"
	"net/http"
)

func Index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Not implemented!")
}

func Show(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Not implemented!")
}

func Store(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Not implemented!")
}

func Update(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Not implemented!")
}

func Destroy(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "Not implemented!")
}
```

## 資料庫

新增 `models/db.go` 檔，封裝對資料庫的操作。

```go
package models

import (
	"log"

	"github.com/globalsign/mgo"
	"github.com/globalsign/mgo/bson"
)

const (
	host     = "localhost:27017"
	source   = ""
	username = ""
	password = ""
)

var session *mgo.Session

func init() {
	dialInfo := &mgo.DialInfo{
		Addrs:    []string{host}, // 資料庫位址
		Source:   source, // 設置權限的資料庫
		Username: username, // 帳號
		Password: password, // 密碼
	}

	s, err := mgo.DialWithInfo(dialInfo)
	if err != nil {
		log.Fatalln("Error: ", err)
	}

	session = s
}

func connect(db string, collection string) (*mgo.Session, *mgo.Collection) {
	// 每一次操作，都複製一份 session，避免每次操作都創建 session，導致連線數超過設置的最大值
	s := session.Copy()
	// 獲取資料表
	c := s.DB(db).C(collection)

	return s, c
}

// FindAll will find all resources.
func FindAll(db string, collection string, query interface{}, selector interface{}, result interface{}) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.Find(query).Select(selector).All(result)
}

// Find will find a resource.
func Find(db string, collection string, query interface{}, selector interface{}, result interface{}) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.Find(query).Select(selector).One(result)
}

// FindByID will find a resource by ID.
func FindByID(db string, collection string, id string, result interface{}) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.FindId(bson.ObjectIdHex(id)).One(result)
}

// Insert will insert a resource.
func Insert(db string, collection string, docs ...interface{}) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.Insert(docs...)
}

// Update will update a resource.
func Update(db string, collection string, selector interface{}, update interface{}) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.Update(selector, update)
}

// UpdateByID will update a resource By ID.
func UpdateByID(db string, collection string, id string, update interface{}) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.UpdateId(bson.ObjectIdHex(id), update)
}

// Remove will remove a resource.
func Remove(db string, collection string, selector interface{}) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.Remove(selector)
}

// RemoveByID will remove a resource by ID.
func RemoveByID(db string, collection string, id string) error {
	s, c := connect(db, collection)
	// 主動關閉 session
	defer s.Close()

	return c.RemoveId(bson.ObjectIdHex(id))
}
```

## 模型

新增 `models/movie.go` 模型，封裝對資源的操作。

```go
package models

import (
	"github.com/globalsign/mgo/bson"
)

// Movie struct
type Movie struct {
	ID          bson.ObjectId `bson:"_id" json:"id"`
	Name        string        `bson:"name" json:"name"`
	Description string        `bson:"description" json:"description"`
}

const (
	db         = "movie"
	collection = "movies"
)

// FindAll will find all movies.
func (m *Movie) FindAll() ([]Movie, error) {
	var movies []Movie
	err := FindAll(db, collection, nil, nil, &movies)

	return movies, err
}

// FindByID will find a movie by ID.
func (m *Movie) FindByID(id string) (Movie, error) {
	var movie Movie
	err := FindByID(db, collection, id, &movie)

	return movie, err
}

// Store will store a movie.
func (m *Movie) Store(movie Movie) error {
	return Insert(db, collection, movie)
}

// Update will update a movie.
func (m *Movie) Update(id string, movie Movie) error {
	return UpdateByID(db, collection, id, movie)
}

// Remove will remove a movie.
func (m *Movie) Remove(id string) error {
	return RemoveByID(db, collection, id)
}
```

## 實作控制器

修改 `controllers/movie.go` 檔，實作相關方法：

```go
package controllers

import (
	"encoding/json"
	"net/http"

	"github.com/globalsign/mgo/bson"
	"github.com/gorilla/mux"
	"github.com/memochou1993/movies-api/models"
)

var (
	model = models.Movie{}
)

func response(w http.ResponseWriter, code int, payload interface{}) {
	response, _ := json.Marshal(payload)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}

// Index display a listing of the resource.
func Index(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var movies []models.Movie

	movies, err := model.FindAll()
	if err != nil {
		response(w, http.StatusInternalServerError, err.Error())
		return
	}

	response(w, http.StatusOK, movies)
}

// Show display the specified resource.
func Show(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	vars := mux.Vars(r)
	id := vars["id"]

	movie, err := model.FindByID(id)

	if err != nil {
		response(w, http.StatusInternalServerError, err.Error())
		return
	}

	response(w, http.StatusOK, movie)
}

// Store store a newly created resource in storage.
func Store(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var movie models.Movie
	movie.ID = bson.NewObjectId()

	if err := json.NewDecoder(r.Body).Decode(&movie); err != nil {
		response(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if err := model.Store(movie); err != nil {
		response(w, http.StatusInternalServerError, err.Error())
		return
	}

	response(w, http.StatusCreated, movie)
}

// Update update the specified resource in storage.
func Update(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	vars := mux.Vars(r)
	id := vars["id"]

	var movie models.Movie
	movie.ID = bson.ObjectIdHex(id)

	if err := json.NewDecoder(r.Body).Decode(&movie); err != nil {
		response(w, http.StatusBadRequest, "Invalid request payload")
		return
	}

	if err := model.Update(id, movie); err != nil {
		response(w, http.StatusInternalServerError, err.Error())
		return
	}

	response(w, http.StatusOK, movie)
}

// Destroy remove the specified resource from storage.
func Destroy(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	vars := mux.Vars(r)
	id := vars["id"]

	if err := model.Remove(id); err != nil {
		response(w, http.StatusInternalServerError, err.Error())
		return
	}

	response(w, http.StatusNoContent, nil)
}
```

## 執行

執行應用。

```bash
go run main.go
```

## 補充

在 Go 語言中的 BSON 物件，常見的有以下 4 種類型：

- `D`：一個有序的 BSON 文件。
- `M`：一個無序的 BSON 文件。
- `A`：一個 BSON 陣列。
- `E`：一個 D 類型中的單獨元素。

## 程式碼

- [go-mongo-example](https://github.com/memochou1993/go-mongo-example)

## 參考資料

- [Build RESTful API with Go and MongoDB](https://github.com/coderminer/restful)
- [Golang 對 MongoDB 的操作簡單封裝](https://juejin.im/post/5b3c46115188251aab711733)
- [The MongoDB driver for Go](https://godoc.org/github.com/globalsign/mgo)
