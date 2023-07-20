---
title: 在 Laravel 10.0 使用 Redocly CLI 整合 Swagger UI 文件工具
date: 2023-07-20 00:18:23
tags: ["程式設計", "PHP", "Laravel", "Swagger"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 建立專案

建立專案。

```bash
laravel new laravel-swagger-ui
cd laravel-swagger-ui
```

## 安裝 Swagger UI

手動從 Swagger UI 的 [GitHub](https://github.com/swagger-api/swagger-ui/releases) 下載原始碼。也可以使用以下指令下載，並解壓縮。

```bash
wget $(curl -s https://api.github.com/repos/swagger-api/swagger-ui/releases/latest | jq -r ".zipball_url") -O swagger-ui-latest.zip
unzip -d swagger-ui-latest swagger-ui-latest.zip
rm swagger-ui-latest.zip
```

將其中的 `dist` 資料夾，移動到專案的 `public/docs` 資料夾。

```bash
cp -r $(find swagger-ui-latest -type d -name "dist" -print -quit) public/docs
rm -rf swagger-ui-latest
```

修改 `index.html` 檔，修正靜態檔案引入的相對路徑。

```html
<!-- HTML for static distribution bundle build -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Swagger UI</title>
    <link rel="stylesheet" type="text/css" href="./swagger-ui.css" />
    <link rel="stylesheet" type="text/css" href="./index.css" />
    <link rel="icon" type="image/png" href="./favicon-32x32.png" sizes="32x32" />
    <link rel="icon" type="image/png" href="./favicon-16x16.png" sizes="16x16" />
  </head>

  <body>
    <div id="swagger-ui"></div>
    <script src="./swagger-ui-bundle.js" charset="UTF-8"> </script>
    <script src="./swagger-ui-standalone-preset.js" charset="UTF-8"> </script>
    <script src="./swagger-initializer.js" charset="UTF-8"> </script>
  </body>
</html>
```

修改 `swagger-initializer.js` 檔，修正 `url` 欄位。

```js
window.onload = function() {
  window.ui = SwaggerUIBundle({
    url: "./spec.json",
    // ...
  });
};
```

## 安裝 Redocly CLI

安裝依賴套件。

```bash
npm install @redocly/cli -D
```

修改 `package.json` 檔，建立一個腳本。

```json
{
    "scripts": {
        "build:docs": "redocly bundle docs/openapi.yaml --output public/docs/spec.json --ext json"
    }
}
```

## 建立文件

在專案根目錄建立 `docs/openapi.yaml` 檔。

```yaml
openapi: 3.0.3

info:
  title: JSONPlaceholder
  description: Free fake API for testing and prototyping.
  version: 0.1.0

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
```

編譯文件。

```bash
npm run build:docs
```

啟動專案。

```bash
php artisan serve
```

## 瀏覽文件

前往 <http://localhost:8000/docs> 瀏覽。

## 程式碼

- [laravel-swagger-ui](https://github.com/memochou1993/laravel-swagger-ui)

## 參考文件

- [swagger-api/swagger-ui](https://github.com/swagger-api/swagger-ui)
- [Redocly](https://redocly.com/docs/cli/commands/bundle/#json)
