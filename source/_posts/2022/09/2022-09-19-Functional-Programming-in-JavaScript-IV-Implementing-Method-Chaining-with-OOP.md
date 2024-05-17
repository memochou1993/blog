---
title: >-
  Functional Programming in JavaScript (IV): Implementing Method Chaining with
  OOP
date: 2022-09-19 23:19:14
tags: ["Programming", "JavaScript", "TypeScript", "Vite", "Functional Programming", "TDD", "Testing", "Workshop"]
categories: ["Programming", "JavaScript", "Others"]
---

## Topics

- Functional Programming in JavaScript
- Building a Modern JavaScript Library with Vite
- Unit Testing with Jest and Vitest

## Resources

- 📖 Check out the [handbook](https://memochou1993.github.io/functional-programming-workshop/)
- 📜 Check out the [slide](https://docs.google.com/presentation/d/14Navycm3I2oFvE0DdUNzVtvLhRRs1BM_V2xTy_azRt0/edit?usp=sharing)
- 💪 Work in groups
- 🔨 Collaborate with [Live Share](https://code.visualstudio.com/learn/collaboration/live-share)

## Workshop

### Example of method chaining

Implementations in defferent languages:

- JavaScript: <https://lodash.com/docs/4.17.15#chain>
- PHP: <https://laravel.com/docs/9.x/collections>

```js
collect([1, 2, 3])
  .map((v: number) => v * 2)
  .filter((v: number) => v < 5)
  .toArray();
```

### Create test case for "map" function

Create an `index.test.ts` file in `src` folder.

```js
import { test, expect } from 'vitest';
import { collect } from './index';

test('map should work', () => {
  const actual = collect([1, 2, 3, 4, 5])
    .map((v: number) => v * 2)
    .toArray();
  const expected = [2, 4, 6, 8, 10];

  expect(actual).toStrictEqual(expected);
});
```

Run `test` command.

```bash
npm run test

🔴 FAIL  src/index.test.ts > method chaining
TypeError: collect is not a function
```

### Implement "map" function

Update `index.ts` file in `src` folder, and create a `Collection` class.

```js
class Collection {
  private items;

  constructor(items: Array<any> = []) {
    this.items = items;
  }
}
```

Implement a `map` function for the class, and return the class itself.

```js
import {
  map,
} from './modules';

class Collection {
  // ...

  map(callable: Function) {
    this.items = map(this.items, callable);
    return this;
  }
}
```

Implement a `toArray` function for the class, and return the array data.

```js
class Collection {
  // ...

  toArray() {
    return this.items;
  }
}
```

Create a `collect` helper function, and return a `Collection` instance.

```js
// ...

const collect = (items: Array<any>): Collection => new Collection(items);

export {
  collect,
};
```

Run `test` command.

```bash
npm run test

🟢 PASS  Waiting for file changes...
```

### Implement more functions

Implement more functions for the class with TDD:

- map ✅
- every
- filter
- find
- forEach
- includes
- reduce
- reject
- size
- some

Finally, run `coverage` command.

```bash
npm run coverage
```

### Publish to NPM

Build the package before publishing.

```bash
npm run build
```

Login to NPM.

```bash
npm login
```

Update `package.json` file.

```json
{
  "name": "@username/collection-js",
  "private": false,
  "version": "1.1.0",
  // ...
}
```

Publish to NPM with dry run.

```bash
npm publish --dry-run
```

Publish to NPM.

```bash
npm publish --access=public
```

### Use package

#### Try with UMD module

Update `index.html` file.

```html
<!DOCTYPE html>
<html lang="en">
  <!-- ... -->
  <body>
    <div id="app"></div>
    <script src="https://unpkg.com/@username/collection-js"></script>
    <script>
      const res = window.CollectionJS.collect([1, 2, 3, 4, 5])
        .map((v) => v * 2)
        .toArray();

      console.log(res);
    </script>
  </body>
</html>
```

#### Try with ES module

Install dependencies.

```bash
npm install @memochou1993/collection-js@latest
```

Update `index.html` file.

```html
<!DOCTYPE html>
<html lang="en">
  <!-- ... -->
  <body>
    <div id="app"></div>
    <script type="module">
      import { collect } from '@memochou1993/collection-js';

      const res = collect([1, 2, 3, 4, 5])
        .map((v) => v * 2)
        .toArray();

      console.log(res);
    </script>
  </body>
</html>
```

Start a server.

```bash
npm run dev
```

## Source Code

- [functional-programming-workshop](https://github.com/memochou1993/functional-programming-workshop)
- [js-array-methods](https://github.com/memochou1993/js-array-methods)
- [collection-js](https://github.com/memochou1993/collection-js)
