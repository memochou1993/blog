---
title: 使用 XMLHttpRequest 追蹤檔案上傳進度
date: 2025-03-04 18:22:42
tags: ["Programming", "JavaScript", "Python", "FastAPI"]
categories: ["Programming", "JavaScript", "Others"]
---

## 實作後端

建立一個 FastAPI 專案，用來接收檔案。

```bash
mkdir xhr-upload-example-api
cd xhr-upload-example-api
```

建立虛擬環境。

```bash
python -m venv .venv
source .venv/bin/activate
```

新增 `requirements.txt` 檔。

```txt
fastapi[standard]
ruff
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
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit",
      "source.organizeImports": "explicit"
    },
    "editor.defaultFormatter": "charliermarsh.ruff"
  }
}
```

新增 `.gitignore` 檔。

```env
__pycache__/
.venv/
files/
```

新增 `main.py` 檔。

```py
import os

from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

FILE_DIR = "files"

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

if not os.path.exists(FILE_DIR):
    os.makedirs(FILE_DIR)


@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    path = f"{FILE_DIR}/{file.filename}"

    with open(path, "wb") as f:
        f.write(file.file.read())

    return JSONResponse(content={"path": path})
```

啟動伺服器。

```bash
fastapi dev main.py
```

## 實作前端

```bash
mkdir xhr-upload-example-ui
cd xhr-upload-example-ui
```

新增 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>
<body>
  <input type="file" />
  <button type="button">Upload</button>
  <progress value="0" max="100" id="progress-bar"></progress>
  <script>
    const url = 'http://localhost:8000/upload';

    const inputElement = document.querySelector('input');
    const buttonElement = document.querySelector('button');
    const progressBarElement = document.getElementById('progress-bar');

    buttonElement.addEventListener('click', function() {
      const [file] = inputElement.files;
      const formData = new FormData();
      formData.append('file', file);

      const xhr = new XMLHttpRequest();
      xhr.open('POST', url, true);

      xhr.upload.onprogress = function(event) {
        if (event.lengthComputable) {
          progressBarElement.value = (event.loaded / event.total) * 100;
        }
      };

      xhr.send(formData);
    });
  </script>
</body>
</html>
```

啟動伺服器。

```bash
live-server
```

## 程式碼

- [xhr-upload-example-ui](https://github.com/memochou1993/xhr-upload-example-ui)
- [xhr-upload-example-api](https://github.com/memochou1993/xhr-upload-example-api)
