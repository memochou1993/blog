---
title: 在 Go 專案使用 Session 認證
permalink: 在-Go-專案使用-Session-認證
date: 2021-05-29 16:13:38
tags: ["程式設計", "Go"]
categories: ["程式設計", "Go", "其他"]
---

## 做法

建立專案。

```BASH
mkdir go-session-example
cd go-session-example
```

初始化 Go Modules。

```BASH
go mod init github.com/memochou1993/go-session-example
```

下載 `gorilla/sessions` 套件。

```BASH
go get github.com/gorilla/sessions
```

下載 `joho/godotenv` 套件。

```BASH
go get github.com/joho/godotenv
```

新增一個 `main.go` 檔：

```GO
var (
	key        = []byte(os.Getenv("SESSION_KEY"))
	store      = sessions.NewCookieStore(key)
	cookieName = "auth"
)

func main() {
	http.HandleFunc("/secret", secret)
	http.HandleFunc("/login", login)
	http.HandleFunc("/logout", logout)

	http.ListenAndServe(":8080", nil)
}

func secret(w http.ResponseWriter, r *http.Request) {
	session, _ := store.Get(r, cookieName)

	if auth, ok := session.Values["authenticated"].(bool); !ok || !auth {
		http.Error(w, "Forbidden", http.StatusForbidden)
		return
	}

	fmt.Fprintln(w, "Secret")
}

func login(w http.ResponseWriter, r *http.Request) {
	session, _ := store.Get(r, cookieName)

	session.Values["authenticated"] = true
	session.Save(r, w)
}

func logout(w http.ResponseWriter, r *http.Request) {
	session, _ := store.Get(r, cookieName)

	session.Values["authenticated"] = false
	session.Save(r, w)
}
```

新增 `.env` 檔：

```ENV
SESSION_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

執行。

```BASH
go run main.go
```

## 瀏覽網頁

登入：<http://127.0.0.1:8080/login>

進到需要認證的頁面：<http://127.0.0.1:8080/secret>

登出：<http://127.0.0.1:8080/logout>

## 程式碼

- [go-session-example](https://github.com/memochou1993/go-session-example)

## 參考資料

- [Go Web Examples - Sessions](https://gowebexamples.com/sessions/)
