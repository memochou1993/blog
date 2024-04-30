---
title: 使用 AWS Lambda 和 CDK 為 FastAPI 專案建立 REST API 無伺服器應用程式
date: 2024-04-30 18:04:05
tags: ["Deployment", "AWS", "Lambda", "Serverless", "CDK", "IaC", "Python", "FastAPI"]
categories: ["Cloud Computing Service", "AWS"]
---

## 建立專案

建立專案。

```bash
mkdir lambda-fastapi-example
cd lambda-fastapi-example
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
poetry add fastapi mangum
poetry add aws-cdk-lib poetry-plugin-export pytest python-dotenv ruff uvicorn --dev
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

在 `app/auth` 資料夾建立空的 `__init__.py` 檔，以及 `api_key_header.py` 檔，用來產生具有認證功能的文件。

```py
from fastapi.security.api_key import APIKeyHeader

api_key_header = APIKeyHeader(name="x-api-key", auto_error=False)
```

在 `app/handlers` 資料夾建立空的 `__init__.py` 檔，以及 `item_handler.py` 檔，用來放置主要的範例程式。

```py
from auth.api_key_header import api_key_header
from fastapi import APIRouter, Request, Security
from pydantic import BaseModel


class Item(BaseModel):
    name: str | None = None
    description: str | None = None
    price: float | None = None
    tax: float = 10.5
    tags: list[str] = []


items = [
    {"name": "Foo", "price": 50.2},
    {"name": "Bar", "description": "The bartenders", "price": 62, "tax": 20.2},
    {"name": "Baz", "description": None, "price": 50.2, "tax": 10.5, "tags": []},
]

router = APIRouter(tags=["Item"], prefix="/items")


@router.get("")
async def listItems(req: Request, api_key: str = Security(api_key_header)):
    return {"data": items}


@router.post("")
async def createItem(req: Request, item: Item, api_key: str = Security(api_key_header)):
    items.append(item)

    return {"data": item}


@router.get("/{item_id}")
async def getItem(req: Request, item_id: int, api_key: str = Security(api_key_header)):
    return {"data": items[item_id]}


@router.put("/{item_id}")
async def updateItem(req: Request, item_id: int, item: Item, api_key: str = Security(api_key_header)):
    items[item_id] = item

    return {"data": item}


@router.delete("/{item_id}")
async def deleteItem(req: Request, item_id: int, api_key: str = Security(api_key_header)):
    del items[item_id]

    return {"data": {}}
```

在 `app` 資料夾建立空的 `__init__.py` 檔，以及 `main.py` 檔，用來初始化 FastAPI 應用程式。

```py
from fastapi import FastAPI, Request
from handlers import item_handler
from mangum import Mangum

app = FastAPI(root_path="/production", title="Lambda FastAPI Example API")


@app.get("", include_in_schema=False)
@app.get("/", tags=["Root"])
async def root(req: Request):
    return {
        "message": "Hello, World!",
        "root_path": req.scope.get("root_path"),
    }


app.include_router(item_handler.router, prefix="/api")
handler = Mangum(app, lifespan="off")
```

啟動服務。

```bash
cd app
uvicorn main:app --reload
```

## 建立堆疊

把 CDK 建立的 `lambda_fastapi_example` 資料夾更名為 `deployment`。

```bash
mv lambda_fastapi_example deployment
```

修改 `app.py` 檔。

```py
import os

import aws_cdk
from dotenv import load_dotenv

from deployment.lambda_fastapi_example_stack import LambdaFastapiExampleStack

load_dotenv()

app = aws_cdk.App()

env = aws_cdk.Environment(
    account=os.environ.get("CDK_DEFAULT_ACCOUNT"),
    region=os.environ.get("CDK_DEFAULT_REGION"),
)

LambdaFastapiExampleStack(
    app,
    "LambdaFastapiExampleStack",
    env=env,
)

app.synth()
```

修改 `deployment/lambda_fastapi_example_stack.py` 檔。

```py
import os

from aws_cdk import BundlingOptions, Duration, Size, Stack, aws_apigateway, aws_ec2, aws_iam, aws_lambda, aws_logs
from constructs import Construct


class LambdaFastapiExampleStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        self.vpc = self.create_vpc()
        self.lambda_function = self.create_lambda_function()
        self.api_gateway = self.create_api_gateway()

    def create_vpc(self):
        vpc = aws_ec2.Vpc.from_lookup(
            self,
            "SelectedVpc",
            vpc_id=os.environ.get("AWS_VPC_ID"),
        )

        return vpc

    def create_lambda_function(self):
        lambda_role = aws_iam.Role(
            self,
            "LambdaFastapiExampleLambdaRole",
            description="Lambda FastAPI Example Lambda Role",
            assumed_by=aws_iam.CompositePrincipal(
                aws_iam.ServicePrincipal("lambda.amazonaws.com"),
            ),
        )
        lambda_role.add_managed_policy(
            aws_iam.ManagedPolicy.from_managed_policy_arn(
                self,
                "LambdaFastapiExampleAWSLambdaBasicExecutionRolePolicy",
                "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
            )
        )
        lambda_role.add_managed_policy(
            aws_iam.ManagedPolicy.from_managed_policy_arn(
                self,
                "LambdaFastapiExampleAWSLambdaVPCAccessExecutionRolePolicy",
                "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
            )
        )

        layer = aws_lambda.LayerVersion(
            self,
            "LambdaFastapiExampleLambdaLayer",
            description="Lambda FastAPI Example Lambda Layer",
            code=aws_lambda.Code.from_asset(
                "deployment/layer",
                bundling=BundlingOptions(
                    image=aws_lambda.Runtime.PYTHON_3_12.bundling_image,
                    command=[
                        "bash",
                        "-c",
                        "pip install --no-cache -r requirements.txt -t /asset-output/python && cp -au . /asset-output/python",
                    ],
                ),
            ),
            compatible_architectures=[
                aws_lambda.Architecture.ARM_64,
            ],
            compatible_runtimes=[
                aws_lambda.Runtime.PYTHON_3_12,
            ],
        )

        lambda_function = aws_lambda.Function(
            self,
            "LambdaFastapiExampleLambdaFunction",
            description="Lambda FastAPI Example Lambda Function",
            runtime=aws_lambda.Runtime.PYTHON_3_12,
            code=aws_lambda.Code.from_asset("app"),
            handler="main.handler",
            architecture=aws_lambda.Architecture.ARM_64,
            memory_size=512,
            timeout=Duration.seconds(30),
            vpc=self.vpc,
            vpc_subnets=aws_ec2.SubnetSelection(subnet_type=aws_ec2.SubnetType.PRIVATE_WITH_EGRESS, one_per_az=True),
            role=lambda_role,
            layers=[
                layer,
            ],
            environment={},
        )

        return lambda_function

    def create_api_gateway(self):
        log_group = aws_logs.LogGroup(
            self,
            "LambdaFastapiExampleLogGroup",
            retention=aws_logs.RetentionDays.ONE_MONTH,
        )

        api_gateway = aws_apigateway.RestApi(
            self,
            "LambdaFastapiExampleApiGateway",
            description="Lambda FastAPI Example Api Gateway",
            min_compression_size=Size.kibibytes(1),
            endpoint_types=[
                aws_apigateway.EndpointType.REGIONAL,
            ],
            cloud_watch_role=True,
            deploy_options=aws_apigateway.StageOptions(
                stage_name="production",
                metrics_enabled=True,
                access_log_destination=aws_apigateway.LogGroupLogDestination(log_group),
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

        usage_plan = api_gateway.add_usage_plan(
            "LambdaFastapiExampleUsagePlan",
            description="Lambda FastAPI Example Usage Plan",
            throttle=aws_apigateway.ThrottleSettings(
                burst_limit=50,
                rate_limit=100,
            ),
        )

        api_key = aws_apigateway.ApiKey(
            self,
            "LambdaFastapiExampleApiKey",
            description="Lambda FastAPI Example Api Key",
        )

        usage_plan.add_api_key(api_key)

        lambda_integration = aws_apigateway.LambdaIntegration(self.lambda_function)

        api_gateway.root.add_method("GET", lambda_integration)

        proxy_resource = api_gateway.root.add_resource("{proxy+}")
        proxy_resource.add_cors_preflight(
            allow_origins=aws_apigateway.Cors.ALL_ORIGINS,
            allow_methods=aws_apigateway.Cors.ALL_METHODS,
            max_age=Duration.hours(1),
        )
        proxy_method = proxy_resource.add_method("ANY", lambda_integration, api_key_required=True)

        usage_plan.add_api_stage(
            stage=api_gateway.deployment_stage,
            throttle=[
                aws_apigateway.ThrottlingPerMethod(
                    method=proxy_method,
                    throttle=aws_apigateway.ThrottleSettings(
                        burst_limit=50,
                        rate_limit=100,
                    ),
                ),
            ],
        )

        return api_gateway
```

## 建立套件描述檔

新增 `scripts/export-requirements.sh` 檔，用來輸出依賴套件描述檔。

```bash
poetry export --without dev --without-hashes --output deployment/layer/requirements.txt
```

修改腳本權限。

```bash
chmod +x scripts/export-requirements.sh
```

建立 `deployment/layer` 資料夾。

```bash
mkdir deployment/layer
```

執行腳本，以輸出套件描述檔。

```bash
./scripts/export-requirements.sh
```

產生的 `deployment/layer/requirements.txt` 檔如下：

```txt
annotated-types==0.6.0 ; python_version >= "3.12" and python_version < "4.0"
anyio==4.3.0 ; python_version >= "3.12" and python_version < "4.0"
fastapi==0.110.2 ; python_version >= "3.12" and python_version < "4.0"
idna==3.7 ; python_version >= "3.12" and python_version < "4.0"
mangum==0.17.0 ; python_version >= "3.12" and python_version < "4.0"
pydantic-core==2.18.2 ; python_version >= "3.12" and python_version < "4.0"
pydantic==2.7.1 ; python_version >= "3.12" and python_version < "4.0"
sniffio==1.3.1 ; python_version >= "3.12" and python_version < "4.0"
starlette==0.37.2 ; python_version >= "3.12" and python_version < "4.0"
typing-extensions==4.11.0 ; python_version >= "3.12" and python_version < "4.0"
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

- [lambda-fastapi-example](https://github.com/memochou1993/lambda-fastapi-example)

## 參考資料

- [AWS - CDK](https://docs.aws.amazon.com/cdk/api/v2/)
- [Simple Serverless FastAPI with AWS Lambda](https://www.deadbear.io/simple-serverless-fastapi-with-aws-lambda/)
