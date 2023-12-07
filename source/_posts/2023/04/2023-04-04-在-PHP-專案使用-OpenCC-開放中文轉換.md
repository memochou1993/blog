---
title: 在 PHP 專案使用 OpenCC 開放中文轉換
date: 2023-04-04 01:19:28
tags: ["Programming", "PHP", "OpenCC"]
categories: ["Programming", "PHP", "Extension"]
---

## 做法

安裝指令。

```bash
brew install opencc
```

下載專案。

```bash
git clone https://github.com/BYVoid/OpenCC.git
```

複製字典檔。

```bash
cd OpenCC
sudo cp -r data /usr/local/share/opencc/
```

使用指令轉換。

```bash
echo "简体中文" | opencc -c s2twp.json
```

建立轉換函式。

```php
function s2t($text)
{
    $configFile = '/usr/local/share/opencc/s2twp.json';

    $command = sprintf('echo %s | opencc -c %s', escapeshellarg($text), escapeshellarg($configFile));

    $converted = shell_exec($command);

    return trim($converted);
}
```

使用函式轉換。

```bash
s2t('简体中文')
```

## 參考資料

- [BYVoid/OpenCC](https://github.com/BYVoid/OpenCC)
