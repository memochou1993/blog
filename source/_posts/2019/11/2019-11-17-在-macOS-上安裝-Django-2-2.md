---
title: 在 macOS 上安裝 Django 2.2
date: 2019-11-17 02:16:07
tags: ["Programming", "Python", "Django"]
categories: ["Programming", "Python", "Django"]
---

## 環境

- Anaconda
- Python 3.7

## 虛擬環境

使用 `conda` 指令建立虛擬環境。

```bash
conda create --name myenv
```

進入虛擬環境。

```bash
conda activate myenv
```

查看虛擬環境資訊。

```bash
conda info
```

列出所有虛擬環境。

```bash
conda env list
```

退出虛擬環境。

```bash
conda deactivate
```

刪除虛擬環境。

```bash
conda env remove --name myenv
```

## 安裝 Django

進入虛擬環境後，使用 `conda` 指令安裝 Django。

```bash
conda install django
```

查看 Django 版本。

```bash
django-admin.py version
2.2.5
```

使用 django-admin 工具建立一個專案。

```bash
django-admin startproject mysite
cd mysite
```

啟動伺服器。

```bash
python3 manage.py runserver
```

## 瀏覽網頁

前往 <http://127.0.0.1:8000> 瀏覽。
