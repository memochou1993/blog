---
title: 使用 Guzzle Http 請求套件發送異步請求
permalink: 使用-Guzzle-Http-請求套件發送異步請求
date: 2019-11-20 23:09:35
tags: ["程式寫作", "PHP", "Guzzle"]
categories: ["程式寫作", "PHP"]
---

## 異步請求

使用 `GuzzleHttp\Client` 類別的 `requestAsync()` 方法來建立異步請求（async requests）。

```PHP
$results = [];

$client = new \GuzzleHttp\Client();

$uri = 'https://jsonplaceholder.typicode.com/todos';

$promise = $client->requestAsync('GET', $uri);

$promise->then(
    function (\Psr\Http\Message\ResponseInterface $res) use (&$results) {
        $results[] = json_decode($res->getBody(), true);
    },
    function (\GuzzleHttp\Exception\RequestException $e) {
        echo $e->getMessage() . "\n";
        echo $e->getRequest()->getMethod();
    }
);

$promise->wait();

echo 'results: '.count($results)."\n";
```

結果：

```PHP
results: 1
```

## 併發請求

使用 Promise 和異步請求同時發送多個請求。

```PHP
$results = [];

$client = new \GuzzleHttp\Client();

$uri = 'https://jsonplaceholder.typicode.com/todos';

$promise = function ($i) use ($client, $uri) {
    echo $i.': '.date('H:i:s')."\n";

    return $client->getAsync($uri);
};

$promises = [
    '1' => $promise(1),
    '2' => $promise(2),
    '3' => $promise(3),
    '4' => $promise(4),
    '5' => $promise(5),
];

$results = \GuzzleHttp\Promise\unwrap($promises);

echo 'results: '.count($results);
```

結果：

```PHP
1: 15:58:10
2: 15:58:10
3: 15:58:10
4: 15:58:10
5: 15:58:10
results: 5
```

當發送不確定數量的請求時，使用 `GuzzleHttp\Pool` 類別。

```PHP
$results = [];

$client = new \GuzzleHttp\Client();

$requests = function ($total) use ($client) {
    $uri = 'https://jsonplaceholder.typicode.com/todos';

    for ($i = 0; $i < $total; $i++) {
        echo $i.': '.date('H:i:s')."\n";

        yield function() use ($client, $uri) {
            return $client->getAsync($uri);
        };
    }
};

$pool = new \GuzzleHttp\Pool($client, $requests(10), [
    'concurrency' => 10,
    'fulfilled' => function ($response, $index) use (&$results) {
        $results[] = json_decode($response->getBody(), true);
    },
    'rejected' => function ($reason, $index) {
        // this is delivered each failed request
    },
]);

// Initiate the transfers and create a promise
$promise = $pool->promise();

// Force the pool of requests to complete.
$promise->wait();

echo 'results: '.count($results)."\n";
```

併發數設為 10，結果：

```PHP
0: 15:34:23
1: 15:34:23
2: 15:34:23
3: 15:34:23
4: 15:34:23
5: 15:34:23
6: 15:34:23
7: 15:34:23
8: 15:34:23
9: 15:34:23
results: 10
```

併發數設為 1，結果：

```PHP
0: 15:35:54
1: 15:35:55
2: 15:35:57
3: 15:35:58
4: 15:35:59
5: 15:35:59
6: 15:36:00
7: 15:36:00
8: 15:36:01
9: 15:36:01
results: 10
```

## 程式碼

[GitHub](https://github.com/memochou1993/guzzle-async-example)

## 參考資料

[Guzzle Documentation](http://docs.guzzlephp.org/)
