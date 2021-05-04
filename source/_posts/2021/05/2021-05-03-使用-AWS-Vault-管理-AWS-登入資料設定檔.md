---
title: 使用 AWS Vault 管理 AWS 登入資料設定檔
permalink: 使用-AWS-Vault-管理-AWS-登入資料設定檔
date: 2021-05-03 23:11:34
tags: ["環境部署", "AWS", "雲端運算服務"]
categories: ["其他", "雲端運算服務"]
---

## 做法

安裝 `aws-vault` 執行檔。

```BASH
brew install --cask aws-vault
```

修改 `~/.aws/config` 檔，並使用 AWS Single Sign-On 的配置：

```BASH
[default]
region=ap-northeast-1

[profile playground-PowerUser]
sso_start_url=https://my-portal.awsapps.com/start
sso_region=us-east-1
sso_account_id=123456789012
sso_role_name=PowerUserAccess
output=json
```

開啟瀏覽器，以 AWS SSO 登入。

```BASH
aws-vault login --backend=file playground-PowerUser
```

執行 `aws` 指令。

```BASH
aws-vault exec --backend=file playground-PowerUser -- aws s3 ls
```

## 參考資料

- [Usage - AWS Vault](https://github.com/99designs/aws-vault/blob/master/USAGE.md#aws-single-sign-on-aws-sso)
