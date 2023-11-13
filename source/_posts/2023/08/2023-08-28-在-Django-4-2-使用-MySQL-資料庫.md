---
title: 在 Django 4.2 使用 MySQL 資料庫
date: 2023-08-28 20:15:44
tags: ["Programming", "Python", "Django", "MySQL"]
categories: ["Programming", "Python", "Django"]
---

## 實作

修改 `requirements.txt` 檔，添加依賴項目。

```bash
pymysql
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

修改 `example/settings.py` 檔。

```py
import pymysql

pymysql.install_as_MySQLdb()

# ...

DATABASES = {
    'default': {
        "ENGINE": "django.db.backends.mysql",
        "NAME": "my_project",
        "USER": "root",
        "PASSWORD": "root",
        "HOST": "127.0.0.1",
        "PORT": "3306",
    }
}
```

執行遷移。

```bash
python manage.py migrate
```

## 參考資料

- [Django - Databases](https://docs.djangoproject.com/en/4.2/ref/databases/)
