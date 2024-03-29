---
title: 使用 AWS Vault 管理 AWS 登入資料設定檔
date: 2021-05-03 23:11:34
tags: ["Deployment", "AWS", "Cloud Computing Service"]
categories: ["Cloud Computing Service", "AWS"]
---

## 做法

安裝 `aws-vault` 執行檔。

```bash
brew install --cask aws-vault
```

修改 `~/.aws/config` 檔，並使用 AWS Single Sign-On 的配置：

```bash
[default]
region=ap-northeast-1

[profile playground-PowerUser]
sso_start_url=https://my-portal.awsapps.com/start
sso_region=us-east-1
sso_account_id=123456789012
sso_role_name=PowerUserAccess
output=json
```

添加環境變數。

```bash
export AWS_VAULT_BACKEND=file
export AWS_VAULT_FILE_PASSPHRASE=root
```

使用以下命令，以 AWS SSO 登入。

```bash
aws-vault login playground-PowerUser
```

使用以下命令，執行 `aws` 指令。

```bash
aws-vault exec playground-PowerUser -- aws s3 ls
```

## 參考資料

- [Usage - AWS Vault](https://github.com/99designs/aws-vault/blob/master/USAGE.md#aws-single-sign-on-aws-sso)
