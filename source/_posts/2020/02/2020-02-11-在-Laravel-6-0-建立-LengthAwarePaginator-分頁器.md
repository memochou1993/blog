---
title: 在 Laravel 6.0 建立 LengthAwarePaginator 分頁器
permalink: 在-Laravel-6-0-建立-LengthAwarePaginator-分頁器
date: 2020-02-11 17:23:36
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 前言

如果需要對一個 Query Builder 進行 `map()` 或 `transform()` 等 Collection 方法，並且將修改過的資料進行分頁，可以手動建立一個 LengthAwarePaginator 分頁器。

## 做法

使用 `getCollection()` 方法可以從 Query Builder 中取得其 Collection 實例。

```PHP
// 取得資料的 LengthAwarePaginator 實例
$bookings = \App\Booking::paginate();

// 修改資料的 Collection 實例
$transformedBookings = $bookings
    ->getCollection()
    ->transform(function ($booking) {
        $booking->exchangedAmount = $booking->amount * 10000;

        return $booking;
    });

// 手動建立 LengthAwarePaginator 分頁器
$paginatedBookings = new \Illuminate\Pagination\LengthAwarePaginator(
    $transformedBookings,
    $bookings->total(),
    $bookings->perPage(),
    $bookings->currentPage(),
    [
        'path' => \Request::url(),
        'query' => [
            'page' => $bookings->currentPage(),
        ],
    ],
);

return $paginatedBookings;
```
