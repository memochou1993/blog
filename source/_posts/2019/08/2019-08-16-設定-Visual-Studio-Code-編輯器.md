---
title: 設定 Visual Studio Code 編輯器
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
    "files.autoSave":"afterDelay",
    "files.autoSaveDelay": 250,
    "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
    "workbench.colorTheme": "Super One Dark",
    "workbench.editor.untitled.hint": "hidden",
    "terminal.integrated.fontFamily": "SauceCodePro Nerd Font",
    "terminal.integrated.cursorStyle": "underline",
    "terminal.integrated.cursorBlinking": true,
    "git.autofetch": true,
    "namespaceResolver.sortAlphabetically": true,
    "php-cs-fixer.lastDownload": 1644850927895,
    "php-cs-fixer.executablePath": "${extensionPath}/php-cs-fixer.phar",
    "go.formatTool": "goimports",
    "go.useLanguageServer": true,
    "go.toolsManagement.autoUpdate": true,
    "eslint.alwaysShowStatus": true,
    "markdownlint.config": {
        "MD029": false,
        "MD033": false
    },
    "diffEditor.ignoreTrimWhitespace": false,
    "liveServer.settings.donotShowInfoMsg": true,
    "tabnine.experimentalAutoImports": true,
    "powermode.enabled": true,
    "powermode.combo.location": "statusbar",
    "powermode.combo.counterEnabled": "default",
    "powermode.combo.timerEnabled": "hide",
    "powermode.shake.enabled": false,
    "[php]": {
        "editor.formatOnSave": false,
        "editor.defaultFormatter": "junstyle.php-cs-fixer",
        "editor.tabSize": 4
    },
    "[vue]": {
        "editor.formatOnSave": false,
        "editor.defaultFormatter": "octref.vetur",
        "editor.tabSize": 2
    },
    "[javascript]": {
        "editor.formatOnSave": false,
        "editor.defaultFormatter": "vscode.typescript-language-features",
        "editor.tabSize": 2
    },
    "[typescript]": {
        "editor.formatOnSave": false,
        "editor.defaultFormatter": "vscode.typescript-language-features",
        "editor.tabSize": 2
    },
    "[json]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    },
    "[dart]": {
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.rulers": [
            80
        ],
        "editor.selectionHighlight": false,
        "editor.suggest.snippetsPreventQuickSuggestions": false,
        "editor.suggestSelection": "first",
        "editor.tabCompletion": "onlySnippets",
        "editor.wordBasedSuggestions": false
    }
}
```
