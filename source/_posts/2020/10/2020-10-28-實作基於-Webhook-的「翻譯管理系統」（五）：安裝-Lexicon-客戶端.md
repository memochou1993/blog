---
title: 實作基於 Webhook 的「翻譯管理系統」（五）：安裝 Lexicon 客戶端
date: 2020-10-28 22:39:03
tags: ["Programming", "PHP", "Laravel", "Localization", "Lexicon"]
categories: ["Programming", "PHP", "Laravel"]
---

## 本文

本文介紹如何使用 Lexicon 客戶端套件，獲取 Lexicon 服務端的語系資源，並生成 Laravel 使用的語系檔，最終實現網站的在地化（localization）。

## 環境

- Ubuntu 18.04.1 LTS
- PHP 7.4
- Laradock

## 建立專案

建立一個新的專案。

```bash
laravel new lexicon-domo
```

## 安裝套件

安裝 Lexicon 的客戶端套件。

```php
composer require memochou1993/lexicon-api-laravel-client
```

## 環境變數

修改 `.env` 檔，設置 Lexicon 服務端的網址，以及向服務端存取資源的 API 金鑰。

```env
LEXICON_HOST=https://lexicon.epoch.tw
LEXICON_API_KEY=<API_TOKEN>
```

## 指令

修改 `app/Console/Kernel.php` 檔，以註冊 Lexicon 客戶端的指令。

```php
use MemoChou1993\Lexicon\Console\ClearCommand;
use MemoChou1993\Lexicon\Console\SyncCommand;

class Kernel extends ConsoleKernel
{
    protected $commands = [
        ClearCommand::class,
        SyncCommand::class,
    ];
}
```

如果要獲取服務端的語系資源，並生成本地的語系檔，執行以下指令。

```bash
php artisan lexicon:sync
```

如果要清除本地的語系檔，執行以下指令。

```bash
php artisan lexicon:clear
```

## 控制器

新增一個 `DemoController` 控制器。

```bash
php artisan make:controller DemoController
```

修改 `DemoController` 控制器。

```php
namespace App\Http\Controllers;

use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Artisan;
use MemoChou1993\Lexicon\Console\ClearCommand;
use MemoChou1993\Lexicon\Console\SyncCommand;

class DemoController extends Controller
{
    /**
     * Handle the incoming request.
     *
     * @param  Request  $request
     * @param  string  $language
     * @return RedirectResponse|View
     */
    public function __invoke(Request $request, string $language = 'en')
    {
        // 限定語言
        if (! in_array($language, ['en', 'zh'])) {
            return redirect()->route('demo');
        }

        // 設置系統語言
        App::setLocale($language);

        // 同步語系檔
        if ($request->input('sync')) {
            Artisan::call(SyncCommand::class);

            return redirect()->route('demo', ['language' => $language]);
        }

        // 清除語系檔
        if ($request->input('clear')) {
            Artisan::call(ClearCommand::class);

            return redirect()->route('demo', ['language' => $language]);
        }

        $file = sprintf('%s/%s.php', lang_path($language), config('lexicon.filename'));

        $keys = [];

        if (file_exists($file)) {
            $keys = include $file;

            // 傾印語系檔
            if ($request->input('dump')) {
                dd(file_get_contents($file));
            }
        }

        return view('demo', [
            'language' => $language,
            'keys' => $keys,
        ]);
    }
}
```

## 路由

新增一個路由。

```php
use App\Http\Controllers\DemoController;

Route::get('/{language?}', DemoController::class)->name('demo');
```

## 視圖

在 `resources/views` 資料夾新增 `demo.blade.php` 檔。

