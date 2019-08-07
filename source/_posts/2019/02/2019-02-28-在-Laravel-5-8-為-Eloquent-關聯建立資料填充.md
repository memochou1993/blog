---
title: 在 Laravel 5.8 為 Eloquent 關聯建立資料填充
permalink: 在-Laravel-5-8-為-Eloquent-關聯建立資料填充
date: 2019-02-28 17:46:51
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 前言

假設一個使用者（`User`）擁有多個專案，一個專案（`Project`）擁有多個使用者，以及一個專案擁有有多個設定檔（`Environment`）。

## 建立模型

修改 `app/User.php` 檔。

```PHP
/**
 * Get the route key for the model.
 *
 * @return string
 */
public function getRouteKeyName()
{
    return 'username';
}

/**
 * Get the projects that belong to the user.
 *
 * @return \Illuminate\Database\Eloquent\Relations\BelongsToMany
 */
public function projects()
{
    return $this->belongsToMany(Project::class, 'user_project')->withTimestamps();
}
```

修改 `app/Project.php` 檔。

```PHP
/**
 * Get the users that belong to the project.
 *
 * @return \Illuminate\Database\Eloquent\Relations\BelongsToMany
 */
public function users()
{
    return $this->belongsToMany(User::class, 'user_project')->withTimestamps();
}

/**
 * Get the environments for the project.
 *
 * @return \Illuminate\Database\Eloquent\Relations\HasMany
 */
public function environments()
{
    return $this->hasMany(Environment::class);
}
```

修改 `app/Environment.php` 檔。

```PHP
/**
 * Get the project that the environments belongs to.
 *
 * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
 */
public function project()
{
    return $this->belongsTo(Project::class);
}
```

## 建立資料填充

建立 `ProjectsTableSeeder.php` 檔。

```CMD
php artisan make:seed ProjectsTableSeeder
```

為第一個使用者建立 10 筆私人專案，並為每筆專案建立 5 筆設定檔。

```PHP
factory(Project::class, 10)->create([
    'private' => true,
])->each(
    function (Project $project) {
        $project->users()->attach(1);

        $project->environments()->saveMany(
            factory(Environment::class, 5)->make()
        );
    }
);
```

建立 `UserProjectTableSeeder.php` 檔。

```CMD
php artisan make:seed UserProjectTableSeeder
```

為所有使用者與 10 筆專案建立隨機的多對多關聯。

```PHP
/**
 * Get all public projects.
 */
$projects = Project::all();

/**
 * Create many-to-many relationships between users and public projects.
 */
User::all()->each(function ($user) use ($projects) {
    $user->projects()->attach(
        $projects->random(rand(1, 10))->pluck('id')->all()
    );
});
```
