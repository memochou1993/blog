---
title: 使用 CDK 在 Amazon Cognito 服務建立資源
date: 2024-05-20 02:44:03
tags: ["Deployment", "AWS", "Cognito", "CDK", "IaC", "Python"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立專案

建立專案。

```bash
mkdir cdk-cognito-example
cd cdk-cognito-example
```

使用 CDK 初始化專案。

```bash
cdk init app --language python
```

修改 `cdk_s3_cloudfront_example` 資料夾名稱。

```bash
mv cdk_cognito_example deployment
```

修改 `app.py` 檔。

```py
import os

import aws_cdk

from deployment.cdk_cognito_example_stack import CdkCognitoExampleStack

app = aws_cdk.App()

env = aws_cdk.Environment(
    account=os.environ.get("CDK_DEFAULT_ACCOUNT"),
    region=os.environ.get("CDK_DEFAULT_REGION"),
)

CdkCognitoExampleStack(app, "CdkCognitoExampleStack", env=env)

app.synth()
```

修改 `cdk_cognito_example_stack.py` 檔。

```py
import json

from aws_cdk import (Duration, RemovalPolicy, Stack, aws_cloudfront,
                     aws_cloudfront_origins, aws_cognito, aws_s3, aws_ssm)
from constructs import Construct


class CdkCognitoExampleStack(Stack):
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

    # 建立一個 Cognito 使用者池
    def create_cognito_user_pool(self):
        ui_domain = self.cloudfront_distribution.domain_name
        user_pool = aws_cognito.UserPool(
            self,
            'UserPool',
            auto_verify=aws_cognito.AutoVerifiedAttrs(email=True),
            user_invitation=aws_cognito.UserInvitationConfig(
                email_subject='Your temporary password for Example Service',
                email_body=f"""<p>Hello {{username}}, </p>
<p>Here is your Example Service account details:</p>
<ul>
  <li>Username: {{username}}</li>
  <li>Temporary Password: {{####}}</li>
</ul>
<p>Please go to the following URL to reset your password and activate your account:\nhttps://{ui_domain}</p>
""",
            ),
            removal_policy=RemovalPolicy.RETAIN,
        )

        user_pool.add_client(
            'UserPoolClient',
            auth_flows=aws_cognito.AuthFlow(admin_user_password=True, custom=True, user_password=True, user_srp=True),
            o_auth=aws_cognito.OAuthSettings(
                flows=aws_cognito.OAuthFlows(authorization_code_grant=True),
                scopes=[
                    aws_cognito.OAuthScope.OPENID,
                    aws_cognito.OAuthScope.PROFILE,
                    aws_cognito.OAuthScope.EMAIL,
                ],
                callback_urls=[
                    'http://localhost:3000/auth/callback',
                    f'https://{ui_domain}/auth/callback',
                ],
                logout_urls=[
                    'http://localhost:3000/sign-in',
                    f'https://{ui_domain}/sign-in',
                ],
            ),
            access_token_validity=Duration.days(1),
            id_token_validity=Duration.days(1),
            refresh_token_validity=Duration.days(30),
        )

        user_pool.add_domain(
            'UserPoolDomain',
            cognito_domain=aws_cognito.CognitoDomainOptions(
                domain_prefix='cognito-example',
            ),
        )

        return user_pool
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

啟動專案。

```bash
npm run dev
```

前往 <http://localhost:5174> 瀏覽。

## 程式碼

- [cdk-cognito-example](https://github.com/memochou1993/cdk-cognito-example)

## 參考資料

- [AWS - CDK](https://docs.aws.amazon.com/cdk/api/v2/)
