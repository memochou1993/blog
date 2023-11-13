---
title: 使用 GitHub Actions 和 Docker 為 Go 專案建立自動化部署
date: 2021-12-30 21:43:29
tags: ["Deployment", "CI/CD", "Docker", "Go", "GitHub", "GitHub Actions"]
categories: ["Programming", "Go", "Deployment"]
---

## 建立專案

建立專案。

```bash
mkdir go-pipeline-example
cd go-pipeline-example
```

初始化 Go Modules。

```bash
go mod init go-pipeline-example
```

新增 `main.go` 檔：

```go
package main

import "fmt"

var version = "dev"

func main() {
	fmt.Printf("Version: %s\n", version)

	fmt.Println(hello())
}

func hello() string {
	return "Hello World!"
}
```

建立 `main.test.go` 檔：

```go
package main

import "testing"

func TestHello(t *testing.T) {
	expected := "Hello World!"

	actual := hello()

	if expected != actual {
		t.Fatalf("expected: %s, actual: %s\n", expected, actual)
	}
}
```

進行測試。

```bash
go test
```

## 建立存取令牌

登入 [Docker Hub](https://hub.docker.com/settings/security)，建立一個 Access Token，讓 GitHub Actions 推送映像檔。

## 建立儲存庫

建立專案的儲存庫，並建立 secrets，分別為：

- `DOCKERHUB_USERNAME`：Docker Hub 的 Username
- `DOCKERHUB_ACCESS_TOKEN`：Docker Hub 的 Access Token

## 建立流程

建立 `.github/workflows` 資料夾，以及 `push.yaml` 檔。

```bash
mkdir -p .github/workflows
touch .github/workflows/push.yaml
```

在 `push.yaml` 檔中建立兩個工作，分別是 `test` 和 `deploy`。

```yaml
name: go-pipeline
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags')
    steps:
      - uses: actions/checkout@v2
      - name: Run unit tests
        run: go test

  deploy:
    runs-on: ubuntu-latest
    needs: test
    if: startsWith(github.ref, 'refs/tags')
    steps:
      - name: Extract version
        id: version_step
        run: |
          echo "##[set-output name=version;]VERSION=${GITHUB_REF#$"refs/tags/v"}"
          echo "##[set-output name=version_tag;]$GITHUB_REPOSITORY:${GITHUB_REF#$"refs/tags/v"}"
          echo "##[set-output name=latest_tag;]$GITHUB_REPOSITORY:latest"
      - name: Print version
        run: |
          echo ${{steps.version_step.outputs.version_tag}}
          echo ${{steps.version_step.outputs.latest_tag}}
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v1
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      - name: Login to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_ACCESS_TOKEN }}
      - name: Prepare reg names
        id: read-docker-image-identifiers
        run: |
          echo VERSION_TAG=$(echo ${{ steps.version_step.outputs.version_tag }} | tr '[:upper:]' '[:lower:]') >> $GITHUB_ENV
          echo LASTEST_TAG=$(echo ${{ steps.version_step.outputs.latest_tag  }} | tr '[:upper:]' '[:lower:]') >> $GITHUB_ENV
      - name: Build and push
        id: docker_build
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: |
            ${{env.VERSION_TAG}}
            ${{env.LASTEST_TAG}}
          build-args: |
            ${{steps.version_step.outputs.version}}
```

## 建立映像檔

建立 `Dockerfile` 檔：

```dockerfile
FROM golang:latest as builder
ARG VERSION=dev
WORKDIR /go/src/app
COPY main.go .
RUN go build -o main -ldflags=-X=main.version=${VERSION} main.go 

FROM alpine:latest
COPY --from=builder /go/src/app/main /go/bin/main
ENV PATH="/go/bin:${PATH}"
CMD ["main"]
```

建立映像檔，並將標籤取名為 `go-pipeline-example:dev`。

```bash
docker build -t go-pipeline-example:dev .
```

執行映像檔並刪除容器。

```bash
docker run --rm go-pipeline-example:dev
```

顯示結果如下：

```bash
Version: dev
Hello World!
```

指定版本為 `1.0.0`，並再次建立映像檔。由於 Dockerfile 中的 `go build` 腳本使用了 `-ldflags` 參數，因此可以把 `main.go` 檔中的 `version` 變數的值修改為 `1.0.0`。

```bash
docker build -t go-pipeline-example:1.0.0 . --build-arg VERSION=1.0.0
```

列出映像檔列表。

```bash
docker images
```

顯示結果如下：

```bash
REPOSITORY            TAG       IMAGE ID       CREATED              SIZE
go-pipeline-example   1.0.0     1ea19c202291   32 seconds ago       7.37MB
go-pipeline-example   dev       b91b05baed20   About a minute ago   7.37MB
```

## 推送程式碼

推送程式碼到專案儲存庫。

```bash
git init
git branch -m main
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:memochou1993/go-pipeline-example.git
git push -u origin main
```

## 建立標籤

最後，添加標籤，並推送至專案儲存庫。

```bash
git tag v1.0.0
git push --tags
```

只要添加標籤，GitHub Actions 的 `deploy` 流程就會被觸發，並且將版本 `1.0.0` 的映像檔推送至 Docker Hub。

## 程式碼

- [go-pipeline-example](https://github.com/memochou1993/go-pipeline-example)

## 參考資料

- [Build CI/CD pipelines in Go with github actions and Docker](https://dev.to/gopher/build-ci-cd-pipelines-in-go-with-github-actions-and-dockers-1ko7)
