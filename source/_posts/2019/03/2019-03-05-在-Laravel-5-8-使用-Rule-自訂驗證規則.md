---
title: 在 Laravel 5.8 使用 Rule 自訂驗證規則
permalink: 在-Laravel-5-8-使用-Rule-自訂驗證規則
date: 2019-03-05 23:50:24
tags: ["程式寫作", "PHP", "Laravel"]
categories: ["程式寫作", "PHP", "Laravel"]
---

## 做法

### With

設計一個檢查請求參數是否符合特定關聯的驗證規則，例如可接受 `projects` 和 `environments` 參數，則以下請求將通過驗證：

```PHP
api/users/me/projects?with=projects
api/users/me/projects?with=environments
api/users/me/projects?with=projects,environments
api/users/me/projects?with=environments,projects
```

新增 `With` 驗證規則。

```BASH
php artisan make:rule With
```

修改 `app/Rules/With.php` 檔。

```PHP
namespace App\Rules;

use Illuminate\Contracts\Validation\Rule;

class With implements Rule
{
    /**
     * @var array
     */
    protected $values;

    /**
     * Create a new rule instance.
     *
     * @return void
     */
    public function __construct($values)
    {
        $this->values = $values;
    }

    /**
     * Determine if the validation rule passes.
     *
     * @param  string  $attribute
     * @param  mixed  $value
     * @return bool
     */
    public function passes($attribute, $value)
    {
        if (! $value) {
            return true;
        }

        $values = explode(',', $value);

        foreach ($values as $value) {
            if (! in_array($value, $this->values, true)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Get the validation error message.
     *
     * @return string
     */
    public function message()
    {
        return 'The :attribute must be the following types: '.implode(', ', $this->values).'.';
    }
}
```

在 `app/Http/Requests/ProjectRequest.php` 檔使用。

```PHP
public function rules()
{
    return [
        'with' =>  new With([
            'users',
            'environments',
        ]),
    ];
}
```

### Unique

設計一個檢查使用者是否已有相同名稱資源的驗證規則。

新增 `Unique` 驗證規則。

```BASH
php artisan make:rule Unique
```

修改 `app/Rules/Unique.php` 檔。

```PHP
namespace App\Rules;

use Illuminate\Contracts\Validation\Rule;

class Unique implements Rule
{
    protected $user;

    protected $table;

    /**
     * Create a new rule instance.
     *
     * @return void
     */
    public function __construct($user, $table)
    {
        $this->user = $user;

        $this->table = $table;
    }

    /**
     * Determine if the validation rule passes.
     *
     * @param  string  $attribute
     * @param  mixed  $value
     * @return bool
     */
    public function passes($attribute, $value)
    {
        $table = $this->table;

        if ($this->user->$table()->where($attribute, $value)->first()) {
            return false;
        }

        return true;
    }

    /**
     * Get the validation error message.
     *
     * @return string
     */
    public function message()
    {
        return 'The :attribute has already been taken.';
    }
}
```

在 `app/Http/Requests/ProjectRequest.php` 檔使用。

```PHP
public function rules()
{
    return [
        'name' => [
            'required',
            new Unique(
                $this->user('api'),
                'projects'
            ),
        ],
        'private' => 'boolean',
    ];
}
```
