---
title: 在 Go 專案使用 gRPC-Gateway 反向代理
permalink: 在-Go-專案使用-gRPC-Gateway-反向代理
date: 2021-01-09 19:52:26
tags: ["程式設計", "Go", "gRPC", "RPC"]
categories: ["程式設計", "Go", "gRPC"]
---

## 前言

gRPC-Gateway 可以讓專案同時支援 gRPC 以及 HTTP API 的服務。

## 做法

建立專案。

```BASH
mkdir grpc-gateway-go-example
cd grpc-gateway-go-example
go mod init
```

目錄結構如下：

```BASH
|- client/
|- gen/
|- proto/
|- server/
```

### 安裝套件

安裝相關套件。

```BASH
go install \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
    github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
    google.golang.org/protobuf/cmd/protoc-gen-go \
    google.golang.org/grpc/cmd/protoc-gen-go-grpc
```

執行後，會在 `$GOBIN` 目錄生成以下執行檔：

```BASH
protoc-gen-grpc-gateway
protoc-gen-openapiv2
protoc-gen-go
protoc-gen-go-grpc
```

### 定義服務

下載所需定義檔。

```BASH
mkdir -p proto/google/api
cp ../grpc-gateway/third_party/googleapis/google/api/* ./proto/google/api 
```

新增 `hello.proto` 檔：

```PROTO
syntax = "proto3";

option go_package = ".;hello";

import "google/api/annotations.proto";

service HelloService {
  rpc SayHello (HelloRequest) returns (HelloResponse) {
    option (google.api.http) = {
      post: "/hello"
      body: "*"
    };
  }
}

message HelloRequest {
  string greeting = 1;
}

message HelloResponse {
  string reply = 1;
}
```

使用以下指令，生成 `hello.pb.go` 和 `hello_grpc.pb.go` 檔：

```BASH
protoc -I ./proto \
    --go_out=./gen \
    --go-grpc_out=./gen \
    ./proto/hello.proto
```

使用以下指令，生成 `hello.pb.gw.go` 檔：

```BASH
protoc -I ./proto --grpc-gateway_out ./gen \
    --grpc-gateway_opt logtostderr=true \
    --grpc-gateway_opt paths=source_relative \
    ./proto/hello.proto
```

### 實作服務端

在 `server` 資料夾新增 `main.go` 檔：

```GO
package main

import (
	"context"
	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	gw "github.com/memochou1993/grpc-go-example/gen"
	"google.golang.org/grpc"
	"log"
	"net"
	"net/http"
)

const (
	grpcServerEndpoint = ":8080"
	httpServerEndpoint = ":8890"
)

type service struct {
	gw.UnimplementedHelloServiceServer
}

func (s *service) SayHello(ctx context.Context, r *gw.HelloRequest) (*gw.HelloResponse, error) {
	log.Printf("Request received: %s", r.GetGreeting())
	return &gw.HelloResponse{Reply: "Hello, " + r.GetGreeting()}, nil
}

func httpServer() {
	ctx := context.Background()
	mux := runtime.NewServeMux()
	opts := []grpc.DialOption{grpc.WithInsecure()}
	if err := gw.RegisterHelloServiceHandlerFromEndpoint(ctx, mux, grpcServerEndpoint, opts); err != nil {
		log.Fatalln(err.Error())
	}
	log.Fatalln(http.ListenAndServe(httpServerEndpoint, mux))
}

func grpcServer() {
	ln, err := net.Listen("tcp", grpcServerEndpoint)
	if err != nil {
		log.Fatalln(err.Error())
	}
	s := grpc.NewServer()
	gw.RegisterHelloServiceServer(s, new(service))
	log.Fatalln(s.Serve(ln))
}

func main() {
	go grpcServer()
	httpServer()
}
```

使用終端機執行服務端程式：

```BASH
go run server/main.go
```

使用 curl 指令呼叫 API。

```BASH
curl -d '{"greeting":"world"}' -H "Content-Type: application/json" -X POST http://localhost:8890/hello
{"reply":"Hello, world"}
```

### 實作客戶端

在 `client` 資料夾新增 `main.go` 檔：

```GO
package main

import (
	"context"
	pb "github.com/memochou1993/grpc-go-example"
	"google.golang.org/grpc"
	"log"
	"time"
)

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	// 連線
	addr := "127.0.0.1:8080"
	conn, err := grpc.DialContext(ctx, addr, grpc.WithInsecure(), grpc.WithBlock())
	if err != nil {
		log.Fatalln(err.Error())
	}
	defer conn.Close()

	c := pb.NewHelloServiceClient(conn)
	// 執行 SayHello 方法
	r, err := c.SayHello(ctx, &pb.HelloRequest{Greeting: "World!"})
	if err != nil {
		log.Fatalln(err.Error())
	}
	log.Printf("Response received: %s", r.GetReply())
}
```

使用終端機執行客戶端程式：

```BASH
go run client/main.go
Response received: Hello, World!
```

## 程式碼

- [grpc-gateway-go-example](https://github.com/memochou1993/grpc-gateway-go-example)
