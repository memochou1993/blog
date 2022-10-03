---
title: 使用 pyenv 和 pyenv-virtualenv 管理 Python 環境
date: 2022-04-15 16:40:21
tags: ["程式設計", "Python"]
categories: ["程式設計", "Python", "環境安裝"]
---

## 安裝工具

安裝 `pyenv` 命令列工具。

```BASH
brew install pyenv
```

將執行檔路徑添加至環境變數。

```BASH
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"
```

查看版本。

```BASH
pyenv --version
```

安裝 `pyenv-virtualenv` 套件。

```BASH
brew install pyenv-virtualenv
```

查看版本。

```BASH
pyenv virtualenv --version
```

## 管理環境

使用 `pyenv` 指令，安裝 `3.8.13` 版本的 Python。

```BASH
pyenv install 3.8.13
```

創建 `example` 虛擬環境，並使用 `3.8.13` 版本的 Python。

```BASH
pyenv virtualenv 3.8.13 example
```

查看虛擬環境列表。

```BASH
pyenv versions

* system (set by /Users/williamchou/.pyenv/version)
  3.8.13
  3.8.13/envs/example
  3.8.13/envs/goodtv
  example
```

將當前目錄套用至 `example` 虛擬環境。

```BASH
pyenv local example
```

查看當前目錄的虛擬環境。

```BASH
pyenv version

example (set by ~/Projects/example/.python-version)
```

刪除 `example` 虛擬環境。

```BASH
pyenv uninstall example
```

## 參考資料

- [pyenv/pyenv](https://github.com/pyenv/pyenv)
- [pyenv/pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
