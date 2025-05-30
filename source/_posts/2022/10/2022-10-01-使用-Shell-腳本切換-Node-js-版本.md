---
title: 使用 Shell 腳本切換 Node-js 版本
date: 2022-10-01 16:05:00
tags: ["Shell", "SSH", "Node.js"]
categories: ["Programming", "Shell"]
---

## 做法

修改 `.zshrc` 檔，添加以下腳本。

```bash
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

重新讀取環境變數。

```bash
source ~/.zshrc
```

在特定的 Node 專案中新增 `.nvmrc` 檔。

```env
v10.24.1
```

## 參考資料

- [nvm-sh/nvm](https://github.com/nvm-sh/nvm#zsh)
