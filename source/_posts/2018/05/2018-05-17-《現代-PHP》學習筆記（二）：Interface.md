---
title: 《現代 PHP》學習筆記（二）：Interface
date: 2018-05-17 10:22:09
tags: ["程式設計", "PHP"]
categories: ["程式設計", "PHP", "《現代 PHP》學習筆記"]
---

## 前言

本文為《現代 PHP》一書的學習筆記。

## 環境

- Windows 10
- XAMPP 3.2.2

## 介面

> 介面（Interface）是一個介於兩個 PHP 物件之間的合約，讓一個物件了解另一個物件「可以做什麼」。

介面的例子如下：

```php
interface MyInterface
{
    //
}
```

假想一個 `DocumentStore` 類別，它用來蒐集來自不同來源的文字：從遠端 URL 擷取的 HTML、讀取串流來源，以及終端機指令的輸出。

範例 2-6：DocumentStore 類別定義

```php
class DocumentStore
{
    protected $data = [];

    public function addDocument(Documentable $document)
    {
        $key = $document->getId(); // 文件的唯一識別
        $value = $document->getContent(); // 文件的內容
        $this->data[$key] = $value; // 放進陣列
    }

    public function getDocuments()
    {
        return $this->data; // 輸出
    }
}
```

- `addDocument()` 方法只接受 `Documentable` 的實例。

範例 2-7：Documentable 介面定義

```php
interface Documentable
{
    public function getId();

    public function getContent();
}
```

- 介面定義了任何實作 `Documentable` 介面的物件都必須提供公開的 `getId()` 和 `getContent()` 方法。

範例 2-8：HtmlDocument 類別定義

```php
class HtmlDocument implements Documentable
{
    protected $url;

    public function __construct($url)
    {
        $this->url = $url;
    }

    public function getId()
    {
        return $this->url;
    }

    public function getContent()
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
        curl_setopt($ch, CURLOPT_MAXREDIRS, 3);
        $html = curl_exec($ch);
        curl_close($ch);

        return $html;
    }
}
```

- `curl_init()` 函數用來初始化 cURL 會話
- `curl_setopt()` 函數用來設置 cURL 傳輸選項
- `curl_exec()` 函數用來執行 cURL 會話
- `curl_close()` 函數用來關閉 cURL 會話

範例 2-9：StreamDocument 類別定義

```php
class StreamDocument implements Documentable
{
    protected $resource;
    protected $buffer;

    public function __construct($resource, $buffer = 4096)
    {
        $this->resource = $resource;
        $this->buffer = $buffer;
    }

    public function getId()
    {
        return 'resource-' . (int) $this->resource;
    }

    public function getContent()
    {
        $streamContent = '';
        rewind($this->resource);
        while (feof($this->resource) === false) {
            $streamContent .= fread($this->resource, $this->buffer);
        }

        return $streamContent;
    }
}
```

- `rewind()` 函數用來使文件指針的位置回到文件的開頭。
- `feof()` 函數用來檢測是否已到達文件末尾。
- `fread()` 函數用來讀取文件，第二個參數是讀取的最大位元數。

範例 2-10：CommandOutputDocument 類別定義

```php
class CommandOutputDocument implements Documentable
{
    protected $command;

    public function __construct($command)
    {
        $this->command = $command;
    }

    public function getId()
    {
        return $this->command;
    }

    public function getContent()
    {
        return shell_exec($this->command);
    }
}
```

- `shell_exec()` 函式用來通過 Shell 環境執行命令，並以字串返回完整輸出。

範例 2-11：蒐集來自不同來源的文字

```php
require 'Documentable.php';
require 'DocumentStore.php';
require 'HtmlDocument.php';
require 'StreamDocument.php';
require 'CommandOutputDocument.php';

$documentStore = new DocumentStore();

// 加入 HTML 文件
$htmlDoc = new HtmlDocument('http://php.net');
$documentStore->addDocument($htmlDoc);

// 加入串流文件
$streamDoc = new StreamDocument(fopen('stream.txt', 'rb')); // `rb` 表示二進位檔案
$documentStore->addDocument($streamDoc);

// 加入終端機指令
$cmdDoc = new CommandOutputDocument('echo hello world!');
$documentStore->addDocument($cmdDoc);

print_r($documentStore->getDocuments());
```

類別與介面之間的關係如下：

| 類別 | 方法 | 介面 | 類別 |
| --- | --- | --- | --- |
| DocumentStore | addDocument() | Documentable | HtmlDocument |
|   |   |   | StreamDocument |
|   |   |   | CommandOutputDocument |
| 用來蒐集不同來源的文字 | 僅接受實作介面的實例 | 定義實作介面的物件必須提供的方法 | 使用 implements 關鍵字實作介面 |

## 參考資料

- Josh Lockhart（2015）。現代 PHP。台北市：碁峯資訊。
