---
title: 在 Python 專案使用 Ruff 程式碼檢查工具
date: 2024-04-26 16:20:42
tags: ["Programming", "Python"]
categories: ["Programming", "Python", "Others"]
---

## 做法

安裝依賴套件。

```bash
poetry add ruff
```

新增 `ruff.toml` 檔。

```toml
line-length = 120
indent-width = 4

[format]
quote-style = "double"
```

修改 `.vscode/settings.json` 檔。

```json
{
    "[python]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "charliermarsh.ruff"
    }
}
```

## 參考資料

- [astral-sh/ruff](https://github.com/astral-sh/ruff)
