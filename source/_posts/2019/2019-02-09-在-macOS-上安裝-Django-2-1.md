---
title: 在 macOS 上安裝 Django 2.1
permalink: 在-macOS-上安裝-Django-2-1
date: 2019-02-09 18:19:24
tags: ["程式寫作", "Python", "Django"]
categories: ["程式寫作", "Python", "Django"]
---

## 安裝 Python
使用 Homebrew 安裝 Python 3。
```
$ brew install python3
```

添加環境變數至 `~/.bash_profile` 檔。
```
export PATH="/usr/local/Cellar/python/3.7.2_1/bin:$PATH"
```

重新加載啟動文件。
```
$ source ~/.bash_profile
```

查看 Python 版本。
```
$ python3 -V
Python 3.7.2
```

## 安裝 Pip
下載 `get-pip.py` 檔。
```
$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
```

安裝 Pip3。
```
$ python3 get-pip.py
```

添加環境變數至 `~/.bash_profile` 檔。
```
export PATH="/usr/local/Cellar/python/3.7.2_1/Frameworks/Python.framework/Versions/3.7/bin:$PATH"
```

重新加載啟動文件。
```
$ source ~/.bash_profile
```

查看 Pip 版本。
```
$ pip3 -V
pip 19.0.2
```

## 安裝 Virtualenvwrapper
使用 Pip 安裝 Virtualenvwrapper。
```
$ pip3 install virtualenvwrapper
```

添加環境變數至 `~/.bash_profile` 檔。
```
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON="/usr/local/Cellar/python/3.7.2_1/Frameworks/Python.framework/Versions/3.7/bin/python3"
export PROJECT_HOME="$HOME/Devel"
source /usr/local/Cellar/python/3.7.2_1/Frameworks/Python.framework/Versions/3.7/bin/virtualenvwrapper.sh
```

重新加載啟動文件。
```
$ source ~/.bash_profile
```

建立虛擬環境。
```
$ mkvirtualenv django_env
```

列出可用的虛擬環境。
```
$ workon
django_env
```

刪除指定的虛擬環境。
```
$ rmvirtualenv django_env
```

啟動指定的虛擬環境。
```
$ workon django_env
```

退出當前的虛擬環境。
```
$ deactivate
```

## 安裝 Django
建立一個虛擬環境後，使用 Pip 安裝 Django。
```
$ pip3 install django
```

查看 Django 版本。
```
$ python3 -m django --version
2.1.5
```

使用 django-admin 工具建立一個專案。
```
$ django-admin startproject mysite
$ cd mysite
```

啟動網頁伺服器。
```
$ python3 manage.py runserver
```

## 瀏覽網頁
前往：http://127.0.0.1:8000
