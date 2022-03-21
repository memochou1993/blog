---
title: 認識 WebTransport 傳輸協定框架
permalink: 認識-WebTransport-傳輸協定框架
date: 2022-03-04 01:52:30
tags: ["程式設計", "JavaScript", "WebTransport"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 背景

WebTransport 是一個 Web API，使用 HTTP/3 協議作為雙向傳輸。它用於 Web 客戶端和 HTTP/3 服務器之間的雙向通訊。它支援透過其資料報 API 以不可靠方式發送資料，以及透過其 Streams API 以可靠方式發送資料。

資料報（datagram）非常適合發送和接收不需要嚴格保證交付的資料。單個資料包的大小受到底層連線的最大傳輸單元（MTU）的限制，可能會或可能不會成功傳輸，如果傳輸，它們可能以任意順序到達。這些特性使資料報 API 成為低延遲、盡力而為的資料傳輸的理想選擇。可以將資料報視為用戶資料報協議（UDP）訊息，但經過加密和壅塞控制。

相比之下，Streams API 提供可靠、有序的資料傳輸，非常適合需要發送或接收一個或多個有序資料流的場景。使用多個 WebTransport 流類似於建立多個 TCP 連線，但由於 HTTP/3 在底層使用了輕量級的 QUIC 協議，因此可以在沒有太多開銷的情況下打開和關閉。

以下是 WebTransport 可能的幾種使用情景：

- 透過小型、不可靠、無序的訊息，以最小的延遲定期向服務器發送遊戲狀態。
- 以最小的延遲接收從服務器推送的媒體流，獨立於其他資料流。
- 在網頁打開時接收從服務器推送的通知。

### WebTransport 可以替代 WebSockets 嗎？

也許可以。在某些用例中，WebSockets 或 WebTransport 可作為可用的有效通訊協議。

WebSockets 通訊圍繞單一、可靠、有序的訊息流建模，這對於某些類型的通訊需求來說是很好的。如果您需要這些特性，那麼 WebTransport 的 Streams API 也可以提供它們。相比之下，WebTransport 的資料報 API 提供低延遲交付，但不保證可靠性或排序，因此它們不能直接替代 WebSocket。

透過資料報 API 或多個並發 Streams API 實例使用 WebTransport，意味著不必擔心隊列阻塞，這可能是 WebSockets 的問題。此外，在建立新連線時還有性能優勢，因為底層 QUIC 握手比透過 TLS 啟動 TCP 更快。

WebTransport 屬於新草案規範，因此圍繞客戶端和服務器庫的 WebSocket 生態系統目前更加強大。如果需要具有通用服務器設置和廣泛的 Web 客戶端支援的「開箱即用」工具，WebSockets 仍然是目前更好的選擇。

### WebTransport 是否與 UDP Socket API 相同？

不相同。WebTransport 不是 UDP Socket API。雖然 WebTransport 使用 HTTP/3，而後者又在「幕後」使用 UDP，但 WebTransport 對加密和壅塞控制有要求，這使其不僅僅是基本的 UDP Socket API。

### WebTransport 可以替代 WebRTC 資料通道嗎？

可以，用於客戶端與服務器連線。WebTransport 與 WebRTC 資料通道共享許多相同的屬性，儘管底層協議不同。

WebRTC 資料通道支援點對點通訊，但 WebTransport 僅支援客戶端與服務器連線。如果有多個客戶端需要直接相互通訊，那麼 WebTransport 不是一個可行的選擇。

通常，與維護 WebRTC 服務器相比，運行兼容 HTTP/3 的服務器需要更少的設置和配置，後者涉及了解多種協議（ICE、DTLS 和 SCTP）以獲得有效的傳輸。WebRTC 需要更多可能導致客戶端與服務器協商失敗的移動部分。

WebTransport API 的設計考慮了 Web 開發人員的用例，與使用 WebRTC 的資料通道接口相比，它更像是編寫現代 Web 平台程式碼。與 WebRTC 不同的是，Web Workers 內部支援 WebTransport，它允許獨立於給定的 HTML 頁面執行客戶端與服務器通訊。由於 WebTransport 有一個兼容流（Streams）的接口，因此支援圍繞背壓（backpressure）的優化。

但是，如果目前已經有一個滿意的 WebRTC 客戶端與服務器設置，那麼切換到 WebTransport 可能不會帶來很多優勢。

## 使用

WebTransport 的設計基於現代 Web 平台基本類型（如 Streams API）。它在很大程度上依賴於 Promise，並且可以很好地與 `async` 和 `await` 語法配合使用。

WebTransport 初始試用支援三種不同類型的流量，分別是：資料報、單向流以及雙向流。

試驗 WebTransport 的最佳方法是在本地啟動兼容的 HTTP/3 服務器，但是目前還沒有與最新規範兼容的公共參考服務器。

### 連線

可以透過創建 WebTransport 實例連線到 HTTP/3 服務器。URL 的模式應為 `https`，並且需要直接指定埠號。

應該使用 `ready` Promise 來等待建立連線。在完成設置之前，不會履行該 Promise，如果在 `QUIC/TLS` 階段連線失敗，則拒絕該 Promise。

`closed` Promise 在連線正常關閉時會履行，如果意外關閉，則會被拒絕。

如果服務器由於客戶端指示錯誤（如 URL 的路徑無效）而拒絕連線，則會導致 `closed` 拒絕，而 `ready` 仍未解析。

```JS
const url = 'https://example.com:4999/foo/bar';
const transport = new WebTransport(url);

// 連線關閉
transport.closed.then(() => {
  console.log(`The HTTP/3 connection to ${url} closed gracefully.`);
}).catch((error) => {
  console.error('The HTTP/3 connection to ${url} closed due to ${error}.');
});

// 一旦就緒，就可以使用連線
await transport.ready;
```

### 資料報 API

一旦擁有連線到服務器的 WebTransport 實例，就可以使用它來發送和接收離散的資料位，稱為資料報。

`writeable` getter 返回一個 `WritableStream`，Web 客戶端可以使用它向服務器發送資料。

`readable` getter 返回一個 `ReadableStream`，允許監聽來自服務器的資料。這兩個流本質上都是不可靠的，因此服務器有可能收不到您寫入的資料，反之亦然。

兩種類型的流都使用 `Uint8Array` 實例進行資料傳輸。

### Streams API

接到服務器後，還可以使用 WebTransport 透過其 Streams API 發送和接收資料。

所有流的每個塊都是一個 Uint8Array 物件。與資料報 API 不同，這些流是可靠的。但是每個流都是獨立的，因此不能保證跨流的資料順序。

## 參考資料

- [Using WebTransport](https://web.dev/i18n/en/webtransport/)
