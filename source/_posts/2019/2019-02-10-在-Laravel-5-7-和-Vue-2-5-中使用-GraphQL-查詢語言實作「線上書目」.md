---
title: 在 Laravel 5.7 和 Vue 2.5 中使用 GraphQL 查詢語言實作「線上書目」
permalink: 在-Laravel-5-7-和-Vue-2-5-中使用-GraphQL-查詢語言實作「線上書目」
date: 2019-02-10 21:50:05
tags: ["程式寫作", "GraphQL", "PHP", "Laravel", "JavaScript", "Vue"]
categories: ["程式寫作", "GraphQL"]
---

## 前言
本文為「[GraphQL Laravel & Vue](https://www.youtube.com/watch?v=hvjW-MQEwIM&list=PLEhEHUEU3x5qsA5JnRzhgOghrH9Vqz4cg)」教學影片的學習筆記。

## 環境
- macOS

## 建立專案
新增 Laravel 專案。
```
$ laravel new booksql-laravel
```

安裝 `nuwave/lighthouse` 套件。
```
$ composer require nuwave/lighthouse
```

發布資源。
```
$ php artisan vendor:publish --provider="Nuwave\Lighthouse\Providers\LighthouseServiceProvider" --tag=schema
$ php artisan vendor:publish --provider="Nuwave\Lighthouse\Providers\LighthouseServiceProvider" --tag=config
```

修改 `config/lighthouse.php` 檔中 `models` 指定的命名空間。
```PHP
'namespaces' => [
    'models' => 'App',
    'queries' => 'App\\Http\\GraphQL\\Queries',
    'mutations' => 'App\\Http\\GraphQL\\Mutations',
    'interfaces' => 'App\\Http\\GraphQL\\Interfaces',
    'unions' => 'App\\Http\\GraphQL\\Unions',
    'scalars' => 'App\\Http\\GraphQL\\Scalars',
],
```

### 跨域資源共享
安裝 `laravel-cors` 套件。
```
$ composer require barryvdh/laravel-cors
```

修改 `config/lighthouse.php` 檔：
```PHP
'route' => [
    'prefix' => '',
    'middleware' => [
        \Barryvdh\Cors\HandleCors::class,
    ],
],
```

## 新增模型
新增 `Category` 模型。
```
$ php artisan make:model Category -a
```

修改 `app/Category.php` 檔，以允許批量賦值，以及建立關聯。
```PHP
protected $guarded = [];

public function books()
{
    return $this->hasMany(Book::class);
}
```

新增 `Book` 模型。
```
$ php artisan make:model Book -a
```

修改 `app/Book.php` 檔，以允許批量賦值，以及建立關聯。
```PHP
protected $guarded = [];

public function category()
{
    return $this->belongsTo(Category::class);
}
```

## 新增遷移
修改 `database/migrations/create_books_table.php` 檔。
```PHP
public function up()
{
    Schema::create('books', function (Blueprint $table) {
        $table->increments('id');
        $table->string('title');
        $table->string('author');
        $table->string('image')->nullable();
        $table->string('description')->nullable();
        $table->string('link')->nullable();
        $table->string('featured')->default(false);
        $table->integer('category_id')->unsigned();
        $table->foreign('category_id')->references('id')->on('categories')->onUpdate('cascade');
        $table->timestamps();
    });
}
```

修改 `database/migrations/create_categories_table.php` 檔。
```PHP
public function up()
{
    Schema::create('categories', function (Blueprint $table) {
        $table->increments('id');
        $table->string('name');
        $table->timestamps();
    });
}
```

執行遷移。
```
$ php artisan migrate
```

## 新增填充
使用範例，修改 `database/seeds/CategoriesTableSeeder.php` 檔。
```PHP
public function run()
{
    Category::insert([
        [
            'name' => 'Marketing',
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
        [
            'name' => 'Business',
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
        [
            'name' => 'Finance',
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
        [
            'name' => 'Entrepreneurship',
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
        [
            'name' => 'Science',
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
        [
            'name' => 'Biography',
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
    ]);
}
```

使用範例，修改 `database/seeds/BooksTableSeeder.php` 檔。
```PHP
public function run()
{
    Book::insert([
        [
            'title' => 'The Lean Startup',
            'author' => 'Eric Ries',
            'image' => 'https://res.cloudinary.com/dqzxpn5db/image/upload/v1547790672/booksql/the-lean-startup.jpg',
            'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Maiores illum, culpa minus? Id veritatis possimus natus facilis est nisi non vero, cum sint recusandae praesentium exercitationem dolorum itaque vitae eos consequuntur magni accusantium officia at.',
            'link' => 'https://www.amazon.com/Lean-Startup-Entrepreneurs-Continuous-Innovation/dp/0307887898/ref=sr_1_2/133-5239949-7549327?ie=UTF8&qid=1545650084&sr=8-2&keywords=learn+startup',
            'category_id' => 1,
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
        [
            'title' => 'Rework',
            'author' => 'Jason Fried & David Heinemeier Hansson',
            'image' => 'https://res.cloudinary.com/dqzxpn5db/image/upload/v1547790672/booksql/rework.jpg',
            'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Maiores illum, culpa minus? Id veritatis possimus natus facilis est nisi non vero, cum sint recusandae praesentium exercitationem dolorum itaque vitae eos consequuntur magni accusantium officia at.',
            'link' => 'https://www.amazon.com/Rework-Jason-Fried/dp/0307463745/ref=sr_1_2?ie=UTF8&qid=1545650510&sr=8-2&keywords=rework',
            'category_id' => 1,
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
        [
            'title' => 'Sapiens',
            'author' => 'Yuval Noah Harari',
            'image' => 'https://res.cloudinary.com/dqzxpn5db/image/upload/v1547790672/booksql/sapiens.jpg',
            'description' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Maiores illum, culpa minus? Id veritatis possimus natus facilis est nisi non vero, cum sint recusandae praesentium exercitationem dolorum itaque vitae eos consequuntur magni accusantium officia at.',
            'link' => 'https://www.amazon.com/Sapiens-Humankind-Yuval-Noah-Harari/dp/0062316117/ref=sr_1_1?ie=UTF8&qid=1545650642&sr=8-1&keywords=sapiens',
            'category_id' => 1,
            "created_at" =>  date('Y-m-d H:i:s'),
            "updated_at" => date('Y-m-d H:i:s'),
        ],
    ]);
}
```

修改 `database/seeds/DatabaseSeeder.php` 檔。
```PHP
public function run()
{
    $this->call(CategoriesTableSeeder::class);
    $this->call(BooksTableSeeder::class);
}
```

執行填充。
```
$ php artisan db:seed
```

## 結構
修改 `routes/graphql/schema.graphql` 檔。
```JS
type Query {
    categories: [Category] @all
    category(id: ID @eq): Category @find

    books: [Book] @all
    book(id: ID @eq): Book @find
    booksByFeatured(featured: Boolean! @eq): [Book] @all
    booksQuery(q: String!): [Book]
}

type Mutation {
    createCategory(
        name: String @rules(apply: ["required", "unique:categories,name"])
    ): Category @create
    updateCategory(
        id: ID! @rules(apply: ["required", "unique:categories,name"])
        name: String
    ): Category @update
    deleteCategory(
        id: ID! @rules(apply: ["required"])
    ): Category @delete

    createBook(
        title: String! @rules(apply: ["required"])
        author: String! @rules(apply: ["required"])
        image: String
        link: String
        description: String
        featured: Boolean
        category: Int!
    ): Book @create
    updateBook(
        id: ID! @rules(apply: ["required"])
        title: String! @rules(apply: ["required"])
        author: String! @rules(apply: ["required"])
        image: String
        link: String
        description: String
        featured: Boolean
        category: Int!
    ): Book @update
    deleteBook(
        id: ID! @rules(apply: ["required"])
    ): Book @delete
}

type Category {
    id: ID!
    name: String!
    books: [Book] @hasMany
}

type Book {
    id: ID!
    title: String!
    author: String!
    image: String
    link: String
    description: String
    featured: String
    category: Category! @belongsTo
}
```

新增 `BooksQuery` 查詢類別。
```
$ php artisan lighthouse:query BooksQuery
```

修改 `app/Http/GraphQL/Queries/BooksQuery.php` 檔。
```PHP
namespace App\Http\GraphQL\Queries;

use App\Book;
use GraphQL\Type\Definition\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class BooksQuery
{
    /**
     * Return a value for the field.
     *
     * @param null $rootValue Usually contains the result returned from the parent field. In this case, it is always `null`.
     * @param array $args The arguments that were passed into the field.
     * @param GraphQLContext|null $context Arbitrary data that is shared between all fields of a single query.
     * @param ResolveInfo $resolveInfo Information about the query itself, such as the execution state, the field name, path to the field from the root, and more.
     *
     * @return mixed
     */
    public function resolve($rootValue, array $args, GraphQLContext $context = null, ResolveInfo $resolveInfo)
    {
        $books = Book::where(function($query) use ($args) {
            $query->orWhere('title', 'LIKE', '%'.$args['q'].'%');
            $query->orWhere('author', 'LIKE', '%'.$args['q'].'%');
        })->get();

        return $books;
    }
}
```

## 查詢與修改
對 `Book` 執行 `title` 欄位查詢。
```JS
query {
  booksQuery(q: "Jab") {
    title
    author
  }
}
```
對 `Book` 執行 `author` 欄位查詢。
```JS
query {
  booksQuery(q: "Gary") {
    title
    author
  }
}
```

對 `Category` 執行 `create` 修改。
```JS
mutation {
  createCategory(
    name: "New Category"
  ) {
    id
    name
  }
}
```

對 `Category` 執行 `update` 修改。
```JS
mutation {
  updateCategory(
    id: 7
    name: "New Category Update"
  ) {
    id
    name
  }
}
```

對 `Category` 執行 `delete` 修改。
```JS
mutation {
  deleteCategory(
    id: 7
  ) {
    id
    name
  }
}
```

對 `Book` 執行 `create` 修改。
```JS
mutation {
  createBook(
    title: "A New Book"
    author: "Some Author"
    category: 1
  ) {
    id
    title
  }
}
```

對 `Book` 執行 `update` 修改。
```JS
mutation {
  updateBook(
    id: 25
    title: "A New Book Update"
    author: "Some Author Update"
    category: 1
  ) {
    id
    title
  }
}
```

對 `Book` 執行 `delete` 修改。
```JS
mutation {
  deleteBook(
    id: 7
  ) {
    id
    title
  }
}
```