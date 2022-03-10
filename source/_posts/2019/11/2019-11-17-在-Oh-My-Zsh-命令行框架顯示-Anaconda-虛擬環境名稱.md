---
title: 在 Oh My Zsh 命令行框架顯示 Anaconda 虛擬環境名稱
permalink: 在-Oh-My-Zsh-命令行框架顯示-Anaconda-虛擬環境名稱
date: 2019-11-17 03:13:34
tags: ["Zsh", "macOS", "CLI", "Python", "Anaconda"]
categories: ["其他", "CLI"]
---

修改 `~/.zshrc` 檔：

```BASH
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(... anaconda ...)
```

修改符號：

```BASH
POWERLEVEL9K_ANACONDA_LEFT_DELIMITER=""
POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER=""
```

完成設定，執行以下指令：

```BASH
exec $SHELL
```
