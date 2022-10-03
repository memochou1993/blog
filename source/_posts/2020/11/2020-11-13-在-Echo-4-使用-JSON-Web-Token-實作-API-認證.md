---
title: 在 Echo 4 使用 JSON Web Token 實作 API 認證
date: 2020-11-13 20:14:24
tags: ["程式設計", "Go", "Echo", "JWT"]
categories: ["程式設計", "Go", "Echo"]
---

## 做法

```GO
package token

import (
	"errors"
	"github.com/dgrijalva/jwt-go"
	"github.com/labstack/echo/v4"
	"github.com/memochou1993/prophecy/app/model"
	"github.com/memochou1993/prophecy/app/request"
	"github.com/memochou1993/prophecy/database"
	"gorm.io/gorm"
	"net/http"
	"os"
	"time"
)

// 聲明
type Claims struct {
	UserID uint
	jwt.StandardClaims
}

// 認證資訊
type Credentials struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

func Login(c echo.Context) error {
	// 實例化一個認證資訊
	credentials := new(Credentials)

	// 將請求綁定到認證資訊上
	if err := c.Bind(credentials); err != nil {
		return echo.ErrInternalServerError
	}

	// 驗證認證資訊
	if err := c.Validate(credentials); err != nil {
		return c.JSON(http.StatusUnprocessableEntity, err.Error())
	}

	// 實例化一個使用者結構體
	user := model.User{}

	// 使用 Email 查找使用者
	result := database.DB().Where(&model.User{Email: credentials.Email}).First(&user)

	// 判斷使用者是否存在
	if errors.Is(result.Error, gorm.ErrRecordNotFound) {
		return echo.ErrUnauthorized
	}

	// 判斷密碼是否正確
	if user.Password != credentials.Password {
		return echo.ErrUnauthorized
	}

	// 實例化一個聲明
	claims := &Claims{
		user.ID,
		jwt.StandardClaims{
			ExpiresAt: time.Now().Add(time.Hour * 72).Unix(),
		},
	}

	// 產生令牌
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(os.Getenv("APP_KEY")))

	if err != nil {
		return echo.ErrInternalServerError
	}

	return c.JSON(http.StatusOK, map[string]string{
		"token": token,
	})
}
```

## 補充

1. JWT 是無狀態的，如果要登出，直接刪除客戶端的令牌。
2. 藉由縮短令牌的存活時間並頻繁刷新，來提升安全性。

## 參考資料

- [Echo - JWT](https://echo.labstack.com/cookbook/jwt)
