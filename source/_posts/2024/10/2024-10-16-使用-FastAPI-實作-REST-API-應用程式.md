---
title: 使用 FastAPI 實作 REST API 應用程式
date: 2024-10-16 23:49:59
tags: ["Programming", "Python", "FastAPI"]
categories: ["Programming", "Python", "FastAPI"]
---

## 前置作業

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
mkdir fastapi-example
cd fastapi-example
```

使用 Poetry 初始化專案。

```bash
poetry init
```

啟動虛擬環境。

```bash
poetry shell
```

## 安裝檢查工具

安裝依賴套件。

```bash
poetry add ruff
```

新增 `ruff.toml` 檔。

```toml
line-length = 120
indent-width = 4

[format]
quote-style = "double"
```

修改 `.vscode/settings.json` 檔。

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

## 實作

安裝依賴套件。

```bash
poetry add "fastapi[standard]"
```

新增 `main.py` 檔。

```py
from typing import Union

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}
```

啟動網頁伺服器。

```bash
fastapi dev main.py
```

前往 <http://localhost:8000/docs> 瀏覽，並使用文件測試 API 端點。

### 建立端點

修改 `main.py` 檔。

```py
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()


class Item(BaseModel):
    id: int
    name: str
    description: Optional[str] = None


items = [
    Item(id=1, name="Item 1", description="Description 1"),
    Item(id=2, name="Item 2", description="Description 2"),
]


@app.get("/api", tags=["Default"])
async def root():
    return {
        "status": "ok",
    }


@app.get("/api/items", response_model=List[Item], tags=["Items"])
async def get_items():
    return items


@app.post("/api/items", response_model=Item, tags=["Items"])
async def create_item(item: Item):
    items.append(item)
    return item


@app.get("/api/items/{item_id}", response_model=Item, tags=["Items"])
async def get_item(item_id: int):
    item = next((item for item in items if item.id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@app.put("/api/items/{item_id}", response_model=Item, tags=["Items"])
async def update_item(item_id: int, updated_item: Item):
    index = next((index for index, item in enumerate(items) if item.id == item_id), None)
    if index is None:
        raise HTTPException(status_code=404, detail="Item not found")
    items[index] = updated_item
    return updated_item


@app.delete("/api/items/{item_id}", tags=["Items"])
async def delete_item(item_id: int):
    global items
    items = [item for item in items if item.id != item_id]
    return {"status": "Item deleted"}
```

前往 <http://localhost:8000/docs> 瀏覽，並使用文件測試 API 端點。

### 提交修改

新增 `.gitignore` 檔。

```bash
__pycache__
```

提交修改。

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:memochou1993/fastapi-example.git
git push -u origin main
```

## 測試端點

安裝 [Bruno](https://www.usebruno.com/) 工具。

建立一個集合：

- Name: `fastapi-example`
- Location: `~/path-to-your-project/fastapi-example`
- Name: `bruno`

建立端點：

- list-items: `GET` <http://localhost:8000/api/items`>
- create-item: `POST` <http://localhost:8000/api/items`>
- get-item: `GET` <http://localhost:8000/api/items/:id`>
- update-item: `GET` <http://localhost:8000/api/items/:id`>
- delete-item: `DELETE` <http://localhost:8000/api/items/:id`>

## 程式碼

- [fastapi-example](https://github.com/memochou1993/fastapi-example)

## 參考資料

- [Poetry](https://python-poetry.org/)
- [FastAPI](https://fastapi.tiangolo.com/)
