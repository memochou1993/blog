---
title: 使用 Docker 容器化 Django 專案
date: 2023-08-30 00:06:49
tags: ["環境部署", "Docker", "Python", "Django"]
categories: ["程式設計", "Python", "環境部署"]
---

## 實作

如果有使用資料庫，修改 `example/settings.py` 檔。

```py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'USER': 'postgres',
        'NAME': 'article_api',
        'PASSWORD': 'root',
        'HOST': 'postgres', # 修改此行
        'PORT': '5432',
    }
}
```

新增 `Dockerfile` 檔。

```dockerfile
FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt .

RUN pip3 install -r requirements.txt --no-cache-dir

COPY . /app

EXPOSE 8000

CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
```

新增 `docker-compose.yml` 檔。

```yaml
version: "3"

services:
  app:
    container_name: django-api-example
    build: .
    restart: always
    depends_on:
      - postgres
    volumes:
      - .:/var/www
    ports:
      - "80:8000"
    networks:
      - backend

  postgres:
    image: postgres:latest
    container_name: django-api-example-postgres
    restart: always
    volumes:
      - postgres:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - backend
    environment:
      POSTGRES_DB: article_api
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: root

networks:
  backend:

volumes:
  postgres:
```

啟動服務。

```bash
docker compose up -d
```

進入容器。

```bash
docker exec -it django-api-example sh
```

執行遷移。

```bash
python manage.py migrate
```

建立使用者。

```bash
python manage.py createsuperuser
```
