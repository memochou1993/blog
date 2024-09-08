---
title: 在 Python 專案使用 Pydantic 進行資料驗證與模型建立
date: 2024-09-08 16:22:22
tags: ["Programming", "Python", "Pydantic"]
categories: ["Programming", "Python", "Others"]
---

## 實作

建立 `main.py` 檔。

```py
from pydantic import BaseModel, EmailStr
from typing import Optional

class User(BaseModel):
    name: str
    age: int
    email: EmailStr
    is_active: Optional[bool] = True

user = User(
    name="Alice",
    age=30,
    email="alice@example.com"
)

print(user)
```

執行腳本。

```bash
python main.py
```

輸出如下：

```bash
name='Alice' age=30 email='alice@example.com' is_active=True
```

修改 `main.py` 檔。

```py
# ...

try:
    user = User(
        name="Bob",
        age="twenty", # 應為整數
        email="bob_at_example.com", # 格式無效
    )
except Exception as e:
    print(e)
```

執行腳本。

```bash
python main.py
```

輸出如下：

```bash
2 validation errors for User
age
  Input should be a valid integer, unable to parse string as an integer [type=int_parsing, input_value='twenty', input_type=str]
    For further information visit https://errors.pydantic.dev/2.9/v/int_parsing
email
  value is not a valid email address: An email address must have an @-sign. [type=value_error, input_value='bob_at_example.com', input_type=str]
```

## 參考資料

- [Pydantic](https://docs.pydantic.dev/)
