---
title: 在 Laravel 7.0 為關聯模型建立 Seeder 資料填充
permalink: 在-Laravel-7-0-為關聯模型建立-Seeder-資料填充
date: 2020-04-23 01:47:13
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

本文使用「一個使用者擁有多個專案和多筆文章」為例，為關聯模型建立資料填充。

## 關聯方法

首先，為 `User` 模型建立關聯方法：

```PHP
/**
 * Get all of the projects for the user.
 *
 * @return \Illuminate\Database\Eloquent\Relations\hasMany
 */
public function projects() {
    return $this->hasMany(Project::class);
}

/**
 * Get all of the posts for the user.
 *
 * @return \Illuminate\Database\Eloquent\Relations\hasMany
 */
public function posts() {
    return $this->hasMany(Post::class);
}
```

`User` 模型和 `Project` 模型是一對多的關聯，和 `Post` 模型也是一對多的關聯

## 做法一

以父模型為主，由上而下建立關聯資料。

修改 `UserSeeder` 資料填充，建立 5 個使用者，為每個使用者個別建立 10 個專案和 10 筆文章。

```PHP
factory(App\User::class, 5)->create()->each(function ($user) {
    $user->projects()->saveMany(factory(App\Project::class, 10)->make());
    $user->posts()->saveMany(factory(App\Post::class, 10)->make());
});
```

此方法在模型互相關聯的情況下，容易形成複雜的巢狀結構。而且每一個模型的資料填充都寫在同一個檔案內，形成高度耦合。

## 做法二

以子模型為主，由下而上建立關聯資料。

修改 `ProjectSeeder` 資料填充，建立 5 個專案。

```PHP
factory(App\Project::class, 5)->create();
```

修改 `ProjectFactory` 模型工廠，為每個專案建立 1 個使用者。

```PHP
$factory->define(Project::class, function (Faker $faker) {
    return [
        'user_id' => factory(App\User::class)->create()->id,
    ];
});
```

修改 `PostSeeder` 資料填充，建立 5 筆文章。

```PHP
factory(App\Post::class, 5)->create();
```

修改 `PostFactory` 模型工廠，為每筆文章建立 1 個使用者。

```PHP
$factory->define(Post::class, function (Faker $faker) {
    return [
        'user_id' => factory(App\User::class)->create()->id,
    ];
});
```

此方法導致 `Project` 模型和 `Post` 模型所生產出來的 `User` 模型都不一樣，無法反映一個使用者同時擁有專案和文章的情況。而且在模型工廠做資料填充的行為，違反了單一職責原則。

## 做法三

從資料庫找出既有資料，再建立個別的關聯資料。

修改 `UserSeeder` 資料填充，建立 5 個使用者。

```PHP
factory(App\User::class, 5)->create();
```

修改 `ProjectSeeder` 資料填充，撈出所有使用者，個別建立 10 個專案。

```PHP
App\User::all()->each(function ($user) {
    $user->projects()->saveMany(
        factory(App\Project::class, 10)->make()
    );
});
```

修改 `PostSeeder` 資料填充，撈出所有使用者，個別建立 10 筆文章。

```PHP
App\User::all()->each(function ($user) {
    $user->posts()->saveMany(
        factory(App\Post::class, 10)->make()
    );
});
```

此方法雖然解耦了模型之間的資料填充，但關聯模型一旦複雜，會產生很多次的資料庫查詢。

## 做法四

先定義好要建立的資料數量，在模型工廠定義外鍵範圍，再一次性插入資料庫。

修改 `UserSeeder` 資料填充，定義一個常數，代表要建立的使用者數量：

```PHP
public const AMOUNT = 5;
```

建立 5 個使用者。

```PHP
factory(App\User::class, self::AMOUNT)->create();
```

修改 `ProjectFactory` 模型工廠，定義好外鍵範圍：

```PHP
$factory->define(Project::class, function (Faker $faker) {
    return [
        'user_id' => $faker->numberBetween(1, UserSeeder::AMOUNT),
        'created_at'  => now(),
        'updated_at'  => now(),
    ];
});
```

修改 `ProjectSeeder` 資料填充，定義一個常數，代表要建立的專案數量：

```PHP
public const AMOUNT = 10;
```

使用插入的方式，一次建立 10 個專案。

