---
title: 為 Vue Router 的 History 模式設置 Amazon S3 和 CloudFront 的錯誤頁面重定向
date: 2024-05-25 21:30:50
tags: ["Programming", "JavaScript", "Vue", "Nuxt", "S3", "CloudFront"]
categories: ["Programming", "JavaScript", "Vue"]
---

## 前言

Vue 和 Nuxt 使用的 Vue Router 有兩種路由模式，一種是 hash 模式，另一種是 history 模式。在 history 模式下，URL 看起來更加乾淨，不會有 `#` 符號，但是這需要伺服器端支援，當使用者直接訪問帶有特定路徑的 URL 時，伺服器需要返回主要的 HTML 文件，而不是 404 錯誤頁面。

## 錯誤頁面重定向

CloudFront 是一個 CDN（Content Delivery Network），它會快取網站的內容以提高全球使用者的訪問速度。當 CloudFront 收到 403 或 404 錯誤時，預設的行為是返回原始的錯誤頁面。需要透過 CloudFront 的設定來處理這些錯誤，將它們指向專案的 `index.html` 頁面。

CDK 範例如下：

```python
aws_cloudfront.Distribution(
    self,
    'CloudFrontDistribution',
    # ...
    error_responses=[
        aws_cloudfront.ErrorResponse(
            http_status=403,
            response_http_status=200,
            response_page_path='/index.html',
            ttl=Duration.days(365),
        ),
        aws_cloudfront.ErrorResponse(
            http_status=404,
            response_http_status=200,
            response_page_path='/index.html',
            ttl=Duration.days(365),
        ),
    ],
)
```

## 快取

如果看到 `X-Cache: Error from cloudfront` 錯誤，這代表 CloudFront 在處理請求時遇到了問題，無法返回快取內容。有可能因為 CloudFront 沒有找到對應的快取內容，而直接返回了原始的錯誤頁面。

可以透過 CloudFront 的 `Lambda@Edge` 功能，在 CloudFront 的邊緣節點上執行自定義的程式碼。在以下的程式碼中，檢查請求的 URI 是否包含句點（`.`），如果不包含，就將 URI 設置為 `index.html`。

```js
function handler(event){
    // Check if the request is for an internal route (doesn't have a file extension)
    if (!event.request.uri.includes('.')) {
        event.request.uri = '/index.html'; 
       }

    return event.request;
}
```

這樣，當 CloudFront 收到 403 或 404 錯誤時，它會將請求路由到 `index.html`，從而解決了路由問題。當檢查到路徑中有句點時，這通常意味著使用者正在請求一個實際的文件，而不是一個 Vue 路由。因此，在 `Lambda@Edge` 函數中檢查路徑中是否有句點，可以幫助區分使用者的實際文件請求和 Vue 路由的請求。

## CDK 堆疊

完整的 CDK 堆疊如下：

```python
from aws_cdk import Duration, RemovalPolicy, Stack, aws_cloudfront, aws_cloudfront_origins, aws_s3
from constructs import Construct


class UiStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        self.s3_bucket = self.create_s3_bucket()
        self.cloudfront_function = self.create_cloudfront_function()
        self.cloudfront_distribution = self.create_cloudfront_distribution()

    def create_s3_bucket(self):
        s3_bucket = aws_s3.Bucket(
            self,
            'LFEUiBucket',
            block_public_access=aws_s3.BlockPublicAccess.BLOCK_ALL,
            encryption=aws_s3.BucketEncryption.S3_MANAGED,
            access_control=aws_s3.BucketAccessControl.PRIVATE,
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
        )

        return s3_bucket

    def create_cloudfront_function(self):
        cloudfront_function = aws_cloudfront.Function(
            self,
            'LFEUiCloudFrontFunction',
            function_name='HistoryModeRouting',
            comment='Rewrite URI to index.html',
            code=aws_cloudfront.FunctionCode.from_inline(
                """function handler(event) {
    if (!event.request.uri.includes('.')) {
        event.request.uri = '/index.html';
    }
    return event.request;
}
"""
            ),
            runtime=aws_cloudfront.FunctionRuntime.JS_2_0,
            auto_publish=True,
        )

        return cloudfront_function

    def create_cloudfront_distribution(self):
        cloudfront_distribution = aws_cloudfront.Distribution(
            self,
            'LFEUiCloudFrontDistribution',
            default_behavior=aws_cloudfront.BehaviorOptions(
                origin=aws_cloudfront_origins.S3Origin(self.s3_bucket),
                compress=True,
                viewer_protocol_policy=aws_cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
                function_associations=[
                    aws_cloudfront.FunctionAssociation(
                        function=self.cloudfront_function,
                        event_type=aws_cloudfront.FunctionEventType.VIEWER_REQUEST,
                    )
                ],
            ),
            default_root_object='index.html',
            error_responses=[
                aws_cloudfront.ErrorResponse(
                    http_status=403,
                    response_http_status=200,
                    response_page_path='/index.html',
                    ttl=Duration.days(365),
                ),
                aws_cloudfront.ErrorResponse(
                    http_status=404,
                    response_http_status=200,
                    response_page_path='/index.html',
                    ttl=Duration.days(365),
                ),
            ],
        )

        return cloudfront_distribution
```

## 參考資料

- [Vue Router History 路由模式的后端配置](https://kebingzao.com/2022/08/17/vue-router-cloud-redirect/)
- [AWS Cloudfront 部署靜態網站出現 X-Cache: Error from cloudfront 訊息](https://billxu.net/blog/2024/03/19/aws-cloudfront-部署靜態網站出現-x-cache-error-from-cloudfront-訊息/)
