---
title: 將 Storybook 專案部署至 GitLab Pages 服務
date: 2022-05-01 02:36:09
tags: ["Programming", "JavaScript", "Storybook", "GitLab", "GitLab Pages"]
categories: ["Programming", "JavaScript", "Deployment"]
---

## 做法

新增 `.gitlab-ci.yml` 檔。

```yaml
image: node:14-alpine

pages:
  stage: deploy
  script:
    - npm install
    - npm run build-storybook
    - rm -rf public && mkdir -p public
    - mv storybook-static/* public
  artifacts:
    paths:
      - public
  only:
    - main
```

將程式碼推送到 `main` 分支。

```bash
git add .gitlab-ci.yml
git commit -m "Add deploy script"
git push
```
