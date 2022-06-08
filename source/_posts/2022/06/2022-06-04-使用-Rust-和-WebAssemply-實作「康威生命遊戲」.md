---
title: 使用 Rust 和 WebAssemply 實作「康威生命遊戲」
permalink: 使用-Rust-和-WebAssemply-實作「康威生命遊戲」
date: 2022-06-04 20:49:01
tags: ["程式設計", "WebAssembly", "Rust", "JavaScript", "Canvas"]
categories: ["程式設計", "WebAssembly"]
---

## 前言

本文為「[Rust and WebAssembly](https://rustwasm.github.io/docs/book/)」教學指南的學習筆記。

## 介紹

康威生命遊戲（Conway's Game of Life），又稱康威生命棋，是英國數學家康威在 1970 年發明的細胞自動機。

- 規則一：任何活細胞周圍有低於兩個活細胞時，將因人口稀少而死亡。
- 規則二：任何活細胞周圍有兩至三個活細胞時，將存活至下個世代。
- 規則二：任何活細胞周圍有高於三個活細胞時，將因人口過剩而死亡。
- 規則四：任何死細胞周圍有剛好三個活細胞時，將因繁衍而成為活細胞。

例如，以下方世界（universe）為例：

```BASH
🟦🟦🟦🟦🟦
🟦🟦🟧🟦🟦
🟦🟦🟧🟦🟦
🟦🟦🟧🟦🟦
🟦🟦🟦🟦🟦
 1 2 3 4 5
```

座標 `3-2` 和 `3-4` 的活細胞，將因規則一死去；座標 `3-3` 的活細胞，將因規則二繼續存活；座標 `2-3` 和 `4-3` 的活細胞，將因規則四成為活細胞。

到了下個世代，細胞將形成以下狀態。

```BASH
🟦🟦🟦🟦🟦
🟦🟦🟦🟦🟦
🟦🟧🟧🟧🟦
🟦🟦🟦🟦🟦
🟦🟦🟦🟦🟦
 1 2 3 4 5
```

## 建立專案

建立專案。

```BASH
cargo generate --git https://github.com/rustwasm/wasm-pack-template --name wasm-game-of-life
```

進入專案。

```BASH
cd wasm-game-of-life
```

建立前端專案。

```BASH
npm init wasm-app www
```

進入前端專案。

```BASH
cd www
```

修改 `package.json` 檔。

```JSON
{
  // ...
  "dependencies": {
    "wasm-game-of-life": "file:../pkg"
  },
  // ...
}
```

安裝依賴套件。

```BASH
npm install
```

啟動前端專案。

```BASH
npm run start
```

## 架構設計

在程式中盡量最佳化以下兩件事情：

- 最小化從 WebAssembly 線性記憶體當中資料的存取。
- 最小化資料的序列化與反序列化。

因此，避免在每個世代把整個世界（universe）的物件複製進或複製出 WebAssembly 線性記憶體，而是使用扁平的陣列來表達當前世界的狀態，並使用 `0` 來表示死細胞，使用 `1` 來表示活細胞。

以下是一個高度為 `4` 且寬度為 `4` 的世界存在於記憶體中的樣子。

```BASH
0           4           8           12
🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲 🔲
    row1   |    row2   |    row3   |    row4
```

為了找出指定行列的細胞陣列索引，可以使用以下公式：

```BASH
index(row, column, universe) = row * width(universe) + column
```

## 後端實作

首先，修改 `src/lib.rs` 檔，定義一個 `Cell` 枚舉。這裡使用 `#[repr(u8)]` 屬性，用來表示每一個細胞都是一個位元組，並使用 `0` 來表示死細胞，使用 `1` 來表示活細胞，如此一來就可以使用加法來計算一個細胞的周圍存在多少活細胞。

```RS
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Cell {
    Dead = 0,
    Alive = 1,
}
```

再來，定義一個 `Universe` 結構體，包含了其寬度、高度，和一組細胞陣列。

```RS
#[wasm_bindgen]
pub struct Universe {
    width: u32,
    height: u32,
    cells: Vec<Cell>,
}
```

接著為 `Universe` 結構體建立一個 `get_index` 方法，用來取得指定行列的細胞陣列索引。

```RS
impl Universe {
    fn get_index(&self, row: u32, column: u32) -> usize {
        (row * self.width + column) as usize
    }

    // ...
}
```

再建立一個 `live_neighbor_count` 方法，用來取得一個細胞的周圍有多少活細胞。

```RS
impl Universe {
    // ...

    fn live_neighbor_count(&self, row: u32, column: u32) -> u8 {
        let mut count = 0;
        for delta_row in [self.height - 1, 0, 1].iter().cloned() {
            for delta_col in [self.width - 1, 0, 1].iter().cloned() {
                if delta_row == 0 && delta_col == 0 {
                    continue;
                }

                let neighbor_row = (row + delta_row) % self.height;
                let neighbor_col = (column + delta_col) % self.width;
                let idx = self.get_index(neighbor_row, neighbor_col);
                count += self.cells[idx] as u8;
            }
        }
        count
    }
}
```

建立一個帶有 `#[wasm_bindgen]` 屬性的 `Universe` 實作，將方法暴露給前端。

```RS
#[wasm_bindgen]
impl Universe {
  // ...
}
```

建立一個公開的 `tick` 方法，用來記算在下一個世代的細胞狀態。

```RS
#[wasm_bindgen]
impl Universe {
    pub fn tick(&mut self) {
        let mut next = self.cells.clone();

        for row in 0..self.height {
            for col in 0..self.width {
                let idx = self.get_index(row, col);
                let cell = self.cells[idx];
                let live_neighbors = self.live_neighbor_count(row, col);

                let next_cell = match (cell, live_neighbors) {
                    // Rule 1: Any live cell with fewer than two live neighbours
                    // dies, as if caused by underpopulation.
                    (Cell::Alive, x) if x < 2 => Cell::Dead,
                    // Rule 2: Any live cell with two or three live neighbours
                    // lives on to the next generation.
                    (Cell::Alive, 2) | (Cell::Alive, 3) => Cell::Alive,
                    // Rule 3: Any live cell with more than three live
                    // neighbours dies, as if by overpopulation.
                    (Cell::Alive, x) if x > 3 => Cell::Dead,
                    // Rule 4: Any dead cell with exactly three live neighbours
                    // becomes a live cell, as if by reproduction.
                    (Cell::Dead, 3) => Cell::Alive,
                    // All other cells remain in the same state.
                    (otherwise, _) => otherwise,
                };

                next[idx] = next_cell;
            }
        }

        self.cells = next;
    }

    // ...
}
```

為 `Universe` 結構體實作一個 `fmt` 方法，用來渲染出人類可讀的方塊圖形，並且可以使用 `to_string` 方法呼叫。

```RS
use std::fmt;

impl fmt::Display for Universe {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for line in self.cells.as_slice().chunks(self.width as usize) {
            for &cell in line {
                let symbol = if cell == Cell::Dead { '◻' } else { '◼' };
                write!(f, "{}", symbol)?;
            }
            write!(f, "\n")?;
        }

        Ok(())
    }
}
```

再為 `Universe` 結構體建立一個公開的 `new` 方法當作建構子，用來初始化一個新的世界。並建立一個 `render` 方法，用來渲染方塊圖形。

```RS
#[wasm_bindgen]
impl Universe {
    // ...

    pub fn new() -> Universe {
        let width = 64;
        let height = 64;

        let cells = (0..width * height)
            .map(|i| {
                if i % 2 == 0 || i % 7 == 0 {
                    Cell::Alive
                } else {
                    Cell::Dead
                }
            })
            .collect();

        Universe {
            width,
            height,
            cells,
        }
    }

    pub fn render(&self) -> String {
        self.to_string()
    }
}
```

執行編譯。

```BASH
wasm-pack build
```

## 前端實作

修改 `www/index.html` 檔。

```HTML
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Hello wasm-pack!</title>
    <style>
      body {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
      }
    </style>
  </head>
  <body>
    <pre id="game-of-life-canvas"></pre>
    <script src="./bootstrap.js"></script>
  </body>
</html>
```

修改 `www/index.js` 檔。

```JS
import { Universe } from "wasm-game-of-life";

const pre = document.getElementById("game-of-life-canvas");
const universe = Universe.new();

const renderLoop = () => {
  pre.textContent = universe.render();
  universe.tick();

  requestAnimationFrame(renderLoop);
};

requestAnimationFrame(renderLoop);
```

啟動服務。

```BASH
npm run start
```

前往 <http://localhost:8080/> 瀏覽。

## 重構

修改後端的 `src/lib.rs` 檔，建立以下公開方法。

```RS
#[wasm_bindgen]
impl Universe {
    // ...

    pub fn width(&self) -> u32 {
        self.width
    }

    pub fn height(&self) -> u32 {
        self.height
    }

    pub fn cells(&self) -> *const Cell {
        self.cells.as_ptr()
    }
}
```

修改 `www/index.html` 檔，將渲染的節點改為畫布。

```HTML
<body>
  <canvas id="game-of-life-canvas"></canvas>
  <script src="./bootstrap.js"></script>
</body>
```

修改 `www/index.js` 檔，引入 `wasm_game_of_life_bg` 檔的 `memory` 模組，直接存取指向細胞的指針，並寫入 `Uint8Array` 陣列使用。

```JS
import { Universe, Cell } from "wasm-game-of-life";
import { memory } from "wasm-game-of-life/wasm_game_of_life_bg";

const CELL_SIZE = 5;
const GRID_COLOR = "#CCCCCC";
const DEAD_COLOR = "#FFFFFF";
const ALIVE_COLOR = "#000000";

const universe = Universe.new();
const width = universe.width();
const height = universe.height();

const canvas = document.getElementById("game-of-life-canvas");
canvas.height = (CELL_SIZE + 1) * height + 1;
canvas.width = (CELL_SIZE + 1) * width + 1;

const ctx = canvas.getContext('2d');

const renderLoop = () => {
  universe.tick();

  drawGrid();
  drawCells();
  requestAnimationFrame(renderLoop);
};

const drawGrid = () => {
  ctx.beginPath();
  ctx.strokeStyle = GRID_COLOR;

  // Vertical lines.
  for (let i = 0; i <= width; i++) {
    ctx.moveTo(i * (CELL_SIZE + 1) + 1, 0);
    ctx.lineTo(i * (CELL_SIZE + 1) + 1, (CELL_SIZE + 1) * height + 1);
  }

  // Horizontal lines.
  for (let j = 0; j <= height; j++) {
    ctx.moveTo(0, j * (CELL_SIZE + 1) + 1);
    ctx.lineTo((CELL_SIZE + 1) * width + 1, j * (CELL_SIZE + 1) + 1);
  }

  ctx.stroke();
};

const getIndex = (row, column) => {
  return row * width + column;
};

const drawCells = () => {
  const cellsPtr = universe.cells();
  const cells = new Uint8Array(memory.buffer, cellsPtr, width * height);

  ctx.beginPath();

  for (let row = 0; row < height; row++) {
    for (let col = 0; col < width; col++) {
      const idx = getIndex(row, col);

      ctx.fillStyle = cells[idx] === Cell.Dead
        ? DEAD_COLOR
        : ALIVE_COLOR;

      ctx.fillRect(
        col * (CELL_SIZE + 1) + 1,
        row * (CELL_SIZE + 1) + 1,
        CELL_SIZE,
        CELL_SIZE
      );
    }
  }

  ctx.stroke();
};

drawGrid();
drawCells();
requestAnimationFrame(renderLoop);
```

重新執行編譯。

```BASH
wasm-pack build
```

重新啟動服務。

```BASH
npm run start
```

前往 <http://localhost:8080/> 瀏覽。

## 程式碼

- [wasm-game-of-life](https://github.com/memochou1993/wasm-game-of-life)

## 參考資料

- [Rust and WebAssembly](https://rustwasm.github.io/docs/book/)
