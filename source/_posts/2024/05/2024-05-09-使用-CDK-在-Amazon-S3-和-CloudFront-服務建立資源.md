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
from aws_cdk import RemovalPolicy, Stack, aws_cloudfront, aws_cloudfront_origins, aws_s3
from constructs import Construct


class CdkS3CloudfrontExampleStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        self.s3_bucket = self.create_s3_bucket()
        self.cloudfront_distribution = self.create_cloudfront_distribution()

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

        s3_bucket.add_cors_rule(
            allowed_methods=[aws_s3.HttpMethods.GET, aws_s3.HttpMethods.HEAD],
            allowed_headers=["*"],
            allowed_origins=["*"],
            max_age=3600,
        )

        return s3_bucket

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

## 程式碼

- [cdk-s3-cloudfront-example](https://github.com/memochou1993/cdk-s3-cloudfront-example)

## 參考資料

- [AWS - CDK](https://docs.aws.amazon.com/cdk/api/v2/)
