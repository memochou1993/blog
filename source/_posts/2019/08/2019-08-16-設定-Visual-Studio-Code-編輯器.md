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
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "workbench.colorTheme": "Super One Dark",
    "terminal.integrated.fontFamily": "SauceCodePro Nerd Font",
    "terminal.integrated.cursorStyle": "underline",
    "terminal.integrated.cursorBlinking": true,
    "terminal.integrated.shell.osx": "zsh",
    "git.autofetch": true,
    "powermode.enabled": true,
    "powermode.enableShake": false,
    "powermode.enableStatusBarComboTimer": false,
    "namespaceResolver.sortAlphabetically": true,
    "php-cs-fixer.lastDownload": 1585310494243,
    "php-cs-fixer.executablePath": "${extensionPath}/php-cs-fixer.phar",
    "go.formatTool": "goimports",
    "go.useLanguageServer": true,
    "eslint.alwaysShowStatus": true,
    "markdownlint.config": {
        "MD029": false,
        "MD033": false
    },
    "[php]": {
        "editor.formatOnSave": false,
        "editor.defaultFormatter": "junstyle.php-cs-fixer"
    },
    "[vue]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "octref.vetur"
    },
    "[javascript]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "vscode.typescript-language-features"
    },
    "[javascriptreact]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "vscode.typescript-language-features"
    },
    "[jsonc]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    },
    "diffEditor.ignoreTrimWhitespace": false
}
```
