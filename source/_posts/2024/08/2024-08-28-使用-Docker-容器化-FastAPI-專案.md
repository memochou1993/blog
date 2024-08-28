---
title: 使用 Docker 容器化 FastAPI 專案
date: 2024-08-28 23:40:16
tags: ["Deployment", "Docker", "Python", "FastAPI"]
categories: ["Programming", "Python", "Deployment"]
---

## 實作

新增 `Dockerfile` 檔。

```dockerfile
FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir poetry

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root

COPY . .

CMD ["poetry", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]

EXPOSE 80
```

新增 `docker-compose.yml` 檔。

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "80:80"
    environment:
      - PYTHONUNBUFFERED=1
```

啟動服務。

```bash
docker compose up -d
```
