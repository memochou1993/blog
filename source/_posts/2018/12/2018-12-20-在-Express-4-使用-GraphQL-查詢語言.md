---
title: 在 Express 4 使用 GraphQL 查詢語言
date: 2018-12-20 13:33:06
tags: ["Programming", "JavaScript", "Express", "GraphQL"]
categories: ["Programming", "JavaScript", "Express"]
---

## 環境

- macOS

## 建立專案

建立專案。

```bash
mkdir graphql-express
npm install --save graphql express-graphql express
```

## 建立資料結構

新增 `GraphQLSchema.js` 檔：

```js
const { buildSchema } = require('graphql');

exports.schema = buildSchema(`
  type User {
    id: ID!
    name: String!
    posts: [Post!]!
  }

  type Post {
    id: ID!
    user: User!
    title: String!
  }

  type Query {
    users: [User!]!
    posts: [Post!]!
  }
`);

const users = {
  1: {
    id: 1,
    name: 'Memo Chou',
  },
};

const posts = {
  1: {
    id: 1,
    user_id: 1,
    title: 'Post 1',
  },
  2: {
    id: 2,
    user_id: 1,
    title: 'Post 2',
  },
};

class GraphQLUser {
  constructor({ id, name }) {
    this.id = id;
    this.name = name;
  }

  posts() {
    return Object.keys(posts)
      .map(id => new GraphQLPost(posts[id]))
      .filter(post => post.user_id === this.id);
  }
}

class GraphQLPost {
  constructor({ id, user_id, title }) {
    this.id = id;
    this.user_id = user_id;
    this.title = title;
  }

  user() {
    return new GraphQLUser(users[this.user_id]);
  }
}

exports.rootValue = {
  users: () => Object.keys(users).map(id => new GraphQLUser(users[id])),
  posts: () => Object.keys(posts).map(id => new GraphQLPost(posts[id])),
};
```

## 建立伺服

新增 `server.js` 檔：

```js
const express = require('express');
const graphqlHTTP = require('express-graphql');

const { schema, rootValue } = require('./GraphQLSchema');

const app = express();

app.use('/graphql', graphqlHTTP({
  schema: schema,
  rootValue: rootValue,
  graphiql: true,
}));

app.listen(3000);
```

## 啟動服務

```bash
node server.js
```

## 執行查詢

在 http://localhost:3000/graphql 執行查詢：

```
{
  users {
    name
    posts {
      title
      user {
        name
        posts {
          title
          user {
            id
            name
          }
        }
      }
    }
  }
}
```

得到結果：

```json
{
  "data": {
    "users": [
      {
        "name": "Memo Chou",
        "posts": [
          {
            "title": "Post 1",
            "user": {
              "name": "Memo Chou",
              "posts": [
                {
                  "title": "Post 1",
                  "user": {
                    "id": "1",
                    "name": "Memo Chou"
                  }
                },
                {
                  "title": "Post 2",
                  "user": {
                    "id": "1",
                    "name": "Memo Chou"
                  }
                }
              ]
            }
          },
          {
            "title": "Post 2",
            "user": {
              "name": "Memo Chou",
              "posts": [
                {
                  "title": "Post 1",
                  "user": {
                    "id": "1",
                    "name": "Memo Chou"
                  }
                },
                {
                  "title": "Post 2",
                  "user": {
                    "id": "1",
                    "name": "Memo Chou"
                  }
                }
              ]
            }
          }
        ]
      }
    ]
  }
}
```

## 參考資料

- [GraphQL 入門 Part I - 從 REST 到 GraphQL](https://ithelp.ithome.com.tw/articles/10188294)
