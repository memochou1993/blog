---
title: 在 Laravel 6.0 使用 Task Scheduling 任務排程
permalink: 在-Laravel-6-0-使用-Task-Scheduling-任務排程
date: 2020-02-14 22:32:39
tags: ["程式設計", "PHP", "Laravel", "Cron"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 建立專案

建立專案。

```BASH
laravel new laravel
```

新增指令。

```BASH
php artisan make:command MakeFile
```

修改 `app/Console/Commands/MakeFile.php` 檔：

```PHP
namespace App\Console\Commands;

use Illuminate\Console\Command;

class MakeFile extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'make:file';

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
        file_put_contents(storage_path(now()), null);
    }
}
```

修改 `app/Console/Kernel.php` 檔，設置排程頻率：

```PHP
namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * The Artisan commands provided by your application.
     *
     * @var array
     */
    protected $commands = [
        //
    ];

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        $schedule->command('make:file')->everyMinute();
    }

    /**
     * Register the commands for the application.
     *
     * @return void
     */
    protected function commands()
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }
}
```

如果指定時間，需要設定時區：

```PHP
/**
 * Get the timezone that should be used by default for scheduled events.
 *
 * @return \DateTimeZone|string|null
 */
protected function scheduleTimezone()
{
    return 'Asia/Taipei';
}
```

## 設置排程

確認 Cron 的服務狀態。

```BASH
service cron status
```

新增（或修改、刪除）Cron 排程，執行以下指令：

```BASH
crontab -e
```

選擇編輯器並寫入排程，指令 `cd` 的參數為專案的絕對路徑。

```BASH
* * * * * cd /var/www/schedule && php artisan schedule:run >> /dev/null 2>&1
```

列出 Cron 排程，執行以下指令：

```BASH
crontab -l
```

檢查排程執行後，是否生成檔案。

```BASH
ll /var/www/schedule/storage/
-rw-r--r--  1 root root    0 Feb 14 15:29 2020-02-14 15:29:02
-rw-r--r--  1 root root    0 Feb 14 15:30 2020-02-14 15:30:02
```

若要刪除所有 Cron 排程，執行以下指令：

```BASH
crontab -r
```
