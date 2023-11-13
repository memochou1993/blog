---
title: 使用 Go 生成和解析 JWT Token
date: 2022-12-01 21:53:19
tags: ["Programming", "Go", "JWT"]
categories: ["Programming", "Go", "Others"]
---

## 使用

安裝套件。

```go
go get -u github.com/golang-jwt/jwt/v4
```

新增 `main.go` 檔。

```go
package main

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

type TokenClaims struct {
	jwt.RegisteredClaims
}

func main() {
	key := []byte("256-bit-key")

	// 生成 JWT Token
	token, err := CreateToken(key)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(token)

	// 解析 JWT Token
	parsed, err := ParseToken(token, key)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(parsed)
}

func CreateToken(key []byte) (string, error) {
	duration := 24 * time.Hour
	claims := TokenClaims{
		jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(duration)),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, &claims)
	ss, err := token.SignedString(key)
	if err != nil {
		return "", err
	}
	return ss, nil
}

func ParseToken(tokenString string, key []byte) (*TokenClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &TokenClaims{}, func(token *jwt.Token) (i interface{}, err error) {
		return key, nil
	})
	if err != nil {
		return nil, err
	}
	if claims, ok := token.Claims.(*TokenClaims); ok && token.Valid {
		return claims, nil
	}
	return nil, errors.New("invalid token")
}
```

執行程式。

```bash
go run main.go
```

## 參考資料

- [jwt-go](https://pkg.go.dev/github.com/golang-jwt/jwt/v4)
