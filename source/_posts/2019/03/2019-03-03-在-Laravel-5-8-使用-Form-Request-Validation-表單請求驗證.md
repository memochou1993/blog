---
title: 在 Laravel 5.8 使用 Form Request Validation 表單請求驗證
permalink: 在-Laravel-5-8-使用-Form-Request-Validation-表單請求驗證
date: 2019-03-03 00:07:54
tags: ["程式設計", "PHP", "Laravel"]
categories: ["程式設計", "PHP", "Laravel"]
---

## 做法

根據請求方法，將同一資源的表單請求驗證寫在同一個檔案。

```PHP
namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProjectRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     *
     * @return bool
     */
    public function authorize()
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    public function rules()
    {
        $method = $this->method();

        switch($method) {
            case 'GET':
                return [
                    'paginate' => 'min:1|integer',
                ];

            case 'POST':
                return [
                    //
                ];

            case 'PUT':
            case 'PATCH':
                return [
                    //
                ];

            default:
                return [
                    //
                ];
        }
    }
}
```
