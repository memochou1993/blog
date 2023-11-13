---
title: 設定 Visual Studio Code 編輯器
date: 2019-08-16 00:55:04
tags: ["IDE", "Visual Studio Code"]
categories: ["Others", "IDE"]
---

記錄平常使用的設定。

```json
{
  "editor.fontSize": 16,
  "files.autoSaveDelay": 250,
  "php-cs-fixer.lastDownload": 1668616728236,
  "window.zoomLevel": 1,
  "editor.fontFamily": "Operator Mono",
  "editor.suggestSelection": "first",
  "files.autoSave": "afterDelay",
  "go.formatTool": "goimports",
  "javascript.updateImportsOnFileMove.enabled": "always",
  "php-cs-fixer.executablePath": "${extensionPath}/php-cs-fixer.phar",
  "powermode.combo.counterEnabled": "default",
  "powermode.combo.location": "statusbar",
  "powermode.combo.timerEnabled": "hide",
  "terminal.integrated.cursorStyle": "underline",
  "terminal.integrated.fontFamily": "SauceCodePro Nerd Font",
  "vsintellicode.modify.editor.suggestSelection": "automaticallyOverrodeDefaultValue",
  "workbench.colorTheme": "Super One Dark",
  "workbench.editor.untitled.hint": "hidden",
  "workbench.startupEditor": "none",
  "[css]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "vscode.css-language-features",
    "editor.formatOnSave": false
  },
  "[dart]": {
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.rulers": [
      80
    ],
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.wordBasedSuggestions": false
  },
  "[javascript]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "vscode.typescript-language-features",
    "editor.formatOnSave": false
  },
  "[javascriptreact]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "vscode.typescript-language-features",
    "editor.formatOnSave": false
  },
  "[json]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "vscode.json-language-features",
    "editor.formatOnSave": false
  },
  "[php]": {
    "editor.tabSize": 4,
    "editor.defaultFormatter": "junstyle.php-cs-fixer",
    "editor.formatOnSave": false
  },
  "[rust]": {
    "editor.defaultFormatter": "rust-lang.rust-analyzer",
    "editor.formatOnSave": true
  },
  "[typescript]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "vscode.typescript-language-features",
    "editor.formatOnSave": false
  },
  "[typescriptreact]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "vscode.typescript-language-features",
    "editor.formatOnSave": false
  },
  "[vue]": {
    "editor.tabSize": 2,
    "editor.defaultFormatter": "octref.vetur",
    "editor.formatOnSave": false
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact"
  },
  "markdownlint.config": {
    "MD029": false,
    "MD033": false
  },
  "rust-analyzer.checkOnSave.extraArgs": [
    "--target-dir",
    "/tmp/rust-analyzer-check"
  ],
  "rust-analyzer.server.extraEnv": {
    "RUSTFLAGS": "--cfg=web_sys_unstable_apis"
  },
  "diffEditor.ignoreTrimWhitespace": false,
  "eslint.alwaysShowStatus": true,
  "git.autofetch": true,
  "git.confirmSync": false,
  "go.toolsManagement.autoUpdate": true,
  "go.useLanguageServer": true,
  "headwind.runOnSave": false,
  "liveServer.settings.donotShowInfoMsg": true,
  "namespaceResolver.sortAlphabetically": true,
  "powermode.enabled": true,
  "powermode.shake.enabled": false,
  "tabnine.experimentalAutoImports": true,
  "terminal.integrated.cursorBlinking": true
}
```
