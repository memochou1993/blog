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
mkdir openai-cli-python-example
cd openai-cli-python-example
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
git remote add origin git@github.com:memochou1993/openai-python-cli-example.git
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

## 實作文字補全

新增 `.env.example` 檔。

```env
OPENAI_API_KEY=
```

新增 `.env` 檔。

```env
OPENAI_API_KEY=your-openai-api-key
```

建立 `main.py` 檔。

```py
import argparse
import os

import requests


def get_completion(prompt: str):
    """Send a request to the OpenAI API and retrieve a response"""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Error: Environment variable OPENAI_API_KEY is not set")
        return

    url = "https://api.openai.com/v1/completions"

    headers = {"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"}

    data = {
        "model": "gpt-3.5-turbo-instruct",
        "prompt": prompt,
        "max_tokens": 100,
        "temperature": 1,
    }

    response = requests.post(url, headers=headers, json=data)

    print(f"API Response:\n{response.text}")


def main():
    parser = argparse.ArgumentParser(description="CLI tool for OpenAI API requests")
    parser.add_argument("prompt", type=str, help="Prompt text to send to OpenAI API")

    args = parser.parse_args()
    get_completion(args.prompt)


if __name__ == "__main__":
    main()
```

執行程式。

```bash
python main.py 你好嗎？
```

響應如下：

```bash
API Response:
{
  "id": "cmpl-BFKZqv3El4WEskkNr1vzDKGHjtk69",
  "object": "text_completion",
  "created": 1742993718,
  "model": "gpt-3.5-turbo-instruct:20230824-v2",
  "choices": [
    {
      "text": "\n\n我是一個人工智能，沒有生理感受，所以並不需要好壞的。謝謝關心。",
      "index": 0,
      "logprobs": null,
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 6,
    "completion_tokens": 42,
    "total_tokens": 48
  }
}
```

## 程式碼

- [openai-cli-python-example](https://github.com/memochou1993/openai-cli-python-example)

## 參考資料

- [OpenAI - Documentation](https://platform.openai.com/docs)
