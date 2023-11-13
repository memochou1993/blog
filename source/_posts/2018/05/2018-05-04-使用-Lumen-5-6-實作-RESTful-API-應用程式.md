---
title: 使用 Lumen 5.6 實作 RESTful API 應用程式
date: 2018-05-04 10:19:40
tags: ["Programming", "PHP", "Laravel", "Lumen"]
categories: ["Programming", "PHP", "Lumen"]
---

## 前言

本文實作一個可以對其進行 CRUD 的期刊目錄 API。

## 環境

- Windows 10
- Homestead 7.4.1

## 建立專案

建立專案。

```bash
lumen new journal
```

## 設定環境參數

設置 `Homestead.yaml` 檔。

```env
sites:
    - map: journal.test
      to: /home/vagrant/Projects/journal/public

databases:
    - journal
```

設置 `hosts` 檔。

```env
192.168.10.10 journal.test
```

設置 `.env` 檔。

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=journal
DB_USERNAME=homestead
DB_PASSWORD=secret
```

啟動 Homestead。

```bash
cd Homestead
vagrant up
```

## 新增遷移

新增 `journals` 資料表。

```bash
php artisan make:migration create_journals_table
```

配置欄位。

```php
Schema::create('journals', function (Blueprint $table) {
    $table->increments('id');
    $table->string('title');
    $table->string('creator');
    $table->timestamps();
});
```

執行遷移。

```bash
php artisan migrate
```

## 新增填充

手動新增 `database\seeds\JournalsTableSeeder.php` 檔，並編輯為：

```php
$journals = factory(App\Journal::class, 20)->create();
```

在 `DatabaseSeeder.php` 呼叫。

```php
public function run()
{
    $this->call('JournalsTableSeeder');
}
```

手動新增 `database\factories\JournalFactory.php` 檔，並編輯為：

```php
$factory->define(App\Journal::class, function (Faker $faker) {
    return [
        'title' => $faker->realText(rand(10,20)),
        'creator' => $faker->companySuffix,
    ];
});
```

執行填充。

```bash
php artisan db:seed
```

## 新增模型

手動新增 `app\Journal` 模型，並配置可寫入欄位。

```php
protected $fillable = [
    'title', 'creator'
];
```

## 新增路由

由於沒有視圖，因此不用 create 和 edit 路由。

```php
$router->group(['prefix' => 'api/journals'],  function($router) {
    $router->get('/', 'JournalController@index');
    $router->post('/', 'JournalController@store');
    $router->get('/{journal}', 'JournalController@show');
    $router->patch('/{journal}', 'JournalController@update');
    $router->delete('/{journal}', 'JournalController@destroy');
});
```

## 新增控制器

取得所有期刊。

```php
public function index(Request $request)
{
    return response()->json(Journal::all());
}
```

儲存期刊。

```php
public function store(Request $request)
{
    $this->validate($request, [
        'title' => 'required',
        'creator' => 'required',
    ]);

    $journal = Journal::create($request->all());

    return response()->json($journal, 201);
}
```

取得指定期刊。

```php
public function show($id)
{
    return response()->json(Journal::find($id));
}
```

更新指定期刊。

```php
public function update(Request $request, $id)
{
    $journal = Journal::findOrFail($id);

    $journal->update($request->all());

    return response()->json($journal, 200);
}
```

刪除指定期刊。

```php
public function destroy($id)
{
    Journal::findOrFail($id)->delete();

    return response()->json(null, 204);
}
```

## 進行 HTTP 請求測試

使用 Postman 向網址 journal.test/api/journals 發起 `GET` 請求，得到回應如下：

```json
[
    {
        "id": 1,
        "title": "I was.",
        "creator": "Group",
        "created_at": "2018-05-03 16:18:54",
        "updated_at": "2018-05-03 16:23:40"
    },
    // ...
]
```

## RESTful API 路由風格

| 動詞 | 路徑 | 動作 | 路由名稱 |
| --- | --- | --- | --- |
| GET | /photos | index | photos.index |
| GET | /photos/create | create | photos.create |
| POST | /photos | store | photos.store |
| GET | /photos/{photo} | show | photos.show |
| GET | /photos/{photo}/edit | edit | photos.edit |
| PUT/PATCH | /photos/{photo} | update | photos.update |
| DELETE | /photos/{photo} | destroy | photos.destroy |

## 補充

發起 `PUT`、`PATCH` 或 `DELETE` 請求，需要在 `body` 表單加上：

| Key | Value |
| --- | --- |
| _method | PUT / PATCH / DELETE |