```html
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>{{ ___('project.name') }}</title>
        <link rel="icon" href="icon.png">
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    </head>
    <body>
        <nav class="navbar navbar-dark bg-dark">
            <a class="navbar-brand" href="{{ config('app.url') }}/{{ $language }}">
                {{ ___('project.name') }}
            </a>
            <div>
                @if($language == 'en')
                <button onclick="location.href='/en'" class="btn btn-sm bg-light ml-1">
                    EN
                </button>
                <button onclick="location.href='/zh'" class="btn btn-sm btn-outline-light ml-1">
                    ZH
                </button>
                @endif
                @if($language == 'zh')
                <button onclick="location.href='/en'" class="btn btn-sm btn-outline-light ml-1">
                    EN
                </button>
                <button onclick="location.href='/zh'" class="btn btn-sm bg-light ml-1">
                    ZH
                </button>
                @endif
            </div>
        </nav>
        <div class="container mb-5">
            <div class="mt-4">
                <div class="card bg-light">
                    <div class="card-body">
                        <span class="mr-2">
                            <button onclick="location.href='/{{ $language  }}?sync=true'" class="btn btn-sm btn-info my-1 my-md-0" id="sync">
                                {{ ___('action.sync') }}
                            </button>
                        </span>
                        <span class="mr-2">
                            <button onclick="location.href='/{{ $language  }}?clear=true'" class="btn btn-sm btn-danger my-1 my-md-0" id="clear">
                                {{ ___('action.clear') }}
                            </button>
                        </span>
                        @if(count($keys))
                        <span class="mr-2">
                            <button onclick="window.open('/{{ $language  }}?dump=true')" class="btn btn-sm btn-secondary my-1 my-md-0">
                                {{ ___('action.dump') }}
                            </button>
                        </span>
                        @endif
                    </div>
                </div>
            </div>
            <div class="my-4" id="table">
                @if(count($keys))
                <table class="table table-bordered table-responsive-sm bg-light">
                    <thead>
                        <tr class="text-center">
                            <th>{{ ___('table.header.code_in_blade_template') }}</th>
                            <th>{{ ___('table.header.translation') }}</th>
                            <th>{{ ___('table.header.code_in_language_file') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($keys as $key => $value)
                            @if($language == 'en')
                            <tr>
                                <td>
                                    ___('{{ $key }}')
                                </td>
                                <td>
                                    {{ ___($key) }}
                                </td>
                                <td rowspan="2">
                                    '{{ $key }}' => '{{ $value }}',
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    ___('{{ $key }}', 2)
                                </td>
                                <td>
                                    {{ ___($key, 2) }}
                                </td>
                            </tr>
                            @endif
                            @if($language == 'zh')
                            <tr>
                                <td>
                                    ___('{{ $key }}')
                                </td>
                                <td>
                                    {{ ___($key) }}
                                </td>
                                <td>
                                    '{{ $key }}' => '{{ $value }}',
                                </td>
                            </tr>
                            @endif
                        @endforeach
                    </tbody>
                </table>
                @endif
            </div>
            <div class="my-5 text-center" id="loading" hidden>
                <h5 class="py-5" id="message"></h5>
                <div style="width: 4rem; height: 4rem;" class="spinner-grow text-warning" role="status">
                    <span class="sr-only">Loading...</span>
                </div>
            </div>
        </div>
    </body>
</html>

<script>
document.getElementById('sync').addEventListener('click', () => {
    document.getElementById('table').hidden = true;
    document.getElementById('loading').hidden = false;
    document.getElementById('message').innerHTML = 'Generating language files...';
});

document.getElementById('clear').addEventListener('click', () => {
    document.getElementById('table').hidden = true;
    document.getElementById('loading').hidden = false;
    document.getElementById('message').innerHTML = 'Deleting language files...';
});
</script>

<style>
body {
    font-family: 'Microsoft Jhenghei', sans-serif;
    font-size: 0.75rem;
}

#table > table {
    table-layout: fixed;
}

#table > table > tbody > tr > td {
    vertical-align: middle;
}
</style>
```

## 權限

由於 Lexicon 客戶端套件會將語系檔存放至 `resources/lang` 資料夾中，因此還需要修改資料夾的權限。

```bash
chown laradock:www-data -R resources/lang
```

## 線上展示

- [Lexicon Demo](https://lexicon-demo.epoch.tw)

## 程式碼

- [lexicon-demo](https://github.com/memochou1993/lexicon-demo)
