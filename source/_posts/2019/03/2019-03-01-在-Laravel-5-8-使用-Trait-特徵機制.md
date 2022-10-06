---
title: 在 Laravel 5.8 使用 Trait 特徵機制
date: 2019-03-01 03:13:33
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

設計一個 Controller 和 Repository 都會使用到的 Query 特徵機制。

## 構想

在 Repository 定義好取得資源的方法，並預先寫好 `where` 和 `with` 查詢。

```php
$user->projects()->where($this->where)->with($this->with)->findOrFail($project->id);
```

在 Controller 使用以下方式，取得特定資料。

```php
$this->setQuery([
    'where' => [
        'private' => false,
    ],
]);
```

在 Controller 使用以下方式，取得關聯資料。

```php
$this->setQuery([
    'with' => $request->with,
]);
```

## 做法

在 `app/Contracts` 資料夾的 `ProjectInterface.php` 檔，定義一個 `getUserProject()` 方法，第三個參數是 `$query`。

```php
namespace App\Contracts;

use App\User;
use App\Project;

interface ProjectInterface
{
    public function getUserProject(User $user, Project $project, array $query = []);
}
```

在 `app/Http/Controllers/Api/User` 資料夾的 `ProjectController.php` 檔，使用 `Queryable` 特徵機制，並使用 `getUserProject()` 方法，從 Repository 取得特定使用者的所有專案。

```php
namespace App\Http\Controllers\Api\User;

use App\Project;
use App\Traits\Queryable;
use Illuminate\Http\Request;
use App\Http\Controllers\Api\ApiController;
use App\Contracts\ProjectInterface as Repository;
use App\Http\Resources\ProjectResource as Resource;

class ProjectController extends ApiController
{
    // 使用特徵機制
    use Queryable;

    /**
     * @var \Illuminate\Http\Request
     */
    protected $request;

    /**
     * @var \App\Contracts\ProjectInterface
     */
    protected $reposotory;

    /**
     * Create a new controller instance.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Contracts\ProjectInterface  $reposotory
     * @return void
     */
    public function __construct(Request $request, Repository $reposotory)
    {
        parent::__construct();

        $this->request = $request;

        $this->reposotory = $reposotory;

        // 使用 with 查詢
        $this->setQuery([
            'with' => $request->with,
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Project  $project
     * @return \App\Http\Resources\ProjectResource
     */
    public function show(Project $project)
    {
        // 使用 where 查詢
        $this->setQuery([
            'where' => [
                'private' => false,
            ],
        ]);

        $project = $this->reposotory->getUserProject($this->user, $project, $this->query);

        return new Resource($project);
    }
}
```

在 `app/Traits/Queryable.php` 檔定義 `setQuery()` 以及 `castQuery()` 方法。

```php
namespace App\Traits;

trait Queryable
{
    /**
     * @var array
     */
    protected $query = [];

    /**
     * @var array
     */
    protected $with;

    /**
     * @var array
     */
    protected $where;

    /**
     * @param  array  $queries
     * @return void
     */
    protected function setQuery(array $queries)
    {
        foreach($queries as $key => $value) {
            $this->query[$key] = $value;
        }
    }

    /**
     * @param  array  $query
     * @return void
     */
    protected function castQuery(array $query)
    {
        $where = $query['where'] ?? [];

        $this->where = $where;

        $with = explode(',', $query['with'] ?? '');

        $this->with = $with[0] ? $with : [];
    }
}
```

在 `app/Repositories` 資料夾的 `ProjectRepository.php` 檔使用 `$this->castQuery()` 方法，將 `$query` 注入，即可使用 `$this->where` 以及 `$this->with` 調用。

```php
namespace App\Repositories;

use App\User;
use App\Project;
use App\Traits\Queryable;
use App\Contracts\ProjectInterface;

class ProjectRepository implements ProjectInterface
{
    // 使用特徵機制
    use Queryable;

    /**
     * Get the specified project for the specified user.
     *
     * @param  \App\User  $user
     * @param  array  $query
     * @return \App\Project
     */
    public function getUserProject(User $user, Project $project, array $query = [])
    {
        $this->castQuery($query);

        return $user->projects()->where($this->where)->with($this->with)->findOrFail($project->id);
    }
}
```
