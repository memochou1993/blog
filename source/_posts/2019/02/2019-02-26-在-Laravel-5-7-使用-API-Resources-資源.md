---
title: 在 Laravel 5.7 使用 API Resources 資源
date: 2019-02-26 18:12:28
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

建立 `ProjectResource.php` 檔。

```BASH
php artisan make:resource ProjectResource
```

指定 API 欄位，並使用 `whenLoaded` 方法避免總是載入關聯資料。

```PHP
public function toArray($request)
{
    return [
        'id' => $this->id,
        'name' => $this->name,
        'description' => $this->description,
        'visibility' => $this->visibility,
        'created_at' => $this->created_at->diffForHumans(),
        'updated_at' => $this->updated_at->diffForHumans(),
        'users' => UserResource::collection($this->whenLoaded('users')),
    ];
}
```

修改 `ProjectController.php` 檔。

```PHP
use App\Project;
use App\Http\Resources\ProjectResource as Resource;

public function index(Project $project)
{
    $projects = $project->paginate();

    return Resource::collection($projects);
}

public function show(Project $project, $id)
{
    $project = $project->find($id);

    return new Resource($project);
}
```

添加額外資訊。

```PHP
use Illuminate\Support\Str;

class ResponseHelper
{
    public static function response($content)
    {
        $meta = [
            'foo' => 'bar',
        ];

        if (is_object($content) && Str::contains(class_basename($content), 'Resource')) {
            return $content->additional($meta);
        }
    }
}
```
