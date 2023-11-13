---
title: 在 Django 4.2 使用 PostgreSQL 資料庫
date: 2023-08-29 23:02:52
tags: ["Programming", "Python", "Django", "MySQL"]
categories: ["Programming", "Python", "Django"]
---

## 實作

修改 `requirements.txt` 檔，添加依賴項目。

```bash
psycopg2-binary
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

修改 `example/settings.py` 檔。

```py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'USER': 'postgres',
        'NAME': 'article_api',
        'PASSWORD': 'root',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

執行遷移。

```bash
python manage.py migrate
```

## 參考資料

- [Django - Databases](https://docs.djangoproject.com/en/4.2/ref/databases/)
