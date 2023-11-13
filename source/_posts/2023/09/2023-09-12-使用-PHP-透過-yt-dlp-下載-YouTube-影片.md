---
title: 使用 PHP 透過 yt-dlp 下載 YouTube 影片
date: 2023-09-12 15:29:17
tags: ["Programming", "PHP"]
categories: ["Programming", "PHP", "Others"]
---

## 安裝套件

下載 `yt-dlp` 執行檔。

```bash
wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos
```

調整權限。

```bash
chmod +x yt-dlp
```

安裝 `ffmpeg` 依賴套件。

```bash
brew install ffmpeg
```

## 實作

新增 `index.php` 檔。

```php
<?php
function download($id) {
    $cmd = 'yt-dlp -x --audio-format mp3 -o "output/%(title)s.%(ext)s" '.$id;
    return shell_exec($cmd);
}

echo download('bu7nU9Mhpyo');
```

執行腳本。

```bash
php index.php
```

## 程式碼

- [youtube-downloader-php](https://github.com/memochou1993/youtube-downloader-php)

## 參考文件

- [yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)
