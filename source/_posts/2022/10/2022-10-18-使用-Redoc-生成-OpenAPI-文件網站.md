---
title: 使用 Redoc 生成 OpenAPI 文件網站
date: 2022-10-18 19:08:50
tags: ["Static Site Generator", "Redoc", "OpenAPI", "Swagger"]
categories: ["靜態網頁生成器", "Redoc"]
---

## 做法

安裝 Redoc CLI 工具。

```bash
npm i -g redoc-cli
```

新增 `openapi.yaml` 檔。

```YAML
openapi: 3.0.3

info:
  title: JSONPlaceholder
  description: Free fake API for testing and prototyping.
  version: 0.1.0

externalDocs:
  description: "JSONPlaceholder's guide"
  url: https://jsonplaceholder.typicode.com/guide

servers:
  - url: https://jsonplaceholder.typicode.com
    description: JSONPlaceholder

paths:
  "/posts":
    get:
      tags: ["posts"]
      summary: Returns all posts
      responses:
        "200":
          description: All went well
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/post"
    post:
      tags: ["posts"]
      summary: Create a new post
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/post"
        required: true
      responses:
        "200":
          description: A post was created
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/post"
  "/posts/{id}":
    parameters:
      - name: id
        in: path
        description: ID of the post
        required: true
        schema:
          type: string
    get:
      tags: ["post"]
      summary: Get a single post
      responses:
        "200":
          description: All went well
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/post"
        "404":
          description: Post not found
          content:
            application/json:
              schema:
                type: object
                properties: {}
    put:
      tags: ["post"]
      summary: Update a post
      requestBody:
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/post"
        required: true
      responses:
        "200":
          description: All went well
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/post"
        "404":
          description: Post not found
          content:
            application/json:
              schema:
                type: object
                properties: {}
    delete:
      tags: ["post"]
      summary: Delete a post
      responses:
        "200":
          description: All went well
          content:
            application/json:
              schema:
                type: object
                properties: {}
        "404":
          description: Post not found
          content:
            application/json:
              schema:
                type: object
                properties: {}

components:
  schemas:
    post:
      type: object
      properties:
        id:
          type: number
          description: ID of the post
        title:
          type: string
          description: Title of the post
        body:
          type: string
          description: Body of the post
        userId:
          type: number
          description: ID of the user who created the post
```

生成文件網站。

```bash
redoc-cli --output index.html build openapi.yaml
```

## 參考資料

- [Redoc - Docs](https://redocly.com/docs/redoc/deployment/cli/)
- [How to Create Documentation for Your REST API with Insomnia](https://www.digitalocean.com/community/tutorials/how-to-create-documentation-for-your-rest-api-with-insomnia#step-8-using-redoc-to-display-api-documentation)
