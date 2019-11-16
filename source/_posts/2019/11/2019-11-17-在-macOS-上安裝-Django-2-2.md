---
title: 在 macOS 上安裝 Django 2.2
permalink: 在-macOS-上安裝-Django-2-2
date: 2019-11-17 02:16:07
tags: ["程式寫作", "Python", "Django"]
categories: ["程式寫作", "Python", "Django"]
---

## 環境

- Anaconda
- Python 3.7

## 虛擬環境

使用 `conda` 指令建立虛擬環境。

```BASH
conda create --name myenv
```

進入虛擬環境。

```BASH
conda activate myenv
```

查看虛擬環境資訊。

```BASH
conda info
```

列出所有虛擬環境。

```BASH
conda env list
```

退出虛擬環境。

```BASH
conda deactivate
```

刪除虛擬環境。

```BASH
conda env remove --name myenv
```

## 安裝 Django

進入虛擬環境後，使用 `conda` 指令安裝 Django。

```BASH
conda install django
```

查看 Django 版本。

```BASH
django-admin.py version
2.2.5
```
