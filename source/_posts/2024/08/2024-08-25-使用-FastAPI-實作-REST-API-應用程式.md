---
title: 使用 FastAPI 實作 REST API 應用程式
date: 2024-08-25 13:39:42
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
mkdir my-project
cd my-project
```

初始化專案。

```bash
poetry init
```

啟動虛擬環境。

```bash
poetry shell
```

安裝依賴套件。

```bash
poetry add fastapi uvicorn
```

新增 `main.py` 檔。

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
uvicorn main:app --reload --port 8000
```

## 實作

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
