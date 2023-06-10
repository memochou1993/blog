---
title: 使用 Terraform 在 AWS S3 服務建立資源
date: 2022-02-17 23:14:29
tags: ["環境部署", "Terraform", "AWS", "S3", "Storage Service"]
categories: ["環境部署", "Terraform"]
---

## 做法

建立工作資料夾。

```bash
mkdir -p terraform-practice/s3
cd terraform-practice/s3
```

使用 `init` 指令初始化工作資料夾，需要的供應商外掛（provider plugins）將會被下載下來。

```bash
terraform init
```

在工作資料夾新增 `main.tf` 檔：

```tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.1.0"
    }
  }

  required_version = ">= 1.1"
}

# 指定為 AWS Provider
provider "aws" {
  region  = "ap-northeast-1"
}

# 建立一個儲存貯體
resource "aws_s3_bucket" "xxx-playground-s3-test" {
  bucket = "xxx-playground-s3-test"
}
```

使用 `plan` 指令查看執行計畫。

```bash
aws-vault exec --backend=file playground-PowerUser -- terraform plan
```

使用 `apply` 指令建立實體。

```bash
aws-vault exec --backend=file playground-PowerUser -- terraform apply
```

使用 `destroy` 指令刪除實體。

```bash
aws-vault exec --backend=file playground-PowerUser -- terraform destroy
```

## 參考資料

- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
