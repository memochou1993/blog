---
title: 在 Oh My Zsh 命令列框架顯示 Anaconda 虛擬環境名稱
date: 2019-11-17 03:13:34
tags: ["Shell", "Zsh", "macOS", "Oh My Zsh", "Python", "Anaconda"]
categories: ["其他", "Shell"]
---

修改 `~/.zshrc` 檔：

```bash
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(... anaconda ...)
```

修改符號：

```bash
POWERLEVEL9K_ANACONDA_LEFT_DELIMITER=""
POWERLEVEL9K_ANACONDA_RIGHT_DELIMITER=""
```

完成設定，執行以下指令：

```bash
exec $SHELL
```
