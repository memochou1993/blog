---
title: 使用 AWS Lambda 和 CDK 為 Python 專案建立 REST API 無伺服器應用程式
date: 2024-04-27 23:04:05
tags: ["Deployment", "AWS", "Lambda", "Serverless", "CDK", "IaC", "Python"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立專案

建立專案。

```bash
mkdir lambda-python-example
cd lambda-python-example
```

使用 CDK 初始化專案。

```bash
cdk init app --language python
```

新增 `.env.example` 檔。

```env
AWS_VPC_ID=
```

新增 `.env` 檔。

```env
AWS_VPC_ID=your-vpc-id
```

修改 `.gitignore` 檔。

```env
# ...
.env

# CDK asset staging directory
# ...
cdk.context.json
```

## 安裝依賴套件

使用 Poetry 初始化專案。

```bash
poetry init
```

安裝依賴套件。

```bash
poetry add aws-cdk-lib python-dotenv ruff
poetry add pytest --dev
```

啟動虛擬環境。

```bash
poetry shell
```

刪除 CDK 建立的 `requirements.txt` 相關檔案。

```bash
rm requirements.txt requirements-dev.txt source.bat
```

新增 `ruff.toml` 檔。

```toml
line-length = 120
indent-width = 4

[format]
quote-style = "double"
```

新增 `.vscode/settings.json` 檔。

```json
{
    "[python]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "charliermarsh.ruff"
    }
}
```

## 建立函式

建立 `lambda/hello.py` 檔。

```py
import json


def handler(event, context):
    print("request: {}".format(json.dumps(event)))
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/plain"},
        "body": json.dumps(
            {
                "message": "Hello, CDK! You have hit {}".format(event["path"]),
            }
        ),
    }
```

## 建立堆疊

把 CDK 建立的 `lambda_python_example` 資料夾更名為 `deployment`。

```bash
mv lambda_python_example deployment
```

修改 `app.py` 檔。

```py
import os

import aws_cdk
from dotenv import load_dotenv

from deployment.lambda_python_example_stack import LambdaPythonExampleStack

load_dotenv()

app = aws_cdk.App()

env = aws_cdk.Environment(
    account=os.environ.get("CDK_DEFAULT_ACCOUNT"),
    region=os.environ.get("CDK_DEFAULT_REGION"),
)

LambdaPythonExampleStack(
    app,
    "LambdaPythonExampleStack",
    env=env,
)

app.synth()
```

修改 `deployment/lambda_python_example_stack.py` 檔。

```py
import os

from aws_cdk import Duration, Size, Stack, aws_apigateway, aws_ec2, aws_iam, aws_lambda, aws_logs
from constructs import Construct


class LambdaPythonExampleStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create VPC
        self.vpc = self.create_vpc()

        # Create Lambda function
        self.lambda_function = self.create_lambda_function()

        # Create API Gateway
        self.api_gateway = self.create_api_gateway()

    def create_vpc(self):
        # Retrieve existing VPC
        vpc = aws_ec2.Vpc.from_lookup(
            self,
            "SelectedVpc",
            vpc_id=os.environ.get("AWS_VPC_ID"),
        )

        return vpc

    def create_lambda_function(self):
        # Create Lambda execution role
        lambda_role = aws_iam.Role(
            self,
            "LambdaPythonExampleLambdaRole",
            description="Lambda Python Example Lambda Role",
            assumed_by=aws_iam.CompositePrincipal(
                aws_iam.ServicePrincipal("lambda.amazonaws.com"),
            ),
        )
        
        # Attach policies to Lambda role
        lambda_role.add_managed_policy(
            aws_iam.ManagedPolicy.from_managed_policy_arn(
                self,
                "LambdaPythonExampleAWSLambdaBasicExecutionRolePolicy",
                "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
            )
        )
        lambda_role.add_managed_policy(
            aws_iam.ManagedPolicy.from_managed_policy_arn(
                self,
                "LambdaPythonExampleAWSLambdaVPCAccessExecutionRolePolicy",
                "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
            )
        )

        # Create Lambda function
        lambda_function = aws_lambda.Function(
            self,
            "LambdaPythonExampleLambdaFunction",
            description="Lambda Python Example Lambda Function",
            runtime=aws_lambda.Runtime.PYTHON_3_11,
            code=aws_lambda.Code.from_asset("lambda"),
            handler="hello.handler",
            architecture=aws_lambda.Architecture.ARM_64,
            memory_size=512,
            timeout=Duration.seconds(30),
            vpc=self.vpc,  # Lambda function runs inside the specified VPC
            vpc_subnets=aws_ec2.SubnetSelection(subnet_type=aws_ec2.SubnetType.PRIVATE_WITH_EGRESS, one_per_az=True),
            role=lambda_role,
            environment={},
        )

        return lambda_function

    def create_api_gateway(self):
        # Create CloudWatch log group for API Gateway
        log_group = aws_logs.LogGroup(
            self,
            "LambdaPythonExampleLogGroup",
            retention=aws_logs.RetentionDays.ONE_MONTH,
        )

        # Create API Gateway
        api_gateway = aws_apigateway.RestApi(
            self,
            "LambdaPythonExampleApiGateway",
            description="Lambda Python Example Api Gateway",
            min_compression_size=Size.kibibytes(1),
            endpoint_types=[aws_apigateway.EndpointType.REGIONAL],
            cloud_watch_role=True,  # Enables logging to CloudWatch
            deploy_options=aws_apigateway.StageOptions(
                stage_name="production",
                metrics_enabled=True,
                access_log_destination=aws_apigateway.LogGroupLogDestination(log_group),  # Send access logs to CloudWatch
                access_log_format=aws_apigateway.AccessLogFormat.json_with_standard_fields(
                    caller=True,
                    http_method=True,
                    ip=True,
                    protocol=True,
                    request_time=True,
                    resource_path=True,
                    response_length=True,
                    status=True,
                    user=True,
                ),
            ),
        )

        # Create usage plan for API Gateway
        usage_plan = api_gateway.add_usage_plan(
            "LambdaPythonExampleUsagePlan",
            description="Lambda Python Example Usage Plan",
            throttle=aws_apigateway.ThrottleSettings(
                burst_limit=50,
                rate_limit=100,
            ),
        )

        # Create API key
        api_key = aws_apigateway.ApiKey(
            self,
            "LambdaPythonExampleApiKey",
            description="Lambda Python Example Api Key",
        )

        usage_plan.add_api_key(api_key)

        # Create API resources and methods
        v1_resource = api_gateway.root.add_resource("v1")
        v1_resource.add_cors_preflight(
            allow_origins=aws_apigateway.Cors.ALL_ORIGINS,
            allow_methods=aws_apigateway.Cors.ALL_METHODS,
            max_age=Duration.hours(1),
        )
        v1_method = v1_resource.add_method(
            "GET",
            aws_apigateway.LambdaIntegration(self.lambda_function),  # Integration with Lambda function
            api_key_required=True,
        )
        api_resource = v1_resource.add_resource("{path+}")
        api_resource.add_cors_preflight(
            allow_origins=aws_apigateway.Cors.ALL_ORIGINS,
            allow_methods=aws_apigateway.Cors.ALL_METHODS,
            max_age=Duration.hours(1),
        )
        api_method = api_resource.add_method(
            "ANY",
            aws_apigateway.LambdaIntegration(self.lambda_function),  # Integration with Lambda function
            api_key_required=True,
        )

        # Add throttling settings to usage plan
        usage_plan.add_api_stage(
            stage=api_gateway.deployment_stage,
            throttle=[
                aws_apigateway.ThrottlingPerMethod(
                    method=v1_method,
                    throttle=aws_apigateway.ThrottleSettings(
                        burst_limit=50,
                        rate_limit=100,
                    ),
                ),
                aws_apigateway.ThrottlingPerMethod(
                    method=api_method,
                    throttle=aws_apigateway.ThrottleSettings(
                        burst_limit=50,
                        rate_limit=100,
                    ),
                ),
            ],
        )

        return api_gateway
```

## 部署

部署應用程式。

```bash
aws-vault exec your-profile -- cdk deploy
```

如果要清理的話，移除應用程式。

```bash
aws-vault exec your-profile -- cdk destroy
```

## 程式碼

- [lambda-python-example](https://github.com/memochou1993/lambda-python-example)

## 參考資料

- [AWS - CDK](https://docs.aws.amazon.com/cdk/api/v2/)
