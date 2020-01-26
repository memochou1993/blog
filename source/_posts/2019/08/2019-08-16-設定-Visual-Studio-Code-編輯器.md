---
title: 設定 Visual Studio Code 編輯器
permalink: 設定-Visual-Studio-Code-編輯器
date: 2019-08-16 00:55:04
tags: ["編輯器", "Visual Studio Code"]
categories: ["其他", "編輯器"]
---

記錄平常使用的設定。

```JSON
{
    "window.zoomLevel": 1,
    "editor.fontSize": 16,
    "editor.fontFamily": "Operator Mono",
    "editor.suggestSelection": "first",
    "workbench.colorTheme": "Super One Dark",
    "terminal.integrated.fontFamily": "SauceCodePro Nerd Font",
    "terminal.integrated.confirmOnExit": true,
    "terminal.integrated.cursorStyle": "underline",
    "terminal.integrated.cursorBlinking": true,
    "terminal.integrated.shell.osx": "/usr/local/bin/zsh",
    "git.autofetch": true,
    "powermode.enabled": true,
    "powermode.enableShake": false,
    "powermode.enableStatusBarComboTimer": false,
    "namespaceResolver.sortAlphabetically": true,
    "php-cs-fixer.executablePath": "${extensionPath}/php-cs-fixer.phar",
    "php-cs-fixer.lastDownload": 1579943050327,
    "php-cs-fixer.onsave": true,
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "go.formatTool": "goimports",
    "go.useLanguageServer": true,
    "[php]": {
        "editor.defaultFormatter": "junstyle.php-cs-fixer"
    },
    "[vue]": {
        "editor.defaultFormatter": "octref.vetur"
    }
}
```
