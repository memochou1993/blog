---
title: 在 Next 13.0 專案使用 Prisma 操作 MySQL 資料庫
date: 2023-10-31 16:29:38
tags: ["程式設計", "JavaScript", "React", "Next", "Prisma", "ORM", "MySQL"]
categories: ["程式設計", "JavaScript", "Next"]
---

## 建立專案

建立專案。

```bash
npx create-next-app@latest
cd prisma-next-example
```

安裝 Prisma 套件。

```bash
npm install prisma
```

使用 `prisma` 指令初始化。

```bash
npx prisma init
```

修改 `.env` 檔。

```env
DATABASE_URL=mysql://root:root@localhost:3306/example
```

修改 `.gitignore` 檔。

```text
.env
```

## 模型

修改 `schema.prisma` 檔。

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

model Post {
  id        Int     @id @default(autoincrement())
  title     String
  content   String?
  published Boolean @default(false)
  author    User    @relation(fields: [authorId], references: [id])
  authorId  Int
  @@map("posts")
}
```

執行資料表遷移。

```bash
npx prisma migrate dev --name init
```

## 路由

新增 `app/api/posts/route.js` 檔。

```js
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export async function GET() {
  const posts = await prisma.post.findMany()

  const res = {
    data: posts,
  };

  return Response.json(res)
}

export async function POST() {
  const post = await prisma.post.create({
    data: {
      title: 'Test',
      content: 'Hello',
    },
  })

  const res = {
    data: post,
  };

  return Response.json(res)
}
```

查詢記錄。

```bash
curl --request GET \
  --url http://localhost:3000/api/posts \
```

新增記錄。

```bash
curl --request POST \
  --url http://localhost:3000/api/posts
```

## 程式碼

- [prisma-next-example](https://github.com/memochou1993/prisma-next-example)

## 參考資料

- [Prisma](https://www.prisma.io/docs)
