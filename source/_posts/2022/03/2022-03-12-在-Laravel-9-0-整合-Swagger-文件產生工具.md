---
title: 在 Laravel 9.0 整合 Swagger 文件產生工具
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

以 `ArticleController` 為例，在各個方法中加入註解。

```PHP
namespace App\Http\Controllers;

use App\Http\Requests\ArticleStoreRequest;
use App\Http\Requests\ArticleUpdateRequest;
use App\Http\Resources\ArticleResource;
use App\Models\Article;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpFoundation\Response;

class ArticleController extends Controller
{
    /**
     * Instantiate a new controller instance.
     */
    public function __construct() {
        $this->authorizeResource(Article::class);
    }

    /**
     * Display a listing of the resource.
     *
     * @OA\Get(
     *     tags={"Article"},
     *     path="/api/articles",
     *     security={{"sanctum":{}}},
     *     @OA\Response(response=200, description="OK", @OA\JsonContent()),
     *     @OA\Response(response=401, description="Unauthorized", @OA\JsonContent()),
     * )
     *
     * @return AnonymousResourceCollection
     */
    public function index(Request $request)
    {
        $articles = $request->user()->articles()->with(['chain'])->get();

        return ArticleResource::collection($articles);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @OA\Post(
     *     tags={"Article"},
     *     path="/api/articles",
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         @OA\MediaType(
     *             mediaType="application/json",
     *             @OA\Schema(
     *                 @OA\Property(property="name", type="string", default=""),
     *                 @OA\Property(property="address", type="string", default=""),
     *                 @OA\Property(property="is_enabled", type="boolean", default=false),
     *                 @OA\Property(property="chain_id", type="integer", default=0),
     *             ),
     *         ),
     *     ),
     *     @OA\Response(response=201, description="Created", @OA\JsonContent()),
     *     @OA\Response(response=401, description="Unauthorized", @OA\JsonContent()),
     *     @OA\Response(response=403, description="Forbidden", @OA\JsonContent()),
     *     @OA\Response(response=404, description="Not Found", @OA\JsonContent()),
     *     @OA\Response(response=422, description="Unprocessable Content", @OA\JsonContent()),
     * )
     *
     * @param ArticleStoreRequest $request
     * @return ArticleResource
     */
    public function store(ArticleStoreRequest $request)
    {
        $article = $request->user()->articles()->create($request->all());

        return new ArticleResource($article);
    }

    /**
     * Display the specified resource.
     *
     * @OA\Get(
     *     tags={"Article"},
     *     path="/api/articles/{id}",
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         description="Article ID",
     *         required=true,
     *         in="path",
     *         @OA\Schema(type="integer"),
     *     ),
     *     @OA\Response(response=200, description="OK", @OA\JsonContent()),
     *     @OA\Response(response=401, description="Unauthorized", @OA\JsonContent()),
     *     @OA\Response(response=403, description="Forbidden", @OA\JsonContent()),
     *     @OA\Response(response=404, description="Not Found", @OA\JsonContent()),
     * )
     *
     * @param Article $article
     * @return ArticleResource
     */
    public function show(Article $article)
    {
        return new ArticleResource($article);
    }

    /**
     * Update the specified resource in storage.
     *
     * @OA\Put(
     *     tags={"Article"},
     *     path="/api/articles/{id}",
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         description="Article ID",
     *         required=true,
     *         in="path",
     *         @OA\Schema(type="integer"),
     *     ),
     *     @OA\RequestBody(
     *         @OA\MediaType(
     *             mediaType="application/json",
     *             @OA\Schema(
     *                 @OA\Property(property="name", type="string", default=""),
     *                 @OA\Property(property="address", type="string", default=""),
     *                 @OA\Property(property="is_enabled", type="boolean", default=false),
     *                 @OA\Property(property="chain_id", type="integer", default=0),
     *             ),
     *         ),
     *     ),
     *     @OA\Response(response=200, description="OK", @OA\JsonContent()),
     *     @OA\Response(response=401, description="Unauthorized", @OA\JsonContent()),
     *     @OA\Response(response=403, description="Forbidden", @OA\JsonContent()),
     *     @OA\Response(response=404, description="Not Found", @OA\JsonContent()),
     *     @OA\Response(response=422, description="Unprocessable Content", @OA\JsonContent()),
     * )
     *
     * @param ArticleUpdateRequest $request
     * @param Article $article
     * @return ArticleResource
     */
    public function update(ArticleUpdateRequest $request, Article $article)
    {
        $article->update($request->all());

        return new ArticleResource($article);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @OA\Delete(
     *     tags={"Article"},
     *     path="/api/articles/{id}",
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         description="Article ID",
     *         required=true,
     *         in="path",
     *         @OA\Schema(type="integer"),
     *     ),
     *     @OA\Response(response=204, description="No Content", @OA\JsonContent()),
     *     @OA\Response(response=401, description="Unauthorized", @OA\JsonContent()),
     *     @OA\Response(response=403, description="Forbidden", @OA\JsonContent()),
     *     @OA\Response(response=404, description="Not Found", @OA\JsonContent()),
     * )
     *
     * @param Article $article
     * @return JsonResponse
     */
    public function destroy(Article $article)
    {
        $article->delete();

        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}
```

產生文件。

```BASH
php artisan l5-swagger:generate
```

前往：<http://localhost:8000/api/documentation>

## 參考資料

- [L5-Swagger](https://github.com/DarkaOnLine/L5-Swagger)
