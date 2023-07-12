---
title: 在 GitLab CI/CD 使用 SSH keys 克隆儲存庫
date: 2023-07-13 01:59:15
tags: ["環境部署", "CI/CD", "GitLab", "SSH"]
categories: ["環境部署", "CI/CD"]
---

## 做法

首先建立一組 SSH 金鑰對。

```bash
ssh-keygen -t rsa -b 4096 -C user@example.com -f ~/.ssh
```

在當前專案的 CI/CD 變數中，新增名為 `SSH_PRIVATE_KEY` 的環境變數，並且將值設定為 SSH 私鑰的內容。

在要被克隆的專案中，將 SSH 公鑰添加至該專案的 Deploy keys 中。

然後在當前專案新增 `.gitlab-ci.yml` 檔。

```yaml
image: ubuntu

before_script:
  ##
  ## Install ssh-agent if not already installed, it is required by Docker.
  ## (change apt-get to yum if you use an RPM-based image)
  ##
  - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client git -y )'

  ##
  ## Run ssh-agent (inside the build environment)
  ##
  - eval $(ssh-agent -s)

  ##
  ## Add the SSH key stored in SSH_PRIVATE_KEY variable to the agent store
  ## We're using tr to fix line endings which makes ed25519 keys work
  ## without extra base64 encoding.
  ## https://gitlab.com/gitlab-examples/ssh-private-key/issues/1#note_48526556
  ##
  - echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -

  ##
  ## Create the SSH directory and give it the right permissions
  ##
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh

  ##
  ## Use ssh-keyscan to scan the keys of your private server. Replace gitlab.com
  ## with your own domain name. You can copy and repeat that command if you have
  ## more than one server to connect to.
  ##
  - ssh-keyscan gitlab.com >> ~/.ssh/known_hosts
  - chmod 644 ~/.ssh/known_hosts

Test SSH:
  script:
  # try to connect to gitlab.com
  - ssh git@gitlab.com

  # try to clone yourself. A *PUBLIC* key paired to the SSH_PRIVATE_KEY was added as deploy key to this repository
  - git clone git@gitlab.com:gitlab-examples/ssh-private-key.git
```

將程式碼推送到儲存庫。

## 參考資料

- [Using SSH keys with GitLab CI/CD](https://docs.gitlab.com/ee/ci/ssh_keys/)