```PHP
DB::table(app(Project::class)->getTable())->insert(
    factory(Project::class, self::AMOUNT)->make()->toArray()
);
```

修改 `PostFactory` 模型工廠，定義好外鍵範圍：

```PHP
$factory->define(Post::class, function (Faker $faker) {
    return [
        'user_id' => $faker->numberBetween(1, UserSeeder::AMOUNT),
        'created_at'  => now(),
        'updated_at'  => now(),
    ];
});
```

修改 `PostSeeder` 資料填充，定義一個常數，代表要建立的文章數量：

```PHP
public const AMOUNT = 10;
```

在 `PostSeeder` 資料填充使用插入的方式，一次建立 10 筆文章。

```PHP
DB::table(app(Post::class)->getTable())->insert(
    factory(Post::class, self::AMOUNT)->make()->toArray()
);
```

此方法速度最快，但是模型之間的關聯是隨機的，不是每一個使用者都可以有專案和文章。

## 做法五

先定義好要建立的資料數量，在資料填充使用 Collection 產生外鍵列表，將所有資料疊代、合併後，再一次性插入資料庫。

修改 `UserSeeder` 資料填充，定義一個常數，代表要建立的使用者數量：

```PHP
public const AMOUNT = 5;
```

建立 5 個使用者。

```PHP
factory(App\User::class, self::AMOUNT)->create();
```

修改 `ProjectSeeder` 資料填充，定義一個常數，代表要建立的專案數量：

```PHP
public const AMOUNT = 10;
```

使用 Collection 建立外鍵列表，疊代每一個外鍵，產生並合併資料，最後一次為每個使用者建立 10 個專案。

```PHP
$projects = collect()
    ->times(UserSeeder::AMOUNT)
    ->map(function ($userId) {
        return factory(Project)::class, self::AMOUNT)->make([
            'user_id' => $userId,
        ]);
    })
    ->collapse()
    ->toArray();

DB::table(app(Project)::class)->getTable())->insert($projects);
```

修改 `PostSeeder` 資料填充，定義一個常數，代表要建立的文章數量：

```PHP
public const AMOUNT = 10;
```

使用 Collection 建立外鍵列表，疊代每一個外鍵，產生並合併資料，最後一次為每個使用者建立 10 筆文章。

```PHP
$posts = collect()
    ->times(UserSeeder::AMOUNT)
    ->map(function ($userId) {
        return factory(Post)::class, self::AMOUNT)->make([
            'user_id' => $userId,
        ]);
    })
    ->collapse()
    ->toArray();

DB::table(app(Post)::class)->getTable())->insert($posts);
```

此方法的速度會稍微慢一些，但不會比使用 Eloquent 慢，因為每一個使用者都能夠得到專案和文章，測試資料最完整。

## 做法六

將儲存的假資料儲存在靜態變數中，以供其他資料填充使用。

修改 `UserSeeder` 資料填充：

```PHP
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    private const AMOUNT = 5;

    static private Collection $users;

    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $admin = app(User::class)->create([
            'name' => env('ADMIN_NAME'),
            'email' => env('ADMIN_EMAIL'),
            'password' => Hash::make(env('ADMIN_PASSWORD')),
        ]);

        $users = factory(User::class, self::AMOUNT - 1)->create();

        $this->setUsers(new Collection([
            $admin,
            $users,
        ]));
    }

    /**
     * Set the test users.
     *
     * @param  $users
     * @return void
     */
    public function setUsers($users): void
    {
        self::$users = $users;
    }

    /**
     * Get the test users.
     *
     * @return Collection
     */
    public function getUsers(): Collection
    {
        return self::$users;
    }
}
```

修改 `ProjectSeeder` 資料填充，為每個使用者個別建立 10 個專案。

```PHP
app(UserSeeder::class)->getUsers()->each(function ($user) {
    $user->projects()->saveMany(factory(App\Project::class, 10)->make());
});
```

修改 `PostSeeder` 資料填充，為每個使用者個別建立 10 筆文章。

```PHP
app(UserSeeder::class)->getUsers()->each(function ($user) {
    $user->posts()->saveMany(factory(App\Post::class, 10)->make());
});
```

此方法既不需要把關聯資料寫在同一個檔案中，也不需要再次查詢資料庫，不過要多寫一些方法去處理靜態變數的存取。
