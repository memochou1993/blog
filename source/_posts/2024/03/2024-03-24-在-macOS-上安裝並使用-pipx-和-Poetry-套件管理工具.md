---
title: 在 macOS 上安裝並使用 pipx 和 Poetry 套件管理工具
date: 2024-03-24 16:04:00
tags: ["Programming", "Python", "pipx", "Poetry", "Package Manager"]
categories: ["Programming", "Python", "Others"]
---

## 前言

pipx 是用來安裝 CLI 和確保依賴隔離的工具；而 Poetry 則是用來管理專案的依賴套件，就像 npm 一樣。

## 做法

安裝 `pipx` 指令。

```bash
brew install pipx
pipx ensurepath
```

安裝 `poetry` 指令。

```bash
pipx install poetry
```

## 建立專案

建立專案。

```bash
mkdir my-project
cd my-project
```

初始化專案。

```bash
poetry init
```

安裝依賴套件。

```bash
poetry add fastapi uvicorn
```

啟動虛擬環境。

```bash
poetry shell
```

新增 `main.go` 檔。

```py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def root():
  return {
    "message": "Hello World!",
  }
```

啟動網頁伺服器。

```bash
uvicorn main:app --reload --port 8001
```

## 清理

查看虛擬環境資訊。

```bash
poetry env info
```

刪除虛擬環境。

```bash
poetry env remove my-project-Y_ms9Yr_-py3.12
```

## 參考資料

- [Poetry](https://python-poetry.org/)
- [pipx](https://pipx.pypa.io/)
