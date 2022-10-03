---
title: 使用 GitLab 鏡像與 GitHub 同步專案原始碼
date: 2022-08-25 13:28:46
tags: ["其他", "WebHooks", "GitLab", "GitHub"]
categories: ["其他", "Git Repository"]
---

## 做法

1. 在 GitLab 的指定專案中，點進「Settings」的「Repository」設定。

2. 展開「Mirroring repositories」選項。

3. 貼上 Git repository URL，例如：`ssh://git@gitlab.com/your-org/your-repo.git`。

4. 選擇「Mirror direction」為「Pull」或其他選項。

5. 選擇「Authentication method」為「SSH Public Key」。

6. 確認後，點選「Copy SSH public key」按鈕。

7. 在 GitHub 的指定專案中，點進「Settings」的「Deploy Keys」設定。

8. 新增一個 Deploy Key，此動作需要 Repository 的 Admin 權限。

## 參考資料

- [GitLab - Repository Mirroring](https://docs.gitlab.com/ee/user/project/repository/mirror/)
