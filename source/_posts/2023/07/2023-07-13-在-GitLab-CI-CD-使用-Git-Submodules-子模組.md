---
title: 在 GitLab CI/CD 使用 Git Submodules 子模組
date: 2023-07-13 02:17:49
tags: ["環境部署", "CI/CD", "GitLab", "版本控制", "Git"]
categories: ["環境部署", "CI/CD", "GitLab"]
---

## 做法

在當前專案，檢查 `.gitmodules` 檔，每個子模組的 `url` 必須以 `.git` 結尾。

```txt
[submodule "sub-project"]
  path = sub-project
  url = git@gitlab.com:secret-group/sub-project.git
```

修改 `.gitlab-ci.yml` 檔，添加 `GIT_SUBMODULE_STRATEGY` 環境變數。GitLab 會使用 `CI_JOB_TOKEN` 去克隆每個子模組。

```yaml
build:
  stage: build
  variables:
    GIT_SUBMODULE_STRATEGY: recursive
    GIT_SUBMODULE_FORCE_HTTPS: "true"
```

再進到子模組的 GitLab 專案，在 CI/CD 的 Token Access 設定中，添加可存取的儲存庫，例如：`group/project`。

最後，將程式碼推送到儲存庫。

## 參考資料

- [Using Git submodules with GitLab CI/CD](https://docs.gitlab.com/ee/ci/git_submodules.html)
