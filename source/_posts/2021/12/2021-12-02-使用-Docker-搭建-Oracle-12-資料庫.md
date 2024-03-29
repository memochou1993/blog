---
title: 使用 Docker 搭建 Oracle 12 資料庫
date: 2021-12-02 20:11:26
tags: ["Database", "Oracle", "SQL", "Docker"]
categories: ["Database", "Oracle"]
---

## 做法

到 [Docker Store](https://store.docker.com/images/oracle-database-enterprise-edition) 頁面，登入後，完成試用申請，並執行以下指令：

```bash
docker pull store/oracle/database-enterprise:12.2.0.1
```

啟動映像檔。

```bash
docker run -d -it --name oracle-db -p 1521:1521 store/oracle/database-enterprise:12.2.0.1
```

檢查容器是否為 healthy 狀態。

```bash
docker ps
```

進入容器。

```bash
docker exec -it oracle-db bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
```

使用預設密碼 `Oradoc_db1` 建立連線。

```sql
connect sys as sysdba;
```

使用以下指令，開啟一個能夠創建使用者的工作階段。

```sql
alter session set "_ORACLE_SCRIPT"=true;
```

建立一個名為 `tester` 的使用者。

```sql
create user tester identified by tester;
```

將權限給予 `tester` 使用者。

```sql
grant connect, resource, dba to tester;
```

使用以下指令，關閉工作階段。

```sql
alter session set "_ORACLE_SCRIPT"=false;
```

關閉連線。

```sql
disconnect;
```

## 參考資料

- [在 Docker 中建立 Oracle 12c 的測試主機](https://yingclin.github.io/2018/create-oracle-docker-container.html)
