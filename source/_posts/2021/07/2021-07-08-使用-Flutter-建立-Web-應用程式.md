---
title: 使用 Flutter 建立 Web 應用程式
permalink: 使用-Flutter-建立-Web-應用程式
date: 2021-07-08 22:22:34
tags: ["程式設計", "Dart", "Flutter"]
categories: ["程式設計", "Dart", "Flutter"]
---

## 安裝

使用 `brew` 安裝 `flutter`。

```BASH
brew install --cask flutter
```

查看版本。

```BASH
flutter --version
```

查看缺少的依賴項目。

```BASH
flutter doctor
```

## 建立專案

切換到 `stable` 版本，並確保 Flutter 在最新版本。

```BASH
flutter channel stable
flutter upgrade
```

查看裝置。

```BASH
flutter devices
```

建立專案，名字不可以有 `-` 符號。

```BASH
flutter create flutter_web_example
```

啟動服務。

```BASH
cd flutter_web_example
flutter run -d chrome --web-port 8080
```

## 瀏覽網頁

前往：<http://127.0.0.1:8080>

## 參考資料

- [Building a web application with Flutter](https://flutter.dev/docs/get-started/web)
