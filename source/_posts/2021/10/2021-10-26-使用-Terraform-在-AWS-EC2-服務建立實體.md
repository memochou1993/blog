---
title: 使用 Terraform 在 AWS EC2 服務建立實體
date: 2021-10-26 16:59:49
tags: ["環境部署", "Terraform", "AWS", "EC2"]
categories: ["環境部署", "Terraform"]
---

## 做法

建立工作資料夾。

```bash
mkdir -p terraform-practice/ec2
cd terraform-practice/ec2
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
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# 指定為 AWS Provider
provider "aws" {
  region = "ap-northeast-1"
}

# 找出要使用的子網路
data "aws_subnet" "my-subnet" {
  id = "subnet-xxxxxxyyyyyyzzzzz"
}

# 找出要使用的安全群組
data "aws_security_group" "my-security_group" {
  id = "sg-xxxxxxyyyyyyzzzzz"
}

# 建立一個網路界面
resource "aws_network_interface" "my-interface" {
  # 指定子網路
  subnet_id = data.aws_subnet.my-subnet.id
  # 指定安全群組
  security_groups = [ data.aws_security_group.my-security_group.id ]
}

# 建立一個實體
resource "aws_instance" "my-server" {
  ami = "ami-xxxxxxyyyyyyzzzzz"
  instance_type = "t2.micro"
  # 指定網路界面
  network_interface {
    network_interface_id = aws_network_interface.my-interface.id
    device_index = 0
  }
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
