---
title: 使用 helm-secrets 管理 secrets 檔案
date: 2022-06-20 12:09:38
tags: ["Deployment", "Kubernetes", "Helm"]
categories: ["Deployment", "Kubernetes", "Helm"]
---

## 做法

安裝 `helm-secrets` 外掛。

```bash
helm plugin install https://github.com/jkroepke/helm-secrets
```

安裝 `sops` 工具。

```bash
brew install sops
```

修改 `secrets.prod.yaml` 檔，將應用程式所需要的環境變數填入。

```yaml
API_KEY: ...
SECRET: ...
```

新增 `.sops.yaml` 檔，將 `kms` 資訊填入。

```yaml
---
creation_rules:
  - path_regex: \.prod\.yaml
    kms: "arn:aws:kms:ap-northeast-1:...:key/..."
  - kms: "arn:aws:kms:ap-northeast-1:...:key/..."
```

對 `secrets.prod.yaml` 檔解密。

```bash
aws-vault exec playground -- helm secrets dec secrets.prod.yaml
```

對 `secrets.prod.yaml.dec` 檔加密。

```bash
aws-vault exec playground -- helm secrets enc secrets.prod.yaml.dec
```
