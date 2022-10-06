---
title: 在 Laravel 8.4 使用 Hashids 混淆資源唯一辨識碼
date: 2021-08-26 22:18:26
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 安裝套件

使用 [hashids](https://github.com/vinkla/hashids) 套件可以將 ID 打亂，避免將主鍵直接暴露於網址中。

```bash
composer require hashids/hashids
```

## 建立幫手函式

在 `helpers.php` 新增 `hash_id` 函式：

```php
use Hashids\Hashids;
use Illuminate\Support\Str;

if (! function_exists('hash_id')) {
    function hash_id($salt_suffix = '')
    {
        $length = 6;
        $key = Str::of(config('app.key'))->substr(7, $length);
        $salt = sprintf("%s_%s", $key, $salt_suffix);
        $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        return new Hashids($salt, $length, $alphabet);
    }
}
```

確保在 `composer.json` 載入 `helper.php` 檔。

```json
{
    "autoload": {
        "files": [
            "app/helpers.php"
        ]
    }
}
```

執行以下指令，以更新自動加載內容。

```bash
composer dump-autoload
```

## 建立特徵機制

在 `app\Models\Traits` 資料夾建立 `HasHashId.php` 檔：

```php
namespace App\Models\Traits;

trait HasHashId
{
    // 屬性 hash_id 存取器
    public function getHashIdAttribute()
    {
        // 以模型資料表的名字當作 Hash ID 鹽的後綴，讓不同的模型有不同的 Hash ID
        return hash_id($this->getTable())->encodeHex($this->getKey());
    }

    /**
     * Retrieve the model for a bound value.
     *
     * @param  mixed  $value
     * @param  string|null  $field
     * @return \Illuminate\Database\Eloquent\Model|null
     */
    public function resolveRouteBinding($value, $field = null)
    {
        // 兼容 ID 查找
        if (is_numeric($value)) {
            return parent::resolveRouteBinding($value);
        }
        return parent::resolveRouteBinding(hash_id($this->getTable())->decodeHex($value));
    }
}
```

以 `User` 模型為例，引入 `HasHashId` 特徵機制。

```php
use App\Models\Traits\HasHashId;
// ...

class User extends Authenticatable
{
    use HasHashId;

    // ...
}
```

修改 `UserResource` 如下：

```php
/**
 * Transform the resource into an array.
 *
 * @param  \Illuminate\Http\Request  $request
 * @return array
 */
public function toArray($request)
{
    return [
        'id' => $this->hash_id,
        // ...
    ];
}
```
