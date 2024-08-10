---
title: 認識 JavaScript 的並行模型與事件循環
date: 2024-08-10 14:30:38
tags: ["Programming", "JavaScript"]
categories: ["Programming", "JavaScript", "Others"]
---

## 概述

JavaScript 是一個單執行緒（single-threaded）的語言，這代表它一次只能執行一個任務。然而，在現代應用中，經常會需要處理多個非同步任務（asynchronous task），例如網路請求、計時器、用戶輸入等。為了在單執行緒中有效地管理這些非同步任務，JavaScript 採用了事件循環（event loop）機制，並結合了一種獨特的並行模型（concurrency model）。

- 單執行緒的挑戰與事件循環的解決方案：

在單執行緒中，所有程式碼都在同一條執行緒中執行，這會導致同步任務（例如迴圈或大量計算）可能會阻塞後續的程式碼執行。事件循環通過將非同步任務推入任務隊列中，並在主執行堆棧空閒時逐一執行這些任務，從而避免了阻塞。

- 並行模型的概念：

雖然 JavaScript 是單執行緒的，但其並行模型允許在背景中並行處理多個任務。例如，網路請求、I/O 操作等可以在主執行緒之外的其他執行緒中進行處理，而主執行緒仍能繼續執行其他程式碼。一旦這些非同步操作完成，對應的回調函數會被放入事件循環的任務隊列中，等待主執行緒有空時執行。

- 宏任務與微任務的調度：

事件循環中的任務分為宏任務（macro-tasks）和微任務（micro-tasks）。宏任務包括 `setTimeout`、`setInterval` 等非同步操作，而微任務則包括 `Promise` 的回調函數等。事件循環每一輪循環中，會先執行所有同步任務，接著處理微任務，最後才會執行宏任務。這種調度策略確保了微任務可以在宏任務之前完成，提高了整體響應速度。

## 並行模型

並行模型是指在計算機系統中同時執行多個任務的能力。這些任務可以是獨立的或相互依賴的，並行模型可以在多核處理器、分佈式系統和網路應用程式中發揮重要作用。與串行模型相比，並行模型能更高效地利用計算資源，提高性能和響應速度。

- 基於線程的模型（Thread-based model）：允許多個線程並行執行。適用於需要高效利用多核處理器的應用程序。例如：Java、C++、C# 和 Go 語言。
- 基於事件的模型（Event-driven model）：使用事件循環來處理非同步任務，通常在單執行緒環境中運行。例如：JavaScript 和 Node 語言。
- 基於訊息的模型（Message-passing model）：進程或線程之間通過訊息進行通信，而不是共享記憶體。這有助於避免競爭條件。例如：Erlang 語言。
- 基於協程的模型（Coroutine-based model）：協程允許函數在執行中被掛起，並在稍後繼續執行，這樣可以實現非同步操作而無需線程管理的開銷。例如：Kotlin 語言。
- 基於資料流的模型（Dataflow model）：使用資料流的概念，允許在資料可用時自動觸發計算。例如：Haskell 語言。

## 微任務

### Promise 的回調函數

當 `Promise` 被解決或拒絕時，相關的 `.then()`、`.catch()` 和 `.finally()` 回調函數會被視為微任務。例如：

```js
Promise.resolve().then(() => {
  console.log('這是一個微任務');
});
```

### MutationObserver 的回調函數

當 DOM 變化時，`MutationObserver` 可以監聽這些變化，並在變化發生後執行回調。例如：

```js
const observer = new MutationObserver(() => {
  console.log('DOM 變化了！');
});

observer.observe(document.body, { childList: true });
```

### queueMicrotask()

`queueMicrotask()` 是一個用來添加微任務到微任務隊列中的方法，這些任務會在下一輪事件循環中執行。例如：

```js
queueMicrotask(() => {
  console.log('這是一個使用 queueMicrotask 的微任務');
});
```

### async 函數的回調

當使用 `async/await` 語法時，`await` 會在 `Promise` 被解析後執行，這些回調也會被視為微任務。例如：

```js
async function example() {
  await Promise.resolve();
  console.log('這是一個 async 函數中的微任務');
}
example();
```

這些微任務的設計是為了確保能夠迅速響應非同步操作，並在事件循環中保持高效的性能。

## 宏任務

### setTimeout()

使用 `setTimeout()` 設置的計時器回調會在指定的延遲時間後執行，這些回調會被視為宏任務。例如：

```js
setTimeout(() => {
  console.log('這是一個宏任務');
}, 1000); // 1秒後執行
```

### setInterval()

使用 `setInterval()` 設置的計時器回調會在指定的時間間隔內重複執行，這些回調也是宏任務。例如：

```js
setInterval(() => {
  console.log('這是一個重複執行的宏任務');
}, 1000); // 每1秒執行一次
```

### I/O 操作

所有的 I/O 操作（如文件讀取、網路請求等）通常被視為宏任務。在這些操作完成後，對應的回調會被加入宏任務隊列中。例如：

```js
fetch('https://api.example.com/data')
  .then(response => response.json())
  .then(data => {
    console.log('網絡請求的宏任務');
  });
```

### setImmediate()

`setImmediate()` 用於在當前事件循環的迴圈結束後執行一個回調。這是一種宏任務的形式。例如：

```js
setImmediate(() => {
  console.log('這是一個 Node.js 中的宏任務');
});
```

### requestAnimationFrame()

雖然 `requestAnimationFrame()` 的目的是為了優化動畫效果，但它的回調函數也被視為宏任務，因為它們會在瀏覽器的下次重繪之前執行。例如：

