---
title: 將 Flask 專案部署至 Vercel 平台
date: 2023-07-11 23:45:08
tags: ["Programming", "Python", "Flask", "Vercel"]
categories: ["Programming", "Python", "Flask"]
---

## 建立專案

建立專案。

```bash
mkdir flask-example
cd flask-example
```

建立環境。

```bash
pyenv virtualenv 3.11.4 flask-example
pyenv local flask-example
```

## 實作

新增 `.gitignore` 檔。

```env
__pycache__
.vscode
.vercel
.env
```

新增 `requirements.txt` 檔

```txt
Flask==2.2.2
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

新增 `api/index.py` 檔。

```py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return 'Hello, World!'

@app.route('/about')
def about():
    return 'About'
```

啟動服務。

```bash
flask --app api/index run
```

## 部署

新增 `vercel.json` 檔。

```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/api/index"
    }
  ]
}
```

將程式碼推送到 GitHub 儲存庫。

在 [Vercel](https://vercel.com/) 平台註冊帳號，並且連結儲存庫。

## 參考資料

- [Flask + Vercel](https://github.com/vercel/examples/tree/main/python/flask)
