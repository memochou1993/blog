---
title: 在 Laravel 5.7 和 Vue 2.5 中使用 GraphQL 查詢語言
date: 2019-02-09 21:40:47
tags: ["Programming", "PHP", "Laravel", "GraphQL", "JavaScript", "Vue"]
categories: ["Programming", "PHP", "Laravel"]
---

## 前言

本文為「[GraphQL Laravel & Vue](https://www.youtube.com/watch?v=hvjW-MQEwIM&list=PLEhEHUEU3x5qsA5JnRzhgOghrH9Vqz4cg)」教學影片的學習筆記。

## 環境

- macOS

## 後端

### 建立後端專案

新增 Laravel 專案。

```bash
laravel new booksql-laravel
```

安裝 `nuwave/lighthouse` 套件。

```bash
composer require nuwave/lighthouse
```

發布資源。

```bash
php artisan vendor:publish --provider="Nuwave\Lighthouse\Providers\LighthouseServiceProvider" --tag=schema
php artisan vendor:publish --provider="Nuwave\Lighthouse\Providers\LighthouseServiceProvider" --tag=config
```

修改 `config/lighthouse.php` 檔中 `models` 指定的命名空間。

```php
'namespaces' => [
    'models' => 'App',
    'queries' => 'App\\Http\\GraphQL\\Queries',
    'mutations' => 'App\\Http\\GraphQL\\Mutations',
    'interfaces' => 'App\\Http\\GraphQL\\Interfaces',
    'unions' => 'App\\Http\\GraphQL\\Unions',
    'scalars' => 'App\\Http\\GraphQL\\Scalars',
],
```

### 使用範例

下載 `lighthouse-tutorial` 範例。

```bash
git clone https://github.com/nuwave/lighthouse-tutorial.git
cd lighthouse-tutorial
```

或在新專案安裝 `nuwave/lighthouse` 套件。

```bash
composer require nuwave/lighthouse
```

建立設定檔。

```bash
cp .env.example .env
```

生成金鑰。

```bash
php artisan key:generate
```

安裝相依套件。

```bash
composer install
```

執行遷移。

```bash
php artisan migrate
```

新增填充。

```bash
php artisan tinker
>>> factory('App\Comment', 20)->create()
```

啟動伺服器。

```bash
php artisan serve
```

前往 <http://127.0.0.1:8000> 瀏覽。

### 跨域資源共享

安裝 `laravel-cors` 套件。

```bash
composer require barryvdh/laravel-cors
```

修改 `config/lighthouse.php` 檔：

```php
'route' => [
    'prefix' => '',
    'middleware' => [
        \Barryvdh\Cors\HandleCors::class,
    ]
],
```

### 安裝開發工具

安裝 GraphQL Playground 開發工具。

```bash
brew cask install graphql-playground
```

輸入網址：<http://127.0.0.1:8000/graphql>

或安裝 Laravel GraphQL Playground 網頁開發工具。

```bash
composer require --dev mll-lab/laravel-graphql-playground
```

前往 <http://127.0.0.1:8000/graphql-playground> 瀏覽。

### 架構

查看 `routes/graphql/schema.graphql` 檔。

```js
"""This is a custom built-in Scalar type from LightHouse. It handles Carbon dates"""
scalar DateTime @scalar(class: "Nuwave\\Lighthouse\\Schema\\Types\\Scalars\\DateTime")

type User {
    id: ID!
    name: String!
    email: String!
    created_at: DateTime!
    updated_at: DateTime!
    posts: [Post] @hasMany
}

type Post {
    id: ID!
    title: String!
    content: String!
    user: User! @belongsTo
    comments: [Comment] @hasMany
}

type Comment {
    id: ID!
    reply: String!
    post: Post! @belongsTo
}

type Query {
    users: [User] @all
    user(id: Int! @eq): User @find
    posts: [Post] @all
    post(id: Int! @eq): Post @find
}
```

執行查詢。

```js
query {
  post(id: 1) {
    title
    user {
      name
      email
    }
    comments {
      reply
    }
  }
}
```

新增修改。

```js
type Mutation {
    createUser(
        name: String! @rules(apply: ["required", "min:4"]),
        email: String! @rules(apply: ["email", "unique:users"]),
        password: String! @bcrypt,
    ): User! @create
}
```

執行修改。

```js
mutation {
  createUser(
    name:"Test",
    email:"test@gmail.com",
    password: "secret",
  ) {
    id
    name
  }
}
```

### 新增查詢類別

新增一個查詢類別。

```bash
php artisan lighthouse:query LatestPost
```

修改 `app/Http/GraphQL/Queries/LatestPost.php` 檔：

```php
namespace App\Http\GraphQL\Queries;

use App\Post;
use GraphQL\Type\Definition\ResolveInfo;
use Nuwave\Lighthouse\Support\Contracts\GraphQLContext;

class LatestPost
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
        return Post::all()->last();
    }
}
```

修改 `routes/graphql/schema.graphql` 檔：

```js
type Query {
    latestPost: Post
}
```

執行查詢。

```js
query {
  latestPost {
    title
  }
}
```

## 前端

### 建立前端專案

```bash
vue create vue-apollo
```

安裝套件。

```bash
cd vue-apollo
vue add apollo
```

啟動伺服器。

```bash
npm run serve
```

前往 <http://localhost:8080> 瀏覽。

### 設定

修改 `src/vue-apollo.js` 檔：

```js
const httpEndpoint = process.env.VUE_APP_GRAPHQL_HTTP || 'http://localhost:8000/graphql';
```

執行查詢。

```js
import gql from 'graphql-tag';

export default {
  data() {
    return {
      users: [],
      user: '',
    };
  },
  apollo: {
    users: gql`{
      users {
        name
        email
      }
    }`,
  },
};
```

執行修改。

```js
methods: {
  createUser() {
    this.$apollo.mutate({
      mutation: gql`mutation {
        createUser(
          name:"Test2",
          email:"test2@gmail.com",
          password: "secret",
        ) {
          id
          name
        }
      }`,
    });
  },
},
```
