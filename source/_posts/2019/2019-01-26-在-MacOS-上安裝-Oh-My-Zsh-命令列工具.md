---
title: 在 MacOS 上安裝 Oh My Zsh 命令列工具
permalink: 在-MacOS-上安裝-Oh-My-Zsh-命令列工具
date: 2019-01-26 01:03:50
tags: ["Zsh", "macOS", "命令列工具"]
categories: ["其他", "命令列工具"]
---

## 下載主題
下載命令列主題 [iTerm2 Color Schemes](https://github.com/mbadolato/iTerm2-Color-Schemes)，並且解壓縮。
```
$ git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git
```
打開終端機的「偏好設定」、「描述檔」，匯入 `iTerm2-Color-Schemes-master/terminal` 資料夾中喜歡的主題，並且設為預設值。

## 安裝字型
安裝 `Source Code Pro Nerd Font Complete` 字型。
```
$ brew tap caskroom/fonts
$ brew cask install font-sourcecodepro-nerd-font
```
或使用以下指令搜尋其他字型。
```
$ brew search nerd
```
- 指令 `brew cask search` 已廢棄。

打開終端機的「偏好設定」、「描述檔」、「文字」，選擇字體。

## 安裝 Zsh
安裝 Zsh 命令解釋器。
```
$ brew install zsh
```

將 Zsh 設為預設的命令解釋器。
```
$ sudo sh -c "echo $(which zsh) >> /etc/shells" 
chsh -s $(which zsh)
```

## 安裝 Oh My Zsh
安裝 Zsh 的 [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) 框架。
```
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## 安裝 Powerlevel9k
安裝 Oh My Zsh 的 [Powerlevel9k](https://github.com/bhilburn/powerlevel9k) 主題到 `~/.oh-my-zsh/custom/themes` 資料夾。
```
$ git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
```

修改 `~/.zshrc` 檔：
```
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE="nerdfont-complete"
DEFAULT_USER="william"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir dir_writable vcs newline context)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
```
- `ZSH_THEME` 參數設為 `powerlevel9k/powerlevel9k` 主題。
- `POWERLEVEL9K_MODE` 參數設為 `nerdfont-complete` 完整字型。
- `DEFAULT_USER` 參數設為使用者名稱。
- `POWERLEVEL9K_LEFT_PROMPT_ELEMENTS` 設為命令列左端要出現的符號。
- `POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS` 設為命令列右端要出現的符號。

完成設定，執行以下指令：
```
$ exec $SHELL
```

## 設定 VS Code 編輯器
修改 `settings.json` 檔：
```JSON
{
  "terminal.integrated.fontFamily": "SauceCodePro Nerd Font"
}
```

## 補充
在 iTerm 終端機使用 `option` 鍵跳過一段文字的方法：
- 打開選項 `Profiles` 的 `Keys` 列表。
- 將選項 `Left Option Key` 設為 `Esc+`。
- 錄製 `option+left` 的動作，並在 `Esc+` 輸入 `B`。
- 錄製 `option+right` 的動作，並在 `Esc+` 輸入 `F`。

## 參考資料
[超簡單！十分鐘打造漂亮又好用的 Zsh Command Line 環境](https://medium.com/statementdog-engineering/prettify-your-zsh-command-line-prompt-3ca2acc967f)