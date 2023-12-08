---
title: 在 PHP 專案使用 OpenCC 開放中文轉換
date: 2023-11-30 01:19:28
tags: ["Programming", "PHP", "OpenCC"]
categories: ["Programming", "PHP", "Extension"]
---

## 安裝

安裝指令。

```bash
brew install opencc
```

下載專案。

```bash
git clone https://github.com/BYVoid/OpenCC.git
```

查看字典檔。

```bash
ls /usr/local/share/opencc/
```

使用指令轉換。

```bash
echo "简体中文" | opencc -c s2twp.json
```

## 實作

建立轉換函式。

```php
<?php

function s2t($text)
{
    $configFile = '/usr/local/share/opencc/s2twp.json';

    $command = sprintf('echo %s | opencc -c %s', escapeshellarg($text), escapeshellarg($configFile));

    $converted = shell_exec($command);

    return trim($converted);
}

echo s2t('简体中文');
```

或是使用 `symfony/process` 套件，建立更安全的轉換函式。

```php
<?php

require 'vendor/autoload.php';

use Symfony\Component\Process\Process;

class TextConverter
{
    public static function s2t($input)
    {
        $config = 's2twp.json';

        $command = [
            'opencc',
            '-c',
            $config,
        ];

        $process = new Process($command);
        $process->setInput($input);
        $process->mustRun();
        $output = $process->getOutput();

        return $output ?: $input;
    }
}

echo TextConverter::s2t('简体中文');
```

## 參考資料

- [BYVoid/OpenCC](https://github.com/BYVoid/OpenCC)
