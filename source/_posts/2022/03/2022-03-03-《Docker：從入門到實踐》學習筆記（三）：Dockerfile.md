---
title: 《Docker：從入門到實踐》學習筆記（三）：Dockerfile
date: 2022-03-03 01:36:47
tags: ["環境部署", "Docker"]
categories: ["環境部署", "Docker", "《Docker：從入門到實踐》學習筆記"]
---

## 前言

本文複習 Docker 相關概念與指令。

## 基本結構

使用 Dockerfile 讓使用者可以建立自定義的映像檔。Dockerfile 由一行一行的命令語句組成，並且支援以「`#`」開頭的註解行。

一般而言，Dockerfile 分為三個部分：基底映像檔資訊、映像檔操作指令和容器啟動時執行的指令。

```DOCKERFILE
# 基本映像檔，必須是第一個指令
FROM ubuntu

# 更新映像檔的指令
RUN echo "deb http://archive.ubuntu.com/ubuntu/ raring main universe" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# 啟動容器時要執行的指令
CMD /usr/sbin/nginx
```

其中，一開始必須指明作為基底的映像檔名稱。接著則是映像檔操作指令，例如 `RUN` 指令將對映像檔執行相對應的命令。每運行一條 `RUN` 指令，映像檔就會新增一層。最後是 `CMD` 指令，指定執行容器時的操作命令。

## 指令

### FROM

格式為 `FROM <image>` 或 `FROM <image>:<tag>`。

第一條指令必須為 `FROM` 指令。如果在同一個 Dockerfile 中建立多個映像檔時，可以使用多個 `FROM` 指令（每個映像檔一次）。

### RUN

格式為 `RUN <command>` 或 `RUN ["executable", "param1", "param2"]`。

前者將在 `shell` 終端中運行命令，即 `/bin/sh -c`；後者則使用 `exec` 執行。指定使用其它終端可以透過第二種方式實作，例如 `RUN ["/bin/bash", "-c", "echo hello"]`。

每條 `RUN` 指令將在當前映像檔基底上執行指定命令，並產生新的映像檔。當命令較長時可以使用 `\` 來換行。

### CMD

支援三種格式：

- `CMD ["executable","param1","param2"]`，使用 `/bin/sh -c` 執行，推薦使用；
- `CMD command param1 param2`，會被轉換成第一種格式，通常使用在需要互動的指令；
- `CMD ["param1","param2"]`，提供給 `ENTRYPOINT` 的預設參數；

指定啟動容器時執行的命令，每個 Dockerfile 只能有一條 `CMD` 命令。如果指定了多條命令，只有最後一條會被執行。

如果使用者啟動容器時候指定了運行的命令，則會覆蓋掉 `CMD` 指定的命令。

### EXPOSE

格式為 `EXPOSE <port> [<port>...]`。

設定 Docker 伺服器容器對外的埠號，供外界使用。在啟動容器時可以透過 `-P` 參數，Docker 會自動分配一個埠號轉發到指定的埠號。

### ENV

格式為 `ENV <key> <value>`。

指定一個環境變數，會被後續 `RUN` 指令使用，並在容器運行時保持。

### ADD

格式為 `ADD <src> <dest>`。

該命令將複製指定的 `<src>` 路徑到容器中的 `<dest>` 路徑。 其中 `<src>` 路徑可以是 Dockerfile 所在目錄的相對路徑；也可以是一個 URL；還可以是一個 `tar` 檔案，複製後會自動解壓縮。

### COPY

格式為 `COPY <src> <dest>`。

複製本地端的 `<src>` 路徑（即 Dockerfile 所在目錄的相對路徑）到容器中的 `<dest>`。

當使用本地目錄為根目錄時，推薦使用 `COPY` 指令。

### ENTRYPOINT

有兩種格式：

- `ENTRYPOINT ["executable", "param1", "param2"]`；
- `ENTRYPOINT command param1 param2`。

指定容器啟動後執行的命令，並且不會被 `docker run` 提供的參數覆蓋。

每個 Dockerfile 中只能有一個 ENTRYPOINT，當指定多個時，只有最後一個會生效。

### VOLUME

格式為 `VOLUME ["/data"]`。

建立一個可以從本地端或其他容器掛載的掛載點，一般用來存放資料庫和需要保存的資料等。

### USER

格式為 `USER daemon`。

指定運行容器時的使用者名稱或 UID，後續的 `RUN` 也會使用指定使用者。

當服務不需要管理員權限時，可以透過該命令指定運行使用者。並且可以在之前建立所需要的使用者，例如：`RUN groupadd -r postgres && useradd -r -g postgres postgres`。要臨時取得管理員權限可以使用 `gosu`，而不推薦 `sudo`。

### WORKDIR

格式為 `WORKDIR /path/to/workdir`。

為後續的 `RUN`、`CMD`、`ENTRYPOINT` 指令指定工作目錄。

可以使用多個 WORKDIR 指令，後續命令如果參數是相對路徑，則會基於之前命令指定的路徑。

## 建立映像檔

編輯完成 Dockerfile 之後，可以透過 `docker build` 命令建立映像檔。

基本的格式為 `docker build [OPTIONS] PATH`，該命令將讀取指定路徑下（包括子目錄）的 Dockerfile，並將該路徑下所有內容發送給 Docker 伺服端，由伺服端來建立映像檔。

可以透過 `.dockerignore` 檔案（每一行新增一條排除模式）來讓 Docker 忽略路徑下的目錄和檔案。

要指定映像檔的標籤資訊，可以透過 `-t` 參數，例如：

```BASH
docker build -t myrepo/myapp /tmp/test/
```

## 參考資料

- [Docker：從入門到實踐](https://github.com/yeasy/docker_practice)
