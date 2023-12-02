---
title: 在 Laravel 10.0 使用 pgvector 向量搜尋操作 PostgreSQL 資料庫
date: 2023-12-02 18:37:47
tags: ["Programming", "PHP", "Laravel", "PostgreSQL", "Database", "Vector", "Embedding"]
categories: ["Programming", "PHP", "Laravel"]
---

## 建立專案

建立專案。

```bash
laravel new pgvector-laravel
```

建立資料庫。

```bash
docker run -it -d --name pgvector -v pgvector-data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=password -e POSTGRES_USER=forge --publish 5432:5432 ankane/pgvector
```

安裝套件。

```bash
composer require ankane/pgvector
```

發布相關資源。

```
php artisan vendor:publish --tag="pgvector-migrations"
```

修改 `.env` 檔。

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=forge
DB_USERNAME=forge
DB_PASSWORD=password
```

執行遷移。

```bash
php artisan migrate
```

## 建立模型

建立一個 `Embedding` 模型。

```bash
php artisan make:model Embedding -m
```

修改 `database/migrations/..._create_embeddings_table.php` 檔。

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('embeddings', function (Blueprint $table) {
            $table->id();
            $table->vector('embedding', 1536); // dimensionality; 1536 for OpenAI's ada-002
            $table->json('metadata');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('embeddings');
    }
};
```

修改 `app/Models/Embedding.php` 檔。

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Pgvector\Laravel\Vector;

class Embedding extends Model
{
    use HasFactory;

    protected $fillable = [
        'embedding',
        'metadata',
    ];

    protected $casts = [
        'embedding' => Vector::class,
        'metadata' => 'array',
    ];
}
```

執行遷移。

```bash
php artisan migrate
```

## 建立範例指令

安裝 OpenAI SDK 套件。

```bash
composer require openai-php/laravel
php artisan vendor:publish --provider="OpenAI\Laravel\ServiceProvider"
```

修改 `.env` 檔，添加 OpenAI 的 API Key。

```env
OPENAI_API_KEY=sk-...
```

### 建立資料

修改 `routes/console.php` 檔，建立 `insert` 範例指令。

```php
<?php

use App\Models\Embedding;
use Illuminate\Support\Facades\Artisan;
use OpenAI\Laravel\Facades\OpenAI;

Artisan::command('insert', function() {
    $sayings = [
        'Felines say meow',
        'Canines say woof',
        'Birds say tweet',
        'Humans say hello',
    ];

    $result = OpenAI::embeddings()->create([
        'model' => 'text-embedding-ada-002',
        'input' => $sayings
    ]);

    foreach ($sayings as $key=>$saying) {
        Embedding::query()->create([
            'embedding' => $result->embeddings[$key]->embedding,
            'metadata' => [
                'saying' => $saying,
            ]
        ]);
    }
});
```

執行 `insert` 指令。

```bash
php artisan insert
```

檢查紀錄。

```
docker exec -it \
    pgvector \
    psql -U forge -d forge -c "select count(*) from embeddings"

count
-------
     4
(1 row)
```

### 查詢資料

修改 `routes/console.php` 檔，建立 `search` 範例指令。

```php
<?php

use App\Models\Embedding;
use Illuminate\Support\Facades\Artisan;
use OpenAI\Laravel\Facades\OpenAI;
use Pgvector\Laravel\Vector;

// ...

Artisan::command('search', function() {
    $result = OpenAI::embeddings()->create([
        'model' => 'text-embedding-ada-002',
        'input' => 'What do dogs say?',
    ]);

    $embedding = new Vector($result->embeddings[0]->embedding);

    $this->table(
        ['saying'],
        Embedding::query()
            ->orderByRaw('embedding <-> ?', [$embedding])
            ->take(2)
            ->pluck('metadata')
    );
});
```

執行 `search` 指令。

```bash
php artisan search

+------------------+
| saying           |
+------------------+
| Canines say woof |
| Felines say meow |
+------------------+
```

## 程式碼

- [pgvector-laravel](https://github.com/memochou1993/pgvector-laravel)

## 參考資料

- [Using pgvector embeddings search in Laravel](https://aiwithlaravel.com/p/laravel-pgvector-embeddings)
