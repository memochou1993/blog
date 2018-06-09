---
title: 《現代 PHP》學習筆記（四）：Generator
date: 2018-05-21 10:24:27
tags: ["程式寫作", "PHP"]
categories: ["程式寫作", "PHP", "《現代 PHP》學習筆記"]
---

## 前言
本文為《現代 PHP》一書的學習筆記。

## 環境
- Windows 10
- XAMPP 3.2.2

## 產生器
> 產生器（Generator）在需要的時刻計算並產生運算後的數値，避免占用寶貴的記憶體空間。

產生器的例子如下：
```PHP
function myGenerator() {
    yield 'value1';
    yield 'value2';
    yield 'value3';
}

foreach (myGenerator() as $value) {
    echo $value . PHP_EOL;
}
```
這裡使用作者提供的範例進行實作：
```
$ cd modern-php/02-features/generators
```
範例 2-16：Range 產生器（不良示範）
```PHP
function makeRange($length) {
    $dataset = [];
    for ($i = 0; $i < $length; $i++) {
        $dataset[] = $i;
    }

    return $dataset;
}

$customRange = makeRange(1000000);
foreach ($customRange as $i) {
    echo $i . PHP_EOL;
}
```
- 此範例宣告了一個 `$dataset` 陣列並配置了一百萬個整數的記憶體空間。

範例 2-17：Range 產生器（良好示範）
```PHP
function makeRange($length) {
    for ($i = 0; $i < $length; $i++) {
        yield $i;
    }
}

foreach (makeRange(1000000) as $i) {
    echo $i . PHP_EOL;
}
```
> 產生器只是一個使用數次 `yield` 關鍵字的 PHP 函式，沒有回傳値。

假如需要疊代一個 4 GB 的逗號分隔値（CSV），但是虛擬私人主機只有 1 GB 的可用記憶體，此時將需要使用到產生器。

範例 2-18：CSV 產生器
```PHP
function getRows($file) {
    $handle = fopen($file, 'rb'); // `rb` 表示二進位檔案
    if (!$handle) {
        throw new Exception();
    }
    while (!feof($handle)) {
        yield fgetcsv($handle);
    }
    fclose($handle);
}

foreach (getRows('data.csv') as $row) {
    print_r($row);
}
```
- `fopen()` 函數用來打開一個文件。
- `feof()` 函數用來檢測是否已到達文件末尾。
- `fgetcsv()` 函數用來解析 CSV 字段。
- `fclose()` 函數用來關閉一個文件。

> 產生器是只能往前的疊代器，無法用來倒帶、快轉或搜尋資料群集。

## 參考資料
Josh Lockhart（2015）。現代 PHP。台北市：碁峯資訊。