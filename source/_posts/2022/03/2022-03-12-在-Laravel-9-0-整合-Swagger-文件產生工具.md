---
title: 在 Laravel 9.0 整合 Swagger 文件產生工具
permalink: 在-Laravel-9-0-整合-Swagger-文件產生工具
date: 2022-03-12 16:20:35
tags: ["程式設計", "PHP", "Laravel", "Swagger"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 使用

安裝 `darkaonline/l5-swagger` 套件。

```BASH
composer require "darkaonline/l5-swagger"
```

將 `L5SwaggerServiceProvider` 加至 `config/app.php` 檔中。

```PHP
/*
 * Package Service Providers...
 */
L5Swagger\L5SwaggerServiceProvider::class,
```

發布相關檔案。

```BASH
php artisan vendor:publish --provider "L5Swagger\L5SwaggerServiceProvider"
```

如果需要認證，可以修改 `config/l5-swagger.php` 檔中 `securitySchemes` 參數，將 `sanctum` 取消註解，或者加上其他驗證方式。

```PHP
[
    'securitySchemes' => [
        'sanctum' => [
            'type' => 'apiKey',
            'description' => 'Enter token in format (Bearer <token>)',
            'name' => 'Authorization',
            'in' => 'header',
        ],
    ],
],
```

在 `Controller.php` 中加入註解。

```PHP
/**
 * @OA\Info(
 *     version="1.0",
 *     title="my-api"
 * )
 */
class Controller extends BaseController
{
    // ...
}
```

在 `ArticleController.php` 中加入註解。

```PHP
/**
 * Display a listing of the resource.
 *
 * @OA\Get(
 *     tags={"Article"},
 *     path="/api/articles",
 *     security={{"sanctum":{}}},
 *     operationId="get-articles",
 *     summary="Display a listing of the articles.",
 *     description="Display a listing of the articles.",
 *     @OA\Response(
 *       response="200",
 *       description="OK",
 *       @OA\JsonContent()
 *     )
 * )
 *
 * @return AnonymousResourceCollection
 */
public function index(Request $request)
{
    // ...
}

/**
 * Display the specified resource.
 *
 * @OA\Get(
 *     tags={"Article"},
 *     path="/api/articles/{id}",
 *     security={{"sanctum":{}}},
 *     operationId="get-article",
 *     summary="Display the specified article.",
 *     description="Display the specified article.",
 *     @OA\Parameter(
 *       name="id",
 *       description="Article ID",
 *       required=true,
 *       in="path",
 *       @OA\Schema(
 *         type="integer"
 *       )
 *     ),
 *     @OA\Response(
 *       response="200",
 *       description="OK",
 *       @OA\JsonContent()
 *     )
 * )
 *
 * @param Article $article
 * @return ArticleResource
 */
public function show(Article $article)
{
    // ...
}
```

產生文件。

```BASH
php artisan l5-swagger:generate
```

前往：<http://localhost:8000/api/documentation>

## 參考資料

- [L5-Swagger](https://github.com/DarkaOnLine/L5-Swagger)
