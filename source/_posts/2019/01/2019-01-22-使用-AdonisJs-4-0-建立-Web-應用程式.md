---
title: 使用 AdonisJs 4.0 建立 Web 應用程式
permalink: 使用-AdonisJs-4-0-建立-Web-應用程式
date: 2019-01-22 00:36:06
tags: ["程式設計", "JavaScript", "Node", "AdonisJs"]
categories: ["程式設計", "JavaScript", "Node"]
---

## 前言

[Adonis](https://github.com/adonisjs/adonis-framework) 是 Node.js 框架中的 Laravel，使用起來幾乎一模一樣。

## 安裝

```BASH
npm i -g @adonisjs/cli
adonis --version
4.0.11
```

## 建立專案

建立專案。

```BASH
adonis new adonis
```

啟動伺服器。

```BASH
cd adonis
adonis serve --dev
```

## 環境變數

建立 `.env` 檔。

```BASH
cp .env.example .env
```

## 新增路由

在 `start/routes.js` 新增路由：

```JS
Route.get('/', () => 'Hello Adonis')
Route.resource('api/users', 'Api/UserController').apiOnly()
```

## 安裝 SQLite

```BASH
npm install --save sqlite3
```

## 新增遷移

新增 `timestamp_user` 遷移檔：

```BASH
adonis make:migration users
```

建立欄位：

```JS
'use strict'

const Schema = use('Schema')

class UsersSchema extends Schema {
  up () {
    this.create('users', (table) => {
      table.increments()
      table.string('username', 80).notNullable().unique()
      table.string('email', 254).notNullable().unique()
      table.string('password', 60).notNullable()
      table.timestamps()
    })
  }

  down () {
    this.drop('users')
  }
}

module.exports = UsersSchema
```

## 新增填充

新增 `UserSeeder` 資料填充。

```BASH
adonis make:seed User
```

設定種子數量：

```JS
'use strict'

/*
|--------------------------------------------------------------------------
| UserSeeder
|--------------------------------------------------------------------------
|
| Make use of the Factory instance to seed database with dummy data or
| make use of Lucid models directly.
|
*/

/** @type {import('@adonisjs/lucid/src/Factory')} */
const Factory = use('Factory')
const Database = use('Database')

class UserSeeder {
  async run () {
    await Factory.model('App/Models/User').createMany(10)
    const users = await Database.table('users')
    console.log(users)
  }
}

module.exports = UserSeeder
```

修改 `factory.js` 檔：

```JS
'use strict'

/*
|--------------------------------------------------------------------------
| Factory
|--------------------------------------------------------------------------
|
| Factories are used to define blueprints for database tables or Lucid
| models. Later you can use these blueprints to seed your database
| with dummy data.
|
*/

/** @type {import('@adonisjs/lucid/src/Factory')} */
const Factory = use('Factory')
const Hash = use('Hash')

Factory.blueprint('App/Models/User', async (faker) => {
  return {
    username: faker.username(),
    email: faker.email(),
    password: await Hash.make(faker.password())
  }
})
```

執行遷移。

```BASH
adonis migration:run
adonis seed
```

- Adonis 預設使用 SQLite 資料庫，檔案位置在 `database\adonis.sqlite`。

## 控制器

新增 `User` 控制器：

```BASH
adonis make:controller Api/User --resource
```

修改 `UserController.js` 檔：

```JS
'use strict'

const Database = use('Database')

class UserController {
  async show() {
    const users = await Database.table('users')
    return users
  }
}

module.exports = UserController
```

## 查看

前往：<http://127.0.0.1:3333/api/users>

## 程式碼

- [adonis-example](https://github.com/memochou1993/adonis-example)
