---
title: 在 macOS 上安裝 Oh My Zsh 命令列框架和 Powerlevel10k 主題
date: 2022-03-26 21:38:55
tags: ["Shell", "Zsh", "macOS", "Oh My Zsh"]
categories: ["Others", "Shell"]
---

## 做法

使用以下指令，安裝 Zsh 的 [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) 框架。

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

下載 `Powerlevel10k` 主題。

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

修改 `~/.zshrc` 檔。

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

重啟 Zsh 直譯器。

```bash
exec zsh
```

如果配置沒有出現，可以執行以下指令。

```bash
p10k configure
```

最後，手動安裝 [MesloLGS NF](https://github.com/romkatv/powerlevel10k#fonts) 字體。
