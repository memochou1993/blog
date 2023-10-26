---
title: 在 TypeScript 專案使用 Prisma 操作 SQLite 資料庫
date: 2023-10-24 15:05:14
tags: ["程式設計", "JavaScript", "TypeScript", "Prisma", "ORM", "SQLite"]
categories: ["程式設計", "JavaScript", "TypeScript"]
---

## 建立專案

建立專案。

```bash
mkdir hello-prisma 
cd hello-prisma
```

初始化 TypeScript 專案。

```bash
npm init -y
npm install typescript ts-node @types/node --save-dev
npx tsc --init 
```

安裝 Prisma 套件。

```bash
npm install prisma --save-dev
```

## 模型

使用以下指令在 `prisma` 資料夾生成 `schema.prisma` 檔，並指定資料庫。

```bash
npx prisma init --datasource-provider sqlite 
```

產生的 `schema.prisma` 檔如下：

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}
```

新增兩個模型，修改 `prisma/schema.prisma` 檔。

```prisma
// ...

model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String?
  posts Post[]
}

model Post {
  id        Int     @id @default(autoincrement())
  title     String
  content   String?
  published Boolean @default(false)
  author    User    @relation(fields: [authorId], references: [id])
  authorId  Int
}
```

執行資料表遷移。

```bash
npx prisma migrate dev --name init
```

## 存取資料庫

建立 `script.ts` 檔。

```ts
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // 撰寫查詢指令
}

main()
  .then(async () => {
    await prisma.$disconnect()
  })
  .catch(async (e) => {
    console.error(e)
    await prisma.$disconnect()
    process.exit(1)
  })
```

### 建立記錄

修改 `script.ts` 檔。

```ts
async function main() {
  const user = await prisma.user.create({
    data: {
      name: 'Alice',
      email: 'alice@prisma.io',
    },
  })
  console.log(user)
}
```

執行腳本。

```bash
npx ts-node script.ts
```

結果如下：

```js
{ id: 1, email: 'alice@prisma.io', name: 'Alice' }
```

### 讀取記錄

```ts
async function main() {
  const users = await prisma.user.findMany()
  console.log(users)
}
```

執行腳本。

```bash
npx ts-node script.ts
```

結果如下：

```js
[ { id: 1, email: 'alice@prisma.io', name: 'Alice' } ]
```

### 建立關聯記錄

修改 `script.ts` 檔。

```ts
async function main() {
  const user = await prisma.user.create({
    data: {
      name: 'Bob',
      email: 'bob@prisma.io',
      posts: {
        create: {
          title: 'Hello World',
        },
      },
    },
  })
  console.log(user)
}
```

執行腳本。

```bash
npx ts-node script.ts
```

結果如下：

```js
{ id: 2, email: 'bob@prisma.io', name: 'Bob' }
```

### 讀取關聯記錄

```ts
async function main() {
  const usersWithPosts = await prisma.user.findMany({
    include: {
      posts: true,
    },
  })
  console.dir(usersWithPosts, { depth: null })
}
```

執行腳本。

```bash
npx ts-node script.ts
```

結果如下：

```js
[
  { id: 1, email: 'alice@prisma.io', name: 'Alice', posts: [] },
  {
    id: 2,
    email: 'bob@prisma.io',
    name: 'Bob',
    posts: [
      {
        id: 1,
        title: 'Hello World',
        content: null,
        published: false,
        authorId: 2
      }
    ]
  }
]
```

## 使用者介面

啟動內建的 UI 工具。

```bash
npx prisma studio
```

## 程式碼

- [prisma-example](https://github.com/memochou1993/prisma-example)

## 參考資料

- [Prisma](https://www.prisma.io/docs)
