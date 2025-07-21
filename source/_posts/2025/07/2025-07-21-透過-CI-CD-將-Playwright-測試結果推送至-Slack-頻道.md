---
title: 透過 CI/CD 將 Playwright 測試結果推送至 Slack 頻道
date: 2025-07-21 00:46:31
tags: ["Others", "Slack", "WebHooks", "GitLab", "Playwright"]
categories: ["Programming", "JavaScript", "End-to-end Testing"]
---

## 前言

以下實作一個 `TestReporter` 類別以及一個 `report-test` 腳本，用來解析 Playwright 的測試報告，將測試結果轉換成 Slack 訊息荷載，最後推送至 Slack 頻道。

## 前置作業

首先，需要建立一個 Slack App，完成設定後，取得 Slack Webhook URL，之後要寫入 GitLab 的 CI/CD 環境變數。

## 輸出報告

首先，需要讓 Playwright 輸出 JSON 格式的測試報告。以 Nuxt 專案的 `playwright.config.ts` 為例，可以將 `reporter` 欄位設定如下：

```js
import type { ConfigOptions } from '@nuxt/test-utils/playwright';
import { defineConfig } from '@playwright/test';

export default defineConfig<ConfigOptions>({
  use: {
    nuxt: {
      host: 'http://localhost:3000',
    },
    baseURL: 'http://localhost:3000',
  },
  projects: [
    {
      name: 'dev',
      testDir: './tests/integration/dev',
      timeout: 60 * 1000,
      retries: process.env.CI ? 3 : 0,
    },
  ],
  fullyParallel: true,
  workers: process.env.CI ? 1 : 4,
  reporter: process.env.CI
    ? [
        ['list'],
        ['html', { open: 'never' }],
        ['junit', { outputFile: 'playwright-report/test-results.xml' }],
        ['json', { outputFile: 'playwright-report/test-results.json' }],
      ]
    : [
        ['list'],
        ['json', { outputFile: 'playwright-report/test-results.json' }],
      ],
});
```

執行測試，就可以生成測試報告。

```bash
playwright test
```

測試報告如下：

```json
{
  "config": {
    // ...
  },
  "suites": [
    // ...
  ],
  "errors": [
    // ...
  ],
  "stats": {
    // ...
  }
}
```

## 實作

建立一個 `test-reporter` 資料夾。

```bash
mkdir test-reporter
```

建立 `test-reporter/TestReporter.js` 檔。

```js
import fs from 'fs';
import https from 'https';
import { URL } from 'url';

/**
 * @import { JSONReport, JSONReportSuite } from '@playwright/test/reporter'
 */

const {
  CI,
  TEST_JOB_ID,
  TEST_PROJECT = 'local',
  SLACK_WEBHOOK_URL,
} = process.env;

const Color = Object.freeze({
  SUCCESS: '#008000',
  FAILURE: '#FF0000',
  WARNING: '#FFA500',
});

const Status = Object.freeze({
  FAILED: 'failed',
  INTERRUPTED: 'interrupted',
  PASSED: 'passed',
  SKIPPED: 'skipped',
  TIMED_OUT: 'timedOut',
});

class TestReporter {
  /**
   * @type {JSONReport}
   */
  report;

  constructor(reportPath) {
    this.report = this.loadReport(reportPath);
  }

  get reportUrl() {
    return `https://my-org.gitlab.io/-/my-project/-/jobs/${TEST_JOB_ID}/artifacts/playwright-report/index.html`;
  }

  loadReport(path) {
    if (!fs.existsSync(path)) {
      console.error(`No report found at ${path}`);
      process.exit(1);
    }

    const content = fs.readFileSync(path, 'utf-8');

    return JSON.parse(content);
  }

  /**
   * Summarizes the Playwright test report results
   *
   * @param {JSONReport} report
   */
  summarize(report) {
    const failureStatuses = new Set([Status.FAILED, Status.INTERRUPTED, Status.TIMED_OUT]);
    const messageBlocks = [];

    /**
     * @param {JSONReportSuite} suite
     * @param {string[]} titles
     * @param {object[]} messageBlocks
     */
    const processSuite = (suite, titles = [], messageBlocks = []) => {
      for (const spec of suite.specs || []) {
        for (const test of spec.tests || []) {
          const latestResult = test.results.at(-1);
          if (!latestResult) continue;
          const { status } = latestResult;
          if (failureStatuses.has(status)) {
            const title = [...titles, suite.title, spec.title].join(' › ');
            messageBlocks.push({
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: `*Test:*\n <${this.reportUrl}#?testId=${spec.id}|${title}>\n*Status:*\n ${String(status).toUpperCase()}\n`,
              },
            });
          }
        }
      }
      for (const childSuite of suite.suites || []) {
        processSuite(childSuite, [...titles, suite.title], messageBlocks);
      }
    };

    for (const suite of report.suites || []) {
      processSuite(suite, [], messageBlocks);
    }

    return messageBlocks;
  }

  createMessagePayload() {
    const { stats } = this.report;

    const color = (() => {
      if (stats.unexpected > 0) return Color.FAILURE;
      if (stats.flaky > 0) return Color.WARNING;
      return Color.SUCCESS;
    })();

    const title = stats.unexpected > 0
      ? `[${String(TEST_PROJECT).toUpperCase()}] 🚨 E2E testing reported ${stats.unexpected} test${'s'.repeat(stats.unexpected !== 1)} failed`
      : `[${String(TEST_PROJECT).toUpperCase()}] ✅ E2E testing reported all tests passed`;

    const messageBlocks = this.summarize(this.report);

    const messagePayload = {
      attachments: [
        {
          fallback: title,
          color,
          blocks: [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: title,
              },
            },
            {
              type: 'section',
              fields: [
                {
                  type: 'mrkdwn',
                  text: `*Failed:*\n${stats.unexpected}`,
                },
                {
                  type: 'mrkdwn',
                  text: `*Flaky:*\n${stats.flaky}`,
                },
                {
                  type: 'mrkdwn',
                  text: `*Passed:*\n${stats.expected}`,
                },
                {
                  type: 'mrkdwn',
                  text: `*Skipped:*\n${stats.skipped}`,
                },
              ],
            },
            {
              type: 'actions',
              elements: [
                {
                  type: 'button',
                  text: {
                    type: 'plain_text',
                    text: 'View report',
                    emoji: true,
                  },
                  url: this.reportUrl,
                },
              ],
            },
            ...messageBlocks.flatMap((block, i, arr) => i < arr.length ? [{ type: 'divider' }, block] : [block]),
          ],
        },
      ],
    };

    return messagePayload;
  }

  sendToSlack(messagePayload) {
    const url = new URL(SLACK_WEBHOOK_URL);
    const req = https.request(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    }, (res) => {
      res.resume();
      res.on('end', () => {
        process.exit(res.statusCode === 200 ? 0 : 1);
      });
    });
    req.on('error', (err) => {
      console.error(`Slack request error: ${err}`);
      process.exit(1);
    });
    req.write(JSON.stringify(messagePayload));
    req.end();
  }

  run() {
    const messagePayload = this.createMessagePayload();
    if (!CI) {
      console.log(JSON.stringify(messagePayload, null, 2));
      return;
    }
    this.sendToSlack(messagePayload);
  }
}

