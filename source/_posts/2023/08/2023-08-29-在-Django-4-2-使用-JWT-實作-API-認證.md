---
title: 在 Django 4.2 使用 JWT 實作 API 認證
date: 2023-08-29 00:08:50
tags: ["程式設計", "Python", "Django", "JWT"]
categories: ["程式設計", "Python", "Django"]
---

## 實作

修改 `requirements.txt` 檔，添加依賴項目。

```bash
djangorestframework-simplejwt
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

修改 `example/settings.py` 檔。

```py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}
```

修改 `example/urls.py` 檔。

```py
# ...
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

urlpatterns = [
    # ...
    path('api/token', TokenObtainPairView.as_view(), name='obtain_token'),
    path('api/token/refresh', TokenRefreshView.as_view(), name='refresh_token'),
    path('api/token/verify', TokenVerifyView.as_view(), name='verify_token'),
]
```

修改 `articles/views.py` 檔。

```py
# ...
from rest_framework.permissions import IsAuthenticated

# Create your views here.
class ArticleViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    serializer_class = ArticleSerializer
    queryset = Article.objects.all()

    # ...
```

## 參考資料

- [jazzband/djangorestframework-simplejwt](https://github.com/jazzband/djangorestframework-simplejwt)
- [Django REST framework - Permissions](https://www.django-rest-framework.org/api-guide/permissions/)
