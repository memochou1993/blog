---
title: 使用 GitLab 管理 Terraform 狀態
date: 2023-06-09 13:45:21
tags: ["Deployment", "Terraform", "GitLab", "IaC"]
categories: ["Deployment", "Terraform"]
---

## 做法

在專案根目錄新增 `.gitlab-ci.yml` 檔。

```yaml
include:
  - template: Terraform/Base.gitlab-ci.yml

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/staging
  TF_STATE_NAME: staging
  # TF_AUTO_DEPLOY: "true"

stages:
  - validate
  - test
  - build
  - deploy
  - cleanup

fmt:
  extends: .terraform:fmt
  needs: []

validate:
  extends: .terraform:validate
  needs: []

build:
  extends: .terraform:build
  environment:
    name: $TF_STATE_NAME
    action: prepare

deploy:
  extends: .terraform:deploy
  dependencies:
    - build
  environment:
    name: $TF_STATE_NAME
    action: start
```

在指定資料夾新增 `backend.tf` 檔。

```tf
terraform {
  backend "http" {
  }
}
```

在 GitLab 專案設定環境變數。

```
AWS_DEFAULT_REGION=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

推送專案。

## 轉移狀態

在 GitLab 生成一個存取令牌，並新增 `migrate.sh` 檔，然後執行腳本。

```bash
PROJECT_ID="<gitlab-project-id>"
TF_USERNAME="<gitlab-username>"
TF_PASSWORD="<gitlab-personal-access-token>"
TF_ADDRESS="https://gitlab.com/api/v4/projects/${PROJECT_ID}/terraform/state/old-state-name"

terraform init \
  -backend-config=address=${TF_ADDRESS} \
  -backend-config=lock_address=${TF_ADDRESS}/lock \
  -backend-config=unlock_address=${TF_ADDRESS}/lock \
  -backend-config=username=${TF_USERNAME} \
  -backend-config=password=${TF_PASSWORD} \
  -backend-config=lock_method=POST \
  -backend-config=unlock_method=DELETE \
  -backend-config=retry_wait_min=5
```

修改腳本，並執行。

```bash
TF_ADDRESS="https://gitlab.com/api/v4/projects/${PROJECT_ID}/terraform/state/new-state-name"

terraform init \
  -migrate-state \
  -backend-config=address=${TF_ADDRESS} \
  -backend-config=lock_address=${TF_ADDRESS}/lock \
  -backend-config=unlock_address=${TF_ADDRESS}/lock \
  -backend-config=username=${TF_USERNAME} \
  -backend-config=password=${TF_PASSWORD} \
  -backend-config=lock_method=POST \
  -backend-config=unlock_method=DELETE \
  -backend-config=retry_wait_min=5
```

## 參考資料

- [GitLab-managed Terraform state](https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html)
