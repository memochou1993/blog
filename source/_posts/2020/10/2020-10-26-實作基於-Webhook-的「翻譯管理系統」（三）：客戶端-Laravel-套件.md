---
title: 實作基於 Webhook 的「翻譯管理系統」（三）：客戶端 Laravel 套件
permalink: 實作基於-Webhook-的「翻譯管理系統」（三）：客戶端-Laravel-套件
date: 2020-10-26 14:09:48
tags: ["程式設計", "PHP", "Laravel", "Localization", "Lexicon", "套件開發"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

此套件的目的是封裝 Lexicon 客戶端 PHP 套件，使客戶端可以接收來自服務端的通知，也可以透過 Laravel 的 Artisan 指令獲取資源，並且生成語系檔。

## 服務提供者

在 `LexiconServiceProvider` 服務提供者中，定義了可以被發布的資源，以及需要綁定的類別。

```PHP
namespace MemoChou1993\Lexicon\Providers;

use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;
use MemoChou1993\Lexicon\Client;
use MemoChou1993\Lexicon\Console\ClearCommand;
use MemoChou1993\Lexicon\Console\SyncCommand;
use MemoChou1993\Lexicon\Lexicon;

class LexiconServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register()
    {
        $this->mergeConfigFrom(
            __DIR__.'/../../config/lexicon.php',
            'lexicon'
        );

        $this->app->singleton(Client::class, function() {
            return new Client([
                'host' => config('lexicon.host'),
                'api_key' => config('lexicon.api_key'),
            ]);
        });

        $this->app->singleton('lexicon', function() {
            return new Lexicon(app(Client::class));
        });

        $this->app->register(EventServiceProvider::class);
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        if (! defined('CONFIG_SEPARATOR')) {
            define('CONFIG_SEPARATOR', '.');
        }

        $this->publishes([
            __DIR__.'/../../config/lexicon.php' => config_path('lexicon.php'),
        ]);

        if ($this->app->runningInConsole()) {
            $this->commands([
                SyncCommand::class,
                ClearCommand::class,
            ]);
        }

        Route::group([
            'prefix' => '/api/'.config('lexicon.path'),
            'middleware' => config('lexicon.middleware', []),
        ], function () {
            $this->loadRoutesFrom(__DIR__.'/../Http/routes.php');
        });
    }
}
```

在 `EventServiceProvider` 服務提供者中，定義了註冊的事件。

```PHP
namespace MemoChou1993\Lexicon\Providers;

use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use MemoChou1993\Lexicon\Listeners\Sync;

class EventServiceProvider extends ServiceProvider
{
    /**
     * The event listener mappings for the application.
     *
     * @var array
     */
    protected $listen = [
        'sync' => [
            Sync::class,
        ],
    ];

    /**
     * Register any events for your application.
     *
     * @return void
     */
    public function boot()
    {
        parent::boot();
    }
}
```

## 核心

在 `Lexicon` 類別中，定義了最重要的兩個方法，分別是 `export()` 和 `clear()` 方法。`export()` 方法將獲取的資料整理成特定格式，並輸出成 Laravel 能夠使用的 PHP 語系檔，而 `clear()` 方法則是將舊有的 Lexicon 語系檔刪除。

```PHP
namespace MemoChou1993\Lexicon;

use GuzzleHttp\Exception\GuzzleException;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\File;
use Symfony\Component\VarExporter\Exception\ExceptionInterface;
use Symfony\Component\VarExporter\VarExporter;

class Lexicon
{
    /**
     * @var Client
     */
    private Client $client;

    /**
     * @var array
     */
    protected array $project;

    /**
     * @var Collection|null
     */
    protected ?Collection $expectedLanguages = null;

    /**
     * @param Client $client
     */
    public function __construct(Client $client)
    {
        $this->client = $client;
    }

    /**
     * @return string
     */
    protected function filename(): string
    {
        return config('lexicon.filename');
    }

    /**
     * @param array $project
     * @return void
     */
    protected function setProject($project): void
    {
        $this->project = $project;
    }

    /**
     * @return array
     */
    protected function getProject(): array
    {
        return $this->project ?? $this->fetchProject();
    }

    /**
     * @return Collection
     */
    protected function getKeys(): Collection
    {
        return collect($this->getProject()['keys']);
    }

    /**
     * @return Collection
     */
    public function getLanguages(): Collection
    {
        return collect($this->getProject()['languages'])->pluck('name');
    }

    /**
     * @return Collection
     */
    protected function getExpectedLanguages(): Collection
    {
        return collect($this->expectedLanguages)->whenEmpty(function () {
            return $this->getLanguages();
        });
    }

    /**
     * @param mixed $language
     * @return bool
     */
    public function hasLanguage($language): bool
    {
        return $this->getLanguages()->contains($language);
    }

    /**
     * @return array|void
     */
    protected function fetchProject()
    {
        try {
            $response = $this->client->fetchProject();

            $data = json_decode($response->getBody()->getContents(), true)['data'];

            $this->setProject($data);

            return $data;
        } catch (GuzzleException $e) {
            abort($e->getCode(), $e->getMessage());
        }
    }

    /**
     * @param string $language
     * @return array
     */
    protected function formatKeys(string $language): array
    {
        return $this->getKeys()
            ->mapWithKeys(function ($key) use ($language) {
                return [
                    $key['name'] => $this->formatValues($key['values'], $language),
                ];
            })
            ->toArray();
    }

    /**
     * @param array $values
     * @param string $language
     * @return string
     */
    protected function formatValues(array $values, string $language): string
    {
        return collect($values)
            ->filter(function ($value) use ($language) {
                return $value['language']['name'] === $language;
            })
            ->map(function ($value) {
                return vsprintf('[%s,%s]%s', [
                    $value['form']['range_min'],
                    $value['form']['range_max'],
                    $value['text'],
                ]);
            })
            ->implode('|');
    }

    /**
     * @param array|string $languages
     * @return self
     */
    public function only(...$languages): self
    {
        $this->expectedLanguages = collect($languages)
            ->flatten()
            ->intersect($this->getLanguages());

        return $this;
    }

    /**
     * @param array|string $languages
     * @return self
     */
    public function except(...$languages): self
    {
        $this->expectedLanguages = $this->getLanguages()
            ->diff(collect($languages)->flatten());

        return $this;
    }

    /**
     * @return void
     */
    public function export(): void
    {
        $this->getExpectedLanguages()
            ->each(function ($language) {
                $this->save($language);
            });
    }

    /**
     * @param string $language
     * @return void
     * @throws ExceptionInterface
     */
    protected function save(string $language): void
    {
        $keys = $this->formatKeys($language);

        $data = vsprintf('%s%s%s%s%s%s%s', [
            '<?php',
            PHP_EOL,
            PHP_EOL,
            'return ',
            VarExporter::export($keys),
            ';',
            PHP_EOL,
        ]);

        $directory = lang_path($language);

        File::ensureDirectoryExists($directory);

        $path = sprintf('%s/%s.php', $directory, $this->filename());

        File::put($path, $data);
    }

    /**
     * @return self
     */
    public function clear(): self
    {
        $directories = File::directories(lang_path());

        collect($directories)
            ->filter(function ($directory) {
                return $this->hasLanguage(basename($directory));
            })
            ->each(function ($directory) {
                $path = sprintf('%s/%s.php', $directory, $this->filename());

                File::delete($path);

                return $directory;
            })
            ->reject(function ($directory) {
                return count(File::allFiles($directory)) > 0;
            })
            ->each(function ($directory) {
                File::deleteDirectory($directory);
            });

        return $this;
    }

    /**
     * @param string|null $key
     * @param int $number
     * @param array $replace
     * @param null $locale
     * @return string
     */
    public function trans($key = null, $number = 0, array $replace = [], $locale = null): string
    {
        if (is_null($key)) {
            return '';
        }

        $key = $this->filename().CONFIG_SEPARATOR.$key;

        return trans_choice($key, $number, $replace, $locale);
    }
}
```

## 控制器

在 `DispatchController` 控制器中，負責接收來自服務端的請求，並且派發所有事件。

```PHP
namespace MemoChou1993\Lexicon\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use Illuminate\Support\Facades\Event;
use Symfony\Component\HttpFoundation\Response;

class DispatchController extends Controller
{
    /**
     * The events for the application.
     *
     * @var array
     */
    protected array $events = [
        'sync',
    ];

    /**
     * Receive and dispatch events.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function __invoke(Request $request)
    {
        collect($request->input('events'))
            ->intersect($this->events)
            ->each(fn($event) => Event::dispatch($event));

        return response()->json(null, Response::HTTP_ACCEPTED);
    }
}
```

## 事件

在 `Sync.php` 檔中，定義了一個同步事件，此同步事件會將原先舊的語系檔刪除，再重新輸出一次。

```PHP
namespace MemoChou1993\Lexicon\Listeners;

use MemoChou1993\Lexicon\Facades\Lexicon;

class Sync
{
    /**
     * Create the event listener.
     *
     * @return void
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     *
     * @return void
     */
    public function handle()
    {
        Lexicon::clear()->export();
    }
}
```

## 指令

在 `SyncCommand` 類別中，使用了 `Lexicon::export()` 方法，用來生成語系檔。

```PHP
namespace MemoChou1993\Lexicon\Console;

use Illuminate\Console\Command;
use MemoChou1993\Lexicon\Facades\Lexicon;
use Symfony\Component\HttpKernel\Exception\HttpException;

class SyncCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'lexicon:sync';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Sync language files';

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
     * @return int
     */
    public function handle()
    {
        try {
            Lexicon::export();
        } catch (HttpException $e) {
            $this->error($e->getMessage());

            return 0;
        }

        return 1;
    }
}
```

在 `ClearCommand` 類別中，使用了 `Lexicon::clear()` 方法，用來清除語系檔。

```PHP
namespace MemoChou1993\Lexicon\Console;

use Illuminate\Console\Command;
use MemoChou1993\Lexicon\Facades\Lexicon;
use Symfony\Component\HttpKernel\Exception\HttpException;

class ClearCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'lexicon:clear';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clear language files';

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
     * @return int
     */
    public function handle()
    {
        try {
            Lexicon::clear();
        } catch (HttpException $e) {
            $this->error($e->getMessage());

            return 0;
        }

        return 1;
    }
}
```

## 使用

安裝套件。

```PHP
composer require memochou1993/lexicon-api-laravel-client
```

修改 `.env` 檔，設置 Lexicon 服務端的網址，以及向服務端存取資源的 API 金鑰。

```ENV
LEXICON_HOST=
LEXICON_API_KEY=
```

如果要獲取服務端的語系資源，並生成本地的語系檔，執行以下指令。

```BASH
php artisan lexicon:sync
```

如果要清除本地的語系檔，執行以下指令。

```BASH
php artisan lexicon:clear
```

## 程式碼

- [lexicon-api-laravel-client](https://github.com/memochou1993/lexicon-api-laravel-client)
