---
title: 使用 CDK 在 Amazon S3 和 CloudFront 服務建立資源
date: 2024-05-09 00:59:27
tags: ["Deployment", "AWS", "S3", "CloudFront", "CDK", "IaC", "Python"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立專案

建立專案。

```bash
mkdir cdk-s3-cloudfront-example
cd cdk-s3-cloudfront-example
```

使用 CDK 初始化專案。

```bash
cdk init app --language python
```

修改 `app.py` 檔。

```py
import os

import aws_cdk

from deployment.cdk_s3_cloudfront_example_stack import CdkS3CloudfrontExampleStack

app = aws_cdk.App()

env = aws_cdk.Environment(
    account=os.environ.get("CDK_DEFAULT_ACCOUNT"),
    region=os.environ.get("CDK_DEFAULT_REGION"),
)

CdkS3CloudfrontExampleStack(app, "CdkS3CloudfrontExampleStack", env=env)

app.synth()
```

修改 `cdk_s3_cloudfront_example_stack.py` 檔。

```py
import json

from aws_cdk import RemovalPolicy, Stack, aws_cloudfront, aws_cloudfront_origins, aws_s3, aws_ssm
from constructs import Construct


class CdkS3CloudfrontExampleStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        self.s3_bucket = self.create_s3_bucket()
        self.cloudfront_distribution = self.create_cloudfront_distribution()

    # 建立一個 S3 bucket，用於存放前端靜態檔案
    def create_s3_bucket(self):
        s3_bucket = aws_s3.Bucket(
            self,
            "Bucket",
            block_public_access=aws_s3.BlockPublicAccess.BLOCK_ALL,
            encryption=aws_s3.BucketEncryption.S3_MANAGED,
            access_control=aws_s3.BucketAccessControl.PRIVATE,
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
        )

        return s3_bucket

    # 建立一個 CloudFront 分佈，為前端靜態檔案建立 CDN 分布
    def create_cloudfront_distribution(self):
        cloudfront_distribution = aws_cloudfront.Distribution(
            self,
            "CloudFrontDistribution",
            default_behavior=aws_cloudfront.BehaviorOptions(
                origin=aws_cloudfront_origins.S3Origin(self.s3_bucket),
                compress=True,
                viewer_protocol_policy=aws_cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
            ),
            default_root_object="index.html",
        )

        return cloudfront_distribution

    # 建立一個 SSM 參數，提供前端 CI/CD 腳本使用
    def create_ssm_string_param(self):
        ssm_name = '/output/s3-cloudfront-stack'

        ssm_string_param = aws_ssm.StringParameter(
            self,
            'SsmStringParam',
            parameter_name=ssm_name,
            string_value=json.dumps(
                {
                    's3_bucket_name': self.s3_bucket.bucket_name,
                    'cloudfront_distribution_id': self.cloudfront_distribution.distribution_id,
                }
            ),
            tier=aws_ssm.ParameterTier.STANDARD,
        )

        ssm_string_param.apply_removal_policy(RemovalPolicy.DESTROY)

        return ssm_string_param
```

## 部署

啟動初始化程序。

```bash
aws-vault exec your-profile -- cdk bootstrap
```

部署應用程式。

```bash
aws-vault exec your-profile -- cdk deploy
```

如果要清理的話，移除應用程式。

```bash
aws-vault exec your-profile -- cdk destroy
```

## 自動化部署

建立 `.gitlab-ci.yml` 檔。

```yaml
stages:
  - build
  - deploy

variables:
  AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION

build:
  stage: build
  image: node:20
  before_script:
    - npm install
  script:
    - npm run generate
  artifacts:
    paths:
      - .output/public/
  only:
    refs:
      - /^(\d+\.)+(\d+\.)+(\d+)+$/

deploy:
  stage: deploy
  image:
    name: amazon/aws-cli:latest
    entrypoint: [""]
  before_script:
    - yum install -y jq
  script:
    - export STACK_PARAMETERS=$(aws ssm get-parameter --name "/output/s3-cloudfront-stack" --query "Parameter.Value" --output text)
    - export S3_BUCKET_NAME=$(echo $STACK_PARAMETERS | jq -r .s3_bucket_name)
    - export CLOUDFRONT_DISTRIBUTION_ID=$(echo $STACK_PARAMETERS | jq -r .cloudfront_distribution_id)
    - aws s3 sync --delete .output/public/ s3://$S3_BUCKET_NAME/
    - aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/index.html"
  only:
    refs:
      - /^(\d+\.)+(\d+\.)+(\d+)+$/
```

## 程式碼

- [cdk-s3-cloudfront-example](https://github.com/memochou1993/cdk-s3-cloudfront-example)

## 參考資料

- [AWS - CDK](https://docs.aws.amazon.com/cdk/api/v2/)
