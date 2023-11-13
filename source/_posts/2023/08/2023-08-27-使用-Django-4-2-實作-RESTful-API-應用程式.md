---
title: 使用 Django 4.2 實作 RESTful API 應用程式
date: 2023-08-27 18:36:32
tags: ["Programming", "Python", "Django"]
categories: ["Programming", "Python", "Django"]
---

## 建立專案

建立專案。

```bash
mkdir django-api-example
cd django-api-example
```

建立虛擬環境。

```bash
pyenv virtualenv 3.11.4 django-api-example
pyenv local django-api-example
```

新增 `requirements.txt` 檔。

```txt
django
djangorestframework
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

新增 `.gitignore` 檔。

```env
db.sqlite3
__pycache__/
```

## 實作

新增專案。

```bash
django-admin startproject example .
```

新增應用程式。

```bash
django-admin startapp articles
```

修改 `example/settings.py` 檔。

```py
INSTALLED_APPS = [
    // ...
    'rest_framework',
    'articles',
]
```

### 模型

修改 `articles/models.py` 檔。

```py
from django.db import models

# Create your models here.
class Article(models.Model):
    title = models.CharField(max_length=255)

    class Meta:
        db_table = "articles"
```

### 遷移

建立遷移表。

```bash
python manage.py makemigrations
```

執行遷移。

```bash
python manage.py migrate
```

修改 `articles/serializers.py` 檔。

```py
from rest_framework import serializers
from articles.models import Article

class ArticleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Article
        fields = '__all__'
```

### 路由

修改 `example/urls.py` 檔。

```py
from django.contrib import admin
from django.urls import include, path
from rest_framework.routers import DefaultRouter
from articles import views

router = DefaultRouter(trailing_slash=False)
router.register('articles', views.ArticleViewSet, basename='article')

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
]
```

### 視圖

修改 `articles/views.py` 檔。

```py
from articles.models import Article
from rest_framework import viewsets, status
from rest_framework.response import Response
from .serializers import ArticleSerializer
from django.shortcuts import get_object_or_404

# Create your views here.
class ArticleViewSet(viewsets.ModelViewSet):
    serializer_class = ArticleSerializer
    queryset = Article.objects.all()

    def list(self, request):
        queryset = Article.objects.all()
        serializer = self.serializer_class(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def retrieve(self, request, pk=None):
        article = get_object_or_404(self.queryset, pk=pk)
        serializer = self.serializer_class(article)
        return Response(serializer.data)

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, pk=None, *args, **kwargs):
        article = get_object_or_404(self.queryset, pk=pk)
        serializer = self.serializer_class(article, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, pk=None):
        article = get_object_or_404(self.queryset, pk=pk)
        article.delete()
        return Response(None, status=status.HTTP_204_NO_CONTENT)
```

## 程式碼

- [django-api-example](https://github.com/memochou1993/django-api-example)

## 參考資料

- [Django](https://www.djangoproject.com/)
- [Django REST framework](https://www.django-rest-framework.org/)