export default TestReporter;
```

建立 `scripts` 資料夾。

```bash
mkdir scripts
```

建立 `scripts/report-test.js` 檔。

```js
import path from 'path';
import TestReporter from '../test-reporter/TestReporter.js';

const testReporter = new TestReporter(path.resolve(process.cwd(), 'playwright-report/test-results.json'));

testReporter.run();
```

執行腳本。

```bash
node ./scripts/report-test.js
```

輸出如下：

```json
{
  "attachments": [
    {
      "fallback": "[LOCAL] ✅ E2E testing reported all tests passed",
      "color": "#008000",
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "[LOCAL] ✅ E2E testing reported all tests passed"
          }
        },
        {
          "type": "section",
          "fields": [
            {
              "type": "mrkdwn",
              "text": "*Failed:*\n0"
            },
            {
              "type": "mrkdwn",
              "text": "*Flaky:*\n0"
            },
            {
              "type": "mrkdwn",
              "text": "*Passed:*\n4"
            },
            {
              "type": "mrkdwn",
              "text": "*Skipped:*\n0"
            }
          ]
        },
        {
          "type": "actions",
          "elements": [
            {
              "type": "button",
              "text": {
                "type": "plain_text",
                "text": "View report",
                "emoji": true
              },
              "url": "https://my-org.gitlab.io/-/my-project/-/jobs/undefined/artifacts/playwright-report/index.html"
            }
          ]
        }
      ]
    }
  ]
}
```

## 測試訊息

將 Slack 訊息荷載複製起來，並貼到 [Block Kit Builder](https://app.slack.com/block-kit-builder/)，可以預覽訊息呈現的樣子。

```bash
node ./scripts/report-test.js | pbcopy
```

點選 Send to Slack 按鈕，可以實際將訊息推送至 Slack 頻道。

## CI/CD

確保 GitLab 的 CI/CD Variables 已經有對應的環境變數。例如，有一個鍵名為 `ENV_DEV` 的環境變數檔案，有以下的內容：

```env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

修改 `.gitlab-ci.yml` 檔。

```yml
stages:
  - build
  - test
  - deploy

variables:
  AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
  SESSION_NAME: "GitLabRunnerSession-$CI_COMMIT_REF_NAME-Job-$CI_JOB_ID"

.build-template: &build-template
  # ...

.test-template: &test-template
  stage: test
  image: mcr.microsoft.com/playwright:v1.48.1-noble
  before_script:
    - cp $ENV .env
  script:
    - echo $CI_JOB_ID > test-job-id.txt
    - npx serve .output/public &
    - npx wait-on http://localhost:3000
    - npm run test:integration -- --project ${TEST_PROJECT}
  artifacts:
    name: test-report
    paths:
      - test-job-id.txt
      - ./playwright-report/index.html
      - ./playwright-report/test-results.xml
      - ./playwright-report/test-results.json
    reports:
      junit: ./playwright-report/test-results.xml
    when: always
    expire_in: 3 months
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
      - .nuxt/tsconfig.json

.report-test-template: &report-test-template
  stage: test
  image: node:22-alpine
  before_script:
    - cp $ENV .env
  script:
    - echo "TEST_JOB_ID=$(cat test-job-id.txt)" >> .env
    - npx dotenv-cli@7 --no-expand -- node ./scripts/report-test.js

.deploy-template: &deploy-template
  # ...

build-dev:
  # ...

test-dev:
  <<: *test-template
  variables:
    ENV: $ENV_DEV
    TEST_PROJECT: dev
  rules:
    - if: '$CI_MERGE_REQUEST_EVENT_TYPE == "merge_train"'
    - if: '$TEST_ENV == "dev"'

report-test-dev:
  <<: *report-test-template
  variables:
    ENV: $ENV_DEV
    TEST_PROJECT: dev
  needs:
    - job: test-dev
      artifacts: true
  rules:
    - if: '$CI_MERGE_REQUEST_EVENT_TYPE == "merge_train"'
      when: always
    - if: '$TEST_ENV == "dev"'
      when: always
```

## 參考資料

- [Slack API](https://api.slack.com/messaging/webhooks)
- [Building with Block Kit](https://api.slack.com/block-kit/building)
