---
title: 在 CodeIgniter 3.1 使用 PhpSpreadsheet 試算表處理套件
permalink: 在-CodeIgniter-3-1-使用-PhpSpreadsheet-試算表處理套件
date: 2018-11-26 17:05:57
tags: ["程式寫作", "PHP", "CodeIgniter", "Excel"]
categories: ["程式寫作", "PHP", "CodeIgniter"]
---

## 環境

- macOS
- Homestead

## 安裝套件

```CMD
composer require phpoffice/phpspreadsheet
```

## 設計

- 建立一個獨立的 ExcelGenerator 模組，只負責資料處理與檔案輸出。

## 修改 composer.json 檔

使用 PSR-4 方法自動加載命名空間。

```PHP
"autoload": {
    "psr-4": {
        "Application\\Controllers\\Module\\": "application/controllers/module/"
    }
}
```

執行傾倒

```CMD
composer dump-autoload
```

## 使用

### 資料注入

```PHP
// 導入命名空間
use Application\Controllers\Module\ExcelGenerator;

// 資料
$result = [];
// 實例化 ExcelGenerator 物件
$excel = new ExcelGenerator();
// 調用方法，注入資料
$excel->myFunc($result);
```

### 檔案生成

建立 `application/controllers/module/ExcelGenerator.php` 檔。

```PHP
// 命名空間
namespace Application\Controllers\Module;

// 導入命名空間
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;

class ExcelGenerator
{
    public function myFunc($result) {
        // 檔案名稱
        $file_name = 'foo';

        // 實例化 Spreadsheet 物件
        $spreadsheet = new Spreadsheet();
        // 調用方法，注入資料
        $sheet = $spreadsheet->getActiveSheet()->fromArray($data);

        // 設置 HTTP 頭欄位
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="' . $file_name . '.xlsx"');
        header('Cache-Control: max-age=0');

        // 輸出檔案
        $writer = IOFactory::createWriter($sheet, 'Xlsx');
        $writer->save('php://output');
    }
}

```
