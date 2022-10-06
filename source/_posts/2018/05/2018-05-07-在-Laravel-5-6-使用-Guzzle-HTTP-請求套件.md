---
title: 在 Laravel 5.6 使用 Guzzle HTTP 請求套件
date: 2018-05-07 10:20:05
tags: ["程式設計", "PHP", "Laravel", "Guzzle"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 前言

本文將對先前〈使用 Lumen 5.6 實作 RESTful API〉一文所做之 API 進行 HTTP 請求測試。

## 安裝

```bash
composer require guzzlehttp/guzzle
```

## 設定路由

```php
Route::resource('/journals', 'JournalController');
```

## 使用

在控制器調用 `GuzzleHttp\Client` 套件。

```php
use GuzzleHttp\Client;
```

## 發送 GET 請求

取得所有期刊

```php
public function index()
{
    $client = new Client();

    $response = $client->get('journal.test/api/journals')->getBody();

    $journals = json_decode($response, true);

    return view('journals.index', compact('journals'));
}
```

取得特定期刊

```php
public function show($id)
{
    $client = new Client();

    $response = $client->get('journal.test/api/journals/'.$id)->getBody();

    $journal = json_decode($response, true);

    return view('journals.show', compact('cores', 'journal'));
}
```

刪除期刊

```php
public function destroy(Request $request, $id)
{
    $client = new Client();

    $response = $client->post('journal.test/api/journals/'.$id, [
        'form_params' => $request->all()
    ]);

    return redirect()->route('journals.index');
}
```

## 發送 POST 請求

儲存期刊

```php
public function store(Request $request)
{
    $client = new Client();

    $response = $client->post('journal.test/api/journals/', [
        'form_params' => $request->all()
    ])->getBody()->getContents();

    $journal = json_decode($response, true);

    return redirect()->route('journals.show', $journal['id']);
}
```

更新期刊

```php
public function edit($id)
{
    $client = new Client();

    $response = $client->post('journal.test/api/journals/'.$id, [
        'form_params' => $request->all()
    ]);

    return redirect()->route('journals.show', $id);
}
```

## 程式碼

- [doaj](https://github.com/memochou1993/doaj)