```js
requestAnimationFrame(() => {
  console.log('這是一個動畫幀的宏任務');
});
```

宏任務的特點是它們的執行時機是在當前事件循環中的所有同步任務和微任務完成之後。宏任務的設計是為了處理較為耗時的操作，確保主執行堆棧不會被阻塞，並且能夠保持應用的響應性。

## 事件循環

事件循環是 JavaScript 中處理非同步操作的核心機制。它的主要目的是確保非阻塞的執行流程，並且使得非同步任務能夠在適當的時間點執行。

事件循環的運作可以想像成一個持續運行的循環，主要工作流程經常被以以下方式實作：

```js
while (queue.waitForMessage()) {
  queue.processNextMessage();
}
```

在這個循環中，`queue.waitForMessage()` 方法負責檢查是否有新的訊息（例如回調函數）待處理。如果隊列中沒有任何訊息，這個方法將會等待新訊息的到來，從而避免了阻塞主執行堆棧。

事件循環的運作步驟：

- 執行同步任務：首先，主執行堆棧中的所有同步任務會被依次執行，直到堆棧清空。
- 檢查微任務：一旦主執行堆棧清空，事件循環會先處理所有的微任務（例如 `Promise` 的回調函數）。這些微任務的優先級高於宏任務，因此會在宏任務之前執行。
- 處理宏任務：接著，事件循環將處理隊列中的宏任務（例如 `setTimeout` 和 `setInterval` 的回調）。這些任務會根據它們的執行時間來決定何時執行。
- 重複循環：完成上述步驟後，事件循環會再次回到第一步，持續監控和執行新的任務。

事件循環的名稱來自於它的循環特性，這個循環持續運行，監控著事件的到來並處理這些事件。這樣的設計使得 JavaScript 能夠高效地處理大量的非同步操作，同時保持良好的性能。

### 模擬範例

以下創建一個自定義的 `mySetTimeout` 函數，並透過一個模擬的事件循環來執行回調函數。透過此模擬，來理解 JavaScript 如何在單執行緒環境中處理非同步操作，並了解並行模型與事件循環的互動。

```js
// 等待隊列
let queue = [];
// 模擬經過的時間
let timeElapsed = 0;
// 用來記錄 setInterval 的 ID
let intervalId;

// 模擬 setTimeout
function mySetTimeout(callback, delay) {
  // 計算何時執行回調
  const executionTime = timeElapsed + delay;
  // 將回調推入等待隊列
  queue.push({ callback, executionTime });
}

// 模擬事件循環
intervalId = setInterval(() => {
  console.log('timeElapsed:', timeElapsed);

  // 檢查隊列
  for (let i = 0; i < queue.length; i++) {
    if (queue[i].executionTime <= timeElapsed) {
      const { callback } = queue[i];
      callback(); // 執行回調
      queue.splice(i, 1); // 從隊列中刪除已執行的回調
      i--; // 調整索引以便正確遍歷隊列
    }
  }

  // 模擬時間的流逝
  timeElapsed += 100; // 每次增加 100 毫秒

  // 如果所有回調都已執行，停止模擬事件循環
  if (queue.length < 1) {
    clearInterval(intervalId);
  }
}, 100); // 每 100 毫秒檢查一次隊列

// 開始模擬主執行堆棧，輸出開始訊息
console.log('this is the start');

// 設置延遲 1000 毫秒
mySetTimeout(function cb() {
  // 當計時器到達 1000 毫秒時，這個回調函數將被加入事件循環隊列中
  // 在主執行堆棧中的所有同步任務完成後，事件循環會檢查隊列並執行這個回調
  console.log('this is a msg from call back');
}, 1000);

// 輸出中間訊息
console.log('this is just a message');

// 設置延遲 0 毫秒
mySetTimeout(function cb1() {
  // 當計時器設置的延遲時間為 0 毫秒時，這個回調函數將被立即加入事件循環隊列中
  // 儘管延遲為 0，該回調仍然會在主執行堆棧中的所有同步任務完成後執行
  console.log('this is a msg from call back1');
}, 0);

// 輸出結束訊息
console.log('this is the end');
```

執行腳本。

```bash
node index.js
```

輸出如下：

```bash
this is the start
this is just a message
this is the end
timeElapsed: 0
this is a msg from call back1
timeElapsed: 100
timeElapsed: 200
timeElapsed: 300
timeElapsed: 400
timeElapsed: 500
timeElapsed: 600
timeElapsed: 700
timeElapsed: 800
timeElapsed: 900
timeElapsed: 1000
this is a msg from call back
```

在上面的程式碼中，首先定義了一個 queue 來存儲回調函數及其執行時間。接著，創建一個 `mySetTimeout` 函數，它會將回調函數推入 queue 中，並設定它們應該在未來某個時間點執行。

接下來，模擬 JavaScript 的主執行堆棧，並在適當的時機調用 `mySetTimeout`，以便將回調函數推入 queue。最後，使用 `setInterval` 創建了一個模擬的事件循環，每 100 毫秒檢查一次 queue，並在合適的時間執行回調函數。

這個範例模擬了 JavaScript 如何使用事件循環來管理非同步任務，並通過並行模型來處理多個非同步操作。值得注意的是，實際的事件循環運行時會更為精確。而且即使 `setTimeout` 的延遲時間設置為 0，回調函數也不會立即執行，而是會在當前執行堆棧清空後才會被執行。

## 參考資料

- [並行模型和事件循環](https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Event_loop)
- [深入理解 Event loop](https://rurutseng.com/posts/event-loop/)
