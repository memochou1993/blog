---
title: 使用 Terraform 在 Amazon VPC 服務建立資源
date: 2023-06-10 14:03:29
tags: ["Deployment", "Terraform", "AWS", "VPC"]
categories: ["Deployment", "Terraform"]
---

## 做法

新增 `variables.tf` 檔。

```tf
variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "app_environment" {
  type        = string
  description = "Application Environment"
}
```

新增 `terraform.tfvars` 檔。

```tf
aws_region      = "ap-northeast-1"
app_name        = "my-project"
app_environment = "staging"
```

新增 `vpc.tf` 檔。

```tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "ipv6"
  cidr = "10.0.0.0/16"

  azs              = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets   = ["10.0.0.0/19", "10.0.32.0/19"]
  private_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]
  database_subnets = ["10.0.128.0/19", "10.0.160.0/19"]

  enable_nat_gateway = true

  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true

  private_subnet_assign_ipv6_address_on_creation = false

  public_subnet_ipv6_prefixes   = [0, 1]
  private_subnet_ipv6_prefixes  = [2, 3]
  database_subnet_ipv6_prefixes = [4, 5]

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}
```

## 參考資料

- [Terraform - aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
