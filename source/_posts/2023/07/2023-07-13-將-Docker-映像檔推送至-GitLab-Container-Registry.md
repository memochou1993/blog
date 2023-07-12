---
title: 將 Docker 映像檔推送至 GitLab Container Registry
date: 2023-07-13 01:49:50
tags: ["環境部署", "CI/CD", "GitLab", "Docker"]
categories: ["環境部署", "CI/CD"]
---

## 做法

新增 `.gitlab-ci.yml` 檔。

```yaml
default:
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY

stages:
  - build

variables:
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_CERTDIR: "/certs"
  IMAGE_NAME: ${CI_PROJECT_NAME}-base

build:
  stage: build
  script:
    - |
      docker build --no-cache \
        -t $IMAGE_NAME:$CI_COMMIT_REF_SLUG \
        -t $IMAGE_NAME:latest \
        -f Dockerfile .
    - docker tag $IMAGE_NAME:$CI_COMMIT_REF_SLUG $CI_REGISTRY/group/project/$IMAGE_NAME:$CI_COMMIT_REF_SLUG
    - docker tag $IMAGE_NAME:$CI_COMMIT_REF_SLUG $CI_REGISTRY/group/project/$IMAGE_NAME:latest
    - docker push $CI_REGISTRY/group/project/$IMAGE_NAME:$CI_COMMIT_REF_SLUG
    - docker push $CI_REGISTRY/group/project/$IMAGE_NAME:latest
  only:
    - main
```

將程式碼推送到儲存庫。

## 參考資料

- [Build and push container images to the Container Registry](https://docs.gitlab.com/ee/user/packages/container_registry/build_and_push_images.html)
