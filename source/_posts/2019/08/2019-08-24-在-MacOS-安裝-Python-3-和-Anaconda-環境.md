---
title: 在 MacOS 安裝 Python 3 和 Anaconda 環境
permalink: 在-MacOS-安裝-Python-3-和-Anaconda-環境
date: 2019-08-24 00:33:52
tags: ["程式設計", "Python", "Anaconda"]
categories: ["程式設計", "Python", "環境安裝"]
---

## 安裝環境

到官方網站下載 [Anaconda](https://www.anaconda.com/distribution/#download-section) 指令列安裝器。下載後，打開終端機執行安裝腳本，並指定安裝目錄為 `~/library/anaconda3`。

```BASH
bash Anaconda3-2019.07-MacOSX-x86_64.sh
```

將 `conda` 指令添加至環境變數。

```ENV
export PATH=$HOME/library/anaconda3/bin:$PATH
```

取消開機時自動啟動虛擬環境。

```BASH
conda config --set auto_activate_base false
```

## 安裝套件

使用 `conda` 指令安裝 keras，tensorflow 會一併安裝。

```BASH
conda install keras
```

查看 keras 套件版本。

```BASH
python3
>>> import keras
Using TensorFlow backend.
>>> keras.__version__
'2.2.4'
```

查看 tensorflow 套件版本。

```BASH
python3
>>> import tensorflow
>>> tensorflow.__version__
'1.14.0'
```

## 打開筆記本

使用 `jupyter` 指令打開筆記本。

```BASH
cd ~
jupyter notebook
```
