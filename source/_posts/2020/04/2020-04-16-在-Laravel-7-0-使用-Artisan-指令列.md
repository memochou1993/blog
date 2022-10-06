---
title: 在 Laravel 7.0 使用 Artisan 指令列
date: 2020-04-16 09:46:20
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 新增指令

以建立一個檔案為例，新增一條 `MakeFile` 指令。

```bash
php artisan make:command MakeFile
```

修改 `app/Console/Commands/MakeFile.php` 檔：

```php
namespace App\Console\Commands;

use Illuminate\Console\Command;

class MakeFile extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'make:file {name} {--text=}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Make a file';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $name = $this->argument('name');
        $text = $this->option('text');

        file_put_contents(storage_path($name), $text);
    }
}
```

## 參數

設定一個必填的參數：

```php
make:file {name}
```

設定一個選填的參數：

```php
make:file {name?}
```

設定一個選填帶有預設值的參數：

```php
make:file {name=example}
```

取得參數：

```php
$name = $this->argument('name');
```

取得所有的參數：

```php
$arguments = $this->arguments();
```

## 選項

設定一個布林的選項：

```php
--text
```

設定一個選填的選項：

```php
--text=
```

設定一個選填帶有預設值的選項：

```php
--text=example
```

取得選項：

```php
$text = $this->option('text');
```

取得所有的選項：

```php
$options = $this->options();
```

## 使用

```bash
php artisan make:file test.txt --text=example
```
