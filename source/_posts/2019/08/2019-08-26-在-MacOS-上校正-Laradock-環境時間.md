---
title: 在 macOS 上校正 Laradock 環境時間
date: 2019-08-26 22:07:08
tags: ["環境部署", "Docker", "Laradock"]
categories: ["環境部署", "Laradock"]
---

## 步驟

修改 `.env` 檔，開啟 SSH 連線。

```env
WORKSPACE_INSTALL_WORKSPACE_SSH=true
```

修改 `insecure_id_rsa` 檔的權限。

```bash
chmod 0600 workspace/insecure_id_rsa
```

修改 `docker-compose.yml` 檔

```yaml
workspace:
  ...
  privileged: true
```

重建 `workspace` 容器。

```bash
docker-compose build workspace
```

校正時間。

```bash
ssh -p 2222 -i workspace/insecure_id_rsa root@localhost date -u $(date +%m%d%H%M%Y)
```
