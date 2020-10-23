---
title: 實作「雙向溝通的翻譯管理系統」（四）：安裝 Lexicon 客戶端
permalink: 實作「雙向溝通的翻譯管理系統」（四）：安裝-Lexicon-客戶端
date: 2020-10-23 22:39:03
tags:
categories:
---

## 本文

本文介紹如何透過 Lexicon 客戶端提供的 Artisan 指令，獲取 Lexicon 服務端的語系資源，並生成 Laravel 使用的語言檔案，再透過套件所提供的 `___()` 輔助函式，實現網站的在地化（localization）。

## 建立專案

建立一個新的專案。

```BASH
laravel new lexicon-domo
```

## 安裝套件

安裝 Lexicon 的客戶端套件。

```PHP
composer require memochou1993/lexicon-api-client-laravel
```

## 環境變數

修改 `.env` 檔，加上 Lexicon 服務端的網址，以及 API 密鑰。

```ENV
LEXICON_HOST=https://lexicon.epoch.tw
LEXICON_API_KEY=
```

## 指令

修改 `app/Console/Kernel.php` 檔，以註冊 Lexicon 客戶端的指令。

```PHP
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

如果要獲取服務端的語系資源，並生成本地的語言檔案，執行以下指令。

```BASH
php artisan lexicon:sync
```

如果要清除本地的語言檔案，執行以下指令。

```BASH
php artisan lexicon:clear
```

## 控制器

新增一個 `DemoController` 控制器。

```BASH
php artisan make:controller DemoController
```

修改 `DemoController` 控制器。

```PHP
namespace App\Http\Controllers;

use Illuminate\Contracts\View\View;
use Illuminate\Http\Request;
use Illuminate\Routing\Redirector;
use Illuminate\Support\Facades\Artisan;
use MemoChou1993\Lexicon\Console\ClearCommand;
use MemoChou1993\Lexicon\Console\SyncCommand;

class DemoController extends Controller
{
    /**
     * Handle the incoming request.
     *
     * @param  Request  $request
     * @return Redirector|View
     */
    public function __invoke(Request $request)
    {
        // 網站語言
        $language = $request->input('language', 'en');

        // 限定語言
        if (! in_array($language, ['en', 'zh'])) {
            return redirect()->route('demo');
        }

        // 如果接收到 sync 請求，執行 SyncCommand 指令
        if ($request->input('sync')) {
            Artisan::call(SyncCommand::class);

            return redirect()->route('demo', ['language' => $language]);
        }

        // 如果接收到 clear 請求，執行 ClearCommand 指令
        if ($request->input('clear')) {
            Artisan::call(ClearCommand::class);

            return redirect()->route('demo', ['language' => $language]);
        }

        // 語言檔案的內容
        $file = sprintf('%s/%s.php', lang_path($language), config('lexicon.filename'));

        $keys = [];

        // 判斷語言檔案是否存在
        if (file_exists($file)) {
            // 讀取語言檔案的所有內容
            $keys = include $file;

            // 如果接收到 dump 請求，傾印語言檔案
            if ($request->input('dump')) {
                dd(file_get_contents($file));
            }
        }

        // 呈現網頁
        return view('demo', [
            'language' => $language,
            'keys' => $keys,
        ]);
    }
}
```

## 路由

新增一個路由。

```PHP
use App\Http\Controllers\DemoController;

Route::get('/', DemoController::class)->name('demo');
```

## 視圖

在 `resources/views` 資料夾新增 `demo.blade.php` 檔。

```HTML
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
            <a class="navbar-brand" href="demo">
                {{ ___('project.name') }}
            </a>
            <div>
                @if($language == 'en')
                <button onclick="javascript:location.href='?language=zh'" class="btn btn-sm btn-outline-light">
                    ZH
                </button>
                <button onclick="javascript:location.href='?language=en'" class="btn btn-sm bg-light">
                    EN
                </button>
                @endif
                @if($language == 'zh')
                <button onclick="javascript:location.href='?language=zh'" class="btn btn-sm bg-light">
                    ZH
                </button>
                <button onclick="javascript:location.href='?language=en'" class="btn btn-sm btn-outline-light">
                    EN
                </button>
                @endif
            </div>
        </nav>
        <div class="container mb-5">
            <div class="mt-4">
                <div class="card bg-light">
                    <div class="card-body">
                        <span class="mr-2">
                            <button onclick="javascript:location.href='?language={{ $language  }}&sync=true'" class="btn btn-sm btn-info my-1 my-md-0" id="sync">
                                {{ ___('action.sync') }}
                            </button>
                        </span>
                        <span class="mr-2">
                            <button onclick="javascript:location.href='?language={{ $language  }}&clear=true'" class="btn btn-sm btn-danger my-1 my-md-0" id="clear">
                                {{ ___('action.clear') }}
                            </button>
                        </span>
                        @if(count($keys))
                        <span class="mr-2">
                            <button onclick="javascript:window.open('?language={{ $language  }}&dump=true')" class="btn btn-sm btn-secondary my-1 my-md-0">
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
    setTimeout(() => {
        document.getElementById('message').innerHTML = 'Fetching Resources...';
    }, 0);
    setTimeout(() => {
        document.getElementById('message').innerHTML = 'Generating Language Files...';
    }, 1000);
});

document.getElementById('clear').addEventListener('click', () => {
    document.getElementById('table').hidden = true;
    document.getElementById('loading').hidden = false;
    setTimeout(() => {
        document.getElementById('message').innerHTML = 'Deleting Language Files...';
    }, 0);
});
</script>

<style>
body {
    font-family: 'Microsoft Jhenghei';
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

## 範例

前往：<https://lexicon-demo.epoch.tw>

## 程式碼

- [lexicon-demo](https://github.com/memochou1993/lexicon-demo)
