---
title: 使用 TypeScript 操作 Canvas 畫布
date: 2022-06-01 17:44:18
tags: ["Programming", "JavaScript", "TypeScript", "Canvas"]
categories: ["Programming", "JavaScript", "TypeScript"]
---

## 做法

建立一個 `App` 物件。

```ts
class App {
  private canvas:  HTMLCanvasElement;

  private ctx: CanvasRenderingContext2D;

  private rectangle: Element;

  private ellipse: Element;

  private selectedObject: Element | null = null;

  constructor() {
    //
  }
}

new App();
```

初始化一個 `canvas` 畫布，並使用 `getContext` 方法取得渲染環境和繪圖函式。

```ts
constructor() {
  this.canvas = document.getElementById('canvas') as HTMLCanvasElement;
  this.ctx = this.canvas.getContext('2d') as CanvasRenderingContext2D;
}
```

監聽畫布，並建立一個 `handleCanvasClick` 處理器。

```ts
constructor() {
  // ...
  this.canvas.addEventListener('click', (e) => this.handleCanvasClick(e));
}

handleCanvasClick(e: MouseEvent) {
  // ...
}
```

使用 `ctx` 提供的繪圖函式繪製一個矩形。

```ts
handleCanvasClick(e: MouseEvent) {
  const x = e.offsetX;
  const y = e.offsetY;
  this.ctx.strokeRect(x, y, 100, 100);
}
```

使用 `ctx` 提供的繪圖函式繪製一個橢圓形。

```ts
handleCanvasClick(e: MouseEvent) {
  this.ctx.beginPath();
  this.ctx.ellipse(x, y, 75, 100, Math.PI / 2, 0, 2 * Math.PI);
  this.ctx.stroke();
}
```

新增 `index.html` 檔。

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style type="text/css">
        html, body {
            align-items: center;
            display: flex;
            height: 100%;
            justify-content: center;
        }
        #canvas {
            border: 1px solid black;
            border-radius: 8px;
            box-sizing: border-box;
        }
        .object {
            align-items: center;
            border: 1px solid black;
            border-radius: 8px;
            box-sizing: border-box;
            cursor: pointer;
            display: flex;
            height: 100px;
            justify-content: center;
            text-align: center;
            user-select: none;
            width: 100px;
        }
        .object:not(:last-child) {
            margin: 0 12px 12px 0;
        }
        .object.selected {
            border: 2.5px solid black;
        }
    </style>
</head>
<body>
    <div style="display: flex;">
        <div style="display: flex; flex-direction: column;">
            <div class="object" id="rectangle">Rectangle</div>
            <div class="object" id="ellipse">Ellipse</div>
        </div>
        <canvas height="660" width="660" id="canvas"></canvas>
    </div>
    <script src="dist/main.js"></script>
</body>
</html>
```

實作不同物件的處理器，以選取工具並繪製指定的圖形。

```ts
class App {
  private canvas:  HTMLCanvasElement;

  private ctx: CanvasRenderingContext2D;

  private rectangle: Element;

  private ellipse: Element;

  private selectedObject: Element | null = null;

  constructor() {
    this.canvas = document.getElementById('canvas') as HTMLCanvasElement;
    this.ctx = this.canvas.getContext('2d') as CanvasRenderingContext2D;
    this.rectangle = document.getElementById('rectangle') as Element;
    this.ellipse = document.getElementById('ellipse') as Element;
    this.init();
  }

  init() {
    this.canvas?.addEventListener('click', (e) => this.handleCanvasClick(e));
    this.rectangle?.addEventListener('click', (e) => this.handleRectangleClick(e));
    this.ellipse?.addEventListener('click', (e) => this.handleEllipseClick(e));
  }

  handleCanvasClick(e: MouseEvent) {
    const rect = this.canvas?.getBoundingClientRect() as DOMRect;
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    switch (this.selectedObject?.id) {
      case 'rectangle':
        this.ctx.strokeRect(x, y, 100, 100);
        break;
      case 'ellipse':
        this.ctx.beginPath();
        this.ctx.ellipse(x, y, 75, 100, Math.PI / 2, 0, 2 * Math.PI);
        this.ctx.stroke();
        break;
      default:
        break;
    }
    this.clearSelection();
  }

  handleRectangleClick(e: Event) {
    const el = e.target as Element;
    this.toggleSelection(el);
  }

  handleEllipseClick(e: Event) {
    const el = e.target as Element;
    this.toggleSelection(el);
  }

  toggleSelection(el: Element) {
    const { classList } = el;
    if (classList.contains('selected')) {
      this.clearSelection();
      return;
    }
    this.clearSelection();
    classList.add('selected');
    this.selectedObject = el;
  }

  clearSelection() {
    Array.from(document.getElementsByClassName('object')).forEach((el) => el.classList.remove('selected'));
    this.selectedObject = null;
  }
}

new App();
```

## 程式碼

- [paint](https://github.com/memochou1993/paint)

## 參考資料

- [Canvas API](https://developer.mozilla.org/zh-TW/docs/Web/API/Canvas_API)
