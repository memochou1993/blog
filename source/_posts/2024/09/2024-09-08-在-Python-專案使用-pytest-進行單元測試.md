---
title: 在 Python 專案使用 pytest 進行單元測試
date: 2024-09-08 16:45:34
tags: ["Programming", "Python", "Testing"]
categories: ["Programming", "Python", "Others"]
---

## 測試範例

建立 `math_operations.py` 檔。

```py
def add(a, b):
    return a + b
```

建立 `test_math_operations.py` 檔。

```py
from math_operations import add

def test_add():
    assert add(1, 2) == 3
    assert add(-1, 1) == 0
    assert add(0, 0) == 0
```

執行測試。

```bash
pytest test_math_operations.py
```

## 參數化測試

參數化測試可以使用不同的參數組合來測試同一個函數。

### 實作

修改 `test_math_operations.py` 檔。

```py
import pytest

from math_operations import add


@pytest.mark.parametrize(
    "a, b, expected",
    [
        (1, 2, 3),
        (-1, 1, 0),
        (0, 0, 0),
        (100, 200, 300),
    ],
)
def test_add(a, b, expected):
    assert add(a, b) == expected
```

執行測試。

```bash
pytest test_math_operations.py
```

## 測試例外

可以使用 `pytest.raises` 來測試異常情況。

### 實作

修改 `math_operations.py` 檔。

```py
def add(a, b):
    return a + b


def divide(a, b):
    if b == 0:
        raise ZeroDivisionError("Cannot divide by zero")
    return a / b
```

修改 `test_math_operations.py` 檔。

```py
import pytest

from math_operations import divide


def test_divide_by_zero():
    with pytest.raises(ZeroDivisionError):
        divide(1, 0)
```

執行測試。

```bash
pytest test_math_operations.py
```

## 測試夾具

Pytest 的夾具（fixtures）可以在測試中共享和重用程式碼。

### 實作

修改 `math_operations.py` 檔。

```py
import pytest


@pytest.fixture
def sample_data():
    return {"a": 10, "b": 20}


def test_add_with_fixture(sample_data):
    result = sample_data["a"] + sample_data["b"]
    assert result == 30
```

執行測試。

```bash
pytest test_math_operations.py
```

## 參考資料

- [pytest](https://docs.pytest.org/en/stable/)
