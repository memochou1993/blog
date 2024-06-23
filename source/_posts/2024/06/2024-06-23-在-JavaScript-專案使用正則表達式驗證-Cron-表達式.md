---
title: 在 JavaScript 專案使用正則表達式驗證 Cron 表達式
date: 2024-06-23 20:48:30
tags: ["Programming", "JavaScript", "Regular Expression", "Cron"]
categories: ["Programming", "JavaScript", "Others"]
---

## 前言

Cron 表達式是用來描述定時任務執行時間的語法，常見於各種定時任務調度工具中。本文使用正則表達式來驗證 Cron 表達式。

## 做法

首先，在 [regex101](https://regex101.com/) 網站上測試正則表達式，以確保正確性。以下是用來驗證 Cron 表達式的正則表達式：

```bash
^(\*|([0-5]?[0-9]|\*\/[1-9][0-9]*|([0-5]?[0-9])(-([0-5]?[0-9]))?)(,([0-5]?[0-9]|\*\/[1-9][0-9]*|([0-5]?[0-9])(-([0-5]?[0-9]))?))*)\s+(\*|([0-1]?[0-9]|2[0-3]|\*\/[1-9][0-9]*|([0-1]?[0-9]|2[0-3])(-([0-1]?[0-9]|2[0-3]))?)(,([0-1]?[0-9]|2[0-3]|\*\/[1-9][0-9]*|([0-1]?[0-9]|2[0-3])(-([0-1]?[0-9]|2[0-3]))?))*)\s+(\*|([1-9]|[12][0-9]|3[01]|\*\/[1-9][0-9]*|([1-9]|[12][0-9]|3[01])(-([1-9]|[12][0-9]|3[01]))?)(,([1-9]|[12][0-9]|3[01]|\*\/[1-9][0-9]*|([1-9]|[12][0-9]|3[01])(-([1-9]|[12][0-9]|3[01]))?))*)\s+(\*|([1-9]|1[0-2]|\*\/[1-9][0-9]*|([1-9]|1[0-2])(-([1-9]|1[0-2]))?)(,([1-9]|1[0-2]|\*\/[1-9][0-9]*|([1-9]|1[0-2])(-([1-9]|1[0-2]))?))*)\s+(\*|([0-6]|\*\/[1-9][0-9]*|([0-6])(-([0-6]))?)(,([0-6]|\*\/[1-9][0-9]*|([0-6])(-([0-6]))?))*)$
```

## 實作

建立 `validate-cron-expression.js` 檔，根據以上表達式實作一個驗證函數。

```js
function validateCronExpression(input) {
  const segment = '(\\*|(T|\\*\\/[1-9][0-9]*|(T)(-(T))?)(,(T|\\*\\/[1-9][0-9]*|(T)(-(T))?))*)';
  const minute = segment.replaceAll('T', '[0-5]?[0-9]');
  const hour = segment.replaceAll('T', '[0-1]?[0-9]|2[0-3]');
  const dayOfMonth = segment.replaceAll('T', '[1-9]|[12][0-9]|3[01]');
  const month = segment.replaceAll('T', '[1-9]|1[0-2]');
  const dayOfWeek = segment.replaceAll('T', '[0-6]');
  const cronRegex = new RegExp(`^${minute}\\s+${hour}\\s+${dayOfMonth}\\s+${month}\\s+${dayOfWeek}$`);
  return cronRegex.test(input);
}
```

建立簡單的測試案例。

```js
const testCases = [
    { input: "0 0 1 1 0", expected: true }, // Valid: At midnight on the first of January, only on Sundays.
    { input: "* * * * *", expected: true }, // Valid: Every minute of every hour of every day of the month, month, and week.
    { input: "*/15 0 1,15 * 1-5", expected: true }, // Valid: Every 15 minutes, on the hour, on the 1st and 15th of every month, Monday through Friday.
    { input: "0 0 0 0 0", expected: false }, // Invalid: Day of month and month cannot be 0.
    { input: "60 0 1 1 0", expected: false }, // Invalid: Minute cannot be 60.
    { input: "0 24 1 1 0", expected: false }, // Invalid: Hour cannot be 24.
    { input: "0 0 32 1 0", expected: false }, // Invalid: Day of month cannot be 32.
    { input: "0 0 1 13 0", expected: false }, // Invalid: Month cannot be 13.
    { input: "0 0 1 1 7", expected: false }, // Invalid: Day of week cannot be 7.
    { input: "*/5 * * * 1-7", expected: false } // Invalid: Day of week cannot be a range that includes 7.
];

// Function to test the validateCronExpression function
function runTests() {
    testCases.forEach((testCase, index) => {
        const result = validateCronExpression(testCase.input);
        const passed = result === testCase.expected;
        console.log(`Test Case ${index + 1}: ${passed ? "Passed" : "Failed"}`);
        if (!passed) {
            console.log(`  Input: ${testCase.input}`);
            console.log(`  Expected: ${testCase.expected}`);
            console.log(`  Got: ${result}`);
        }
    });
}

// Run the tests
runTests();
```

執行測試。

```bash
node validateCronExpression.js
```

測試結果如下：

```bash
Test Case 1: Passed
Test Case 2: Passed
Test Case 3: Passed
Test Case 4: Passed
Test Case 5: Passed
Test Case 6: Passed
Test Case 7: Passed
Test Case 8: Passed
Test Case 9: Passed
Test Case 10: Passed
```

## 程式碼

- [validate-cron-expression.js](https://gist.github.com/memochou1993/f94a1059292244ce69015d969418c0dc)
