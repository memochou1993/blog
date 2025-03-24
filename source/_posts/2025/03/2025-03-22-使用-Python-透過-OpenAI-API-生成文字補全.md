---
title: 使用 Python 透過 OpenAI API 生成文字補全
date: 2025-03-22 14:46:48
tags: ["Programming", "Python", "GPT", "AI", "OpenAI"]
categories: ["Programming", "Python", "Others"]
---

## 前置作業

在 [OpenAI](https://openai.com/api/) 註冊一個帳號，並且在 [API keys](https://platform.openai.com/settings/organization/api-keys) 頁面產生一個 API 金鑰。

## 建立專案

建立專案。

```bash
mkdir openai-api-python-example
cd openai-api-python-example
```

## 建立虛擬環境

建立虛擬環境。

```bash
python -m venv .venv
```

啟動虛擬環境。

```bash
source .venv/bin/activate
```

建立 `main.py` 檔。

```py
print('Hello, World!')
```

## 初始化版本控制

建立 `.gitignore` 檔。

```env
.venv/
__pycache__/
.env
```

初始化版本控制。

```bash
git init
```

將所有修改添加到暫存區。

```bash
git add .
```

提交修改。

```bash
git commit -m "Initial commit"
```

指定遠端儲存庫位址。

```bash
git remote add origin git@github.com:memochou1993/openai-python-api-example.git
```

推送程式碼到遠端儲存庫。

```bash
git push -u origin main
```

## 安裝 Ruff 格式化工具

新增 `requirements.txt` 檔。

```bash
touch requirements.txt
```

修改 `requirements.txt` 檔，添加 `ruff` 依賴套件。

```txt
ruff
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

新增 `ruff.toml` 檔。

```toml
line-length = 120
indent-width = 4

[format]
quote-style = "double"
```

新增 `.vscode/settings.json` 檔。

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": "explicit",
    "source.organizeImports": "explicit"
  },
  "editor.defaultFormatter": "charliermarsh.ruff"
}
```

提交修改。

```bash
git add .
git commit -m "Add ruff dependency"
```

## 安裝 FastAPI 框架

修改 `requirements.txt` 檔，添加 `fastapi[standard]` 依賴套件。

```txt
ruff
fastapi[standard]
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

修改 `main.py` 檔。

```py
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}
```

啟動伺服器。

```bash
fastapi dev main.py
```

提交修改。

```bash
git add .
git commit -m "Add fastapi dependency"
```

## 實作文字補全

新增 `.env.example` 檔。

```env
OPENAI_API_KEY=
```

新增 `.env` 檔。

```env
OPENAI_API_KEY=your-openai-api-key
```

修改 `main.py` 檔。

```py
import os

import requests
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.responses import JSONResponse

load_dotenv(override=True)

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.post("/completions")
def create_completions():
    url = "https://api.openai.com/v1/completions"

    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}"}

    data = {"model": "gpt-3.5-turbo-instruct", "prompt": "Say this is a test", "max_tokens": 7, "temperature": 0}

    response = requests.post(url, json=data, headers=headers)

    return JSONResponse(content=response.json(), status_code=response.status_code)
```

啟動伺服器。

```bash
fastapi dev main.py
```

測試。

```bash
curl http://127.0.0.1:8000
```

響應如下：

```json
{
  "id": "cmpl-BDowEBUflcAqD7izQNFiI75UBDxTR",
  "object": "text_completion",
  "created": 1742633770,
  "model": "gpt-3.5-turbo-instruct:20230824-v2",
  "choices": [
    {
      "text": "\n\nThis is a test.",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 5,
    "completion_tokens": 6,
    "total_tokens": 11
  }
}
```

## 程式碼

- [openai-api-python-example](https://github.com/memochou1993/openai-api-python-example)

## 參考資料

- [OpenAI - Documentation](https://platform.openai.com/docs)
