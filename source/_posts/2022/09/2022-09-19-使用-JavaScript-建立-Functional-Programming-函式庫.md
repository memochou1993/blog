---
title: 建立「Functional Programming in JavaScript」工作坊
permalink: 建立「Functional-Programming-in-JavaScript」工作坊
date: 2022-09-19 23:19:11
tags: ["程式設計", "JavaScript", "Functional Programming", "TDD", "Testing", "Workshop"]
categories: ["程式設計", "JavaScript", "其他"]
---

## Topics

- Functional Programming in JavaScript
- Building a Modern JavaScript Library with Vite
- Unit Testing with Jest and Vitest

## Procedure

- 📜 Check out the [slide](https://docs.google.com/presentation/d/14Navycm3I2oFvE0DdUNzVtvLhRRs1BM_V2xTy_azRt0/edit?usp=sharing)
- 💪 Work in groups
- 🔨 Collaborate with [Live Share](https://code.visualstudio.com/learn/collaboration/live-share)

## Agenda

### Part I: Practicing JavaScript ES6 Array Methods with Unit Testing

- 📅 Date: 2022-09-19
- 🚀 [Getting Started](#Part-I)

### Part II: Knowing Functional Programming and Scaffolding a Modern JavaScript Library

- 📅 Date: 2022-09-26
- 🚀 [Getting Started](#Part-II)

### Part III: Implementing of Higher-Order Functions with Test-Driven Development

- 📅 Date: 2022-10-03
- 🚀 [Getting Started](#Part-III)

### Part IV: Implementing of Method Chaining with OOP

- 📅 Date: 2022-10-17
- 🚀 [Getting Started](#Part-IV)

## Part I

### Initialize a project

Create a new project.

```bash
mkdir js-array-methods
cd js-array-methods
```

Open VS Code editor. [[How?]](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line)

```bash
code .
```

Create a `package.json` file.

```bash
npm init --yes
```

### Unit test in JavaScript with Jest

Install dependencies. [[How?]](https://jestjs.io/docs/getting-started)

```bash
npm install jest --save-dev
```

Update `package.json` file, add a `test` command to `scripts` field.

```json
{
  // ...
  "scripts": {
    "test": "jest"
  }
}
```

Create an `src` folder.

```bash
mkdir src
```

Create an `index.test.js` file in `src` folder.

```js
const sum = (a, b) => {
  return a + b;
};

test('adds 1 + 2 to equal 3', () => {
  expect(sum(1, 2)).toBe(3);
});
```

Run `test` command.

```bash
npm run test

> js-array-methods@1.0.0 test
> jest

 PASS  src/index.test.js
  ✓ adds 1 + 2 to equal 3 (6 ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   0 total
Time:        0.525 s, estimated 1 s
Ran all test suites.
```

### Unit test for JavaScript array methods

Create some test cases for JavaScript Array Methods.

```js
test('all number are less than 10', () => {
  const actual = [1, 2, 3, 4, 5].every((n) => n < 10);
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

Run `test` command.

```bash
npm run test
```

### Use fake data

Create a `products.js` file in `src` folder and grab some fake data from [here](https://dummyjson.com/products).

```js
const products = [
  // ...
];

module.exports = products;
```

Use fake data and create more test cases.

```js
const products = require('./products');

test('all product prices are less than 5000', () => {
  const actual = products
    .every((product) => product.price < 5000);
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

Run `test` command.

```bash
npm run test
```

### Solve problems

- Teamwork:
  - problem A1~A8 for group A
  - problem B1~B8 for group B
- Array Methods to use: `every`, `filter`, `find`, `forEach`, `map`, `reduce` and `some`

#### Problem A1

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem A2

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem A3

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem A4

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem A5

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem A6

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem A7

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem A8

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B1

```js
test('all products have one image at least', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B2

```js
test('there is a product which description says "no side effects"', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B3

```js
test('the number of Apple smartphones is 2', () => {
  const actual = products; // FIXME
  const expected = 2;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B4

```js
test('the products get over 4.9 rating are fauji and Golden', () => {
  const actual = products; // FIXME
  const expected = [{ brand: 'fauji' }, { brand: 'Golden' }];

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B5

```js
test('the only product of Dry Rose is "Gulab Powder 50 Gram"', () => {
  const actual = products; // FIXME
  const expected = 'Gulab Powder 50 Gram';

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B6

```js
test('the total revenue is 765,200 if all the products sold without discount', () => {
  const actual = products; // FIXME
  const expected = 765200;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B7

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

#### Problem B8

```js
const products = require('./products');

test('...', () => {
  const actual = products; // FIXME
  const expected = true;

  expect(actual).toStrictEqual(expected);
});
```

## Part II

### Initialize a project with Vite

Create a new project. [[How?]](https://vitejs.dev/guide/#scaffolding-your-first-vite-project)

```bash
npm create vite@latest
✔ Project name: … collection-js
✔ Select a framework: › vanilla
✔ Select a variant: › vanilla-ts
```

Install dependencies.

```bash
cd collection-js
npm install
```

Open VS Code editor. [[How?]](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line)

```bash
code .
```

### Initialize a Git repository

Write an initial commit message.

```bash
git init
git add .
git commit -m "Initial commit"
```

Create a repository from [GitHub](https://github.com/).

Push commits to remote.

```bash
git remote add origin git@github.com:<username>/collection-js.git
git push -u origin main
```

### Tidy up the project

Remove sample files.

```bash
rm src/*
```

Write a new commit message.

```bash
git add .
git commit -m "Remove sample files"
```

### Build with library mode

Create a `vite.config.js` file. [[How?]](https://vitejs.dev/guide/build.html#library-mode)

```js
import { resolve } from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'CollectionJS',
      fileName: 'collection-js',
    },
    rollupOptions: {
      external: [],
      output: {
        globals: {
        },
      },
    },
  },
});
```

Install dependencies.

```bash
npm i @types/node --save-dev
```

Create a `index.ts` file in `src` folder as an entry point.

```js
const hello = () => {
  console.log('Hello');
};

export {
  hello,
};
```

Update `package.json` file.

```json
{
  // ...
  "type": "module",
  "files": [
    "dist"
  ],
  "main": "./dist/collection-js.umd.cjs",
  "module": "./dist/collection-js.js",
  "exports": {
    ".": {
      "import": "./dist/collection-js.js",
      "require": "./dist/collection-js.umd.cjs"
    }
  },
}
```

Run `build` command.

```bash
npm run build
```

#### Try with UMD module

Update `index.html` file.

```html
<!DOCTYPE html>
<html lang="en">
  <!-- ... -->
  <body>
    <div id="app"></div>
    <script src="/dist/collection-js.umd.cjs"></script>
    <script>
      window.CollectionJS.hello();
    </script>
  </body>
</html>
```

Start a server.

```bash
npm run dev
```

#### Try with ES module

Update `index.html` file.

```html
<!DOCTYPE html>
<html lang="en">
  <!-- ... -->
  <body>
    <div id="app"></div>
    <script type="module" src="/dist/collection-js"></script>
    <script type="module">
      import { hello } from '/dist/collection-js';
      hello();
    </script>
  </body>
</html>
```

Start a server.

```bash
npm run dev
```

#### Tidy up

Fix `index.html` file.

```html
<!DOCTYPE html>
<html lang="en">
  <!-- ... -->
  <body>
    <div id="app"></div>
    <script type="module" src="/dist/collection-js"></script>
  </body>
</html>
```

Write a new commit message.

```bash
git add .
git commit -m "Add build config"
```

### Initialize ESLint and EditorConfig

Create a `.editorconfig` file. [[How?]](https://editorconfig.org/)

```editorconfig
root = true

[*]
indent_size = 2
```

Initialize ESLint and install dependencies. [[How?]](https://eslint.org/docs/latest/user-guide/getting-started)

```bash
npm init @eslint/config
✔ How would you like to use ESLint? · syntax
✔ What type of modules does your project use? · esm
✔ Which framework does your project use? · none
✔ Does your project use TypeScript? · Yes
✔ Where does your code run? · browser, node
✔ What format do you want your config file to be in? · JavaScript
✔ Would you like to install them now? · Yes
✔ Which package manager do you want to use? · npm
```

Install Airbnb ESLint config and install dependencies. [[How?]](https://www.npmjs.com/package/eslint-config-airbnb)

```bash
npm install eslint-config-airbnb-typescript \
    eslint-plugin-import \
    --save-dev
```

Update `.eslintrc.cjs` file. [[How?]](https://eslint.org/docs/latest/user-guide/configuring/configuration-files#how-do-overrides-work)

```JS
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true
  },
  overrides: [
    {
      files: [
        'src/**/*.ts',
        'src/**/*.tsx',
      ],
      extends: [
        'airbnb-typescript/base',
        'plugin:import/recommended',
      ],
      parserOptions: {
        project: [
          './tsconfig.json',
        ],
      },
    },
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  plugins: [
    '@typescript-eslint'
  ],
  rules: {
  },
};
```

Update `package.json` file, add a `lint` command to scripts field.

```json
{
  "scripts": {
    // ...
    "lint": "eslint src"
  }
}
```

Run `lint` command.

```bash
npm run lint
```

Write a new commit message.

```bash
git add .
git commit -m "Add eslint config"
```

### Implement a "map" function with TypeScript

Create a `modules` folder in `src` folder.

```bash
mkdir src/modules
```

Create a `map.ts` file in `modules` folder, and implement a `map` function.

```js
const map = (items: Array<any>, callable: Function) => {
  const res = [];
  for (let i = 0; i < items.length; i++) {
    res[i] = callable(items[i]);
  }
  return res;
};

export default map;
```

Create an `index.ts` file in `modules` folder, then import and export the module.

```js
import map from './map';

export {
  map,
};
```

### Unit test with Vitest

Install dependencies. [[How?](https://vitest.dev/guide/)]

```bash
npm i vitest @vitest/coverage-c8 --save-dev
```

Update `package.json` file, add `test` and `coverage` commands to scripts field.

```json
{
  "scripts": {
    // ...
    "test": "vitest",
    "coverage": "vitest run --coverage"
  }
}
```

Create a `map.test.ts` file in `modules` folder, and write a test case for the `map` function.

```ts
import { test, expect } from 'vitest';
import { map } from './index';

test('map', () => {
  const actual = map([1, 2, 3, 4, 5], (v: number) => v * 2);
  const expected = [2, 4, 6, 8, 10];

  expect(actual).toStrictEqual(expected);
});
```

Run `test` command.

```bash
npm run test

> collection-ts@0.0.0 test
> vitest


 DEV  v0.22.1 /Users/memochou/Projects/collection-js

 ✓ src/modules/map.test.ts (1)
 ✓ src/index.test.ts (11)

Test Files  2 passed (2)
     Tests  12 passed (12)
  Start at  23:01:17
  Duration  950ms (transform 541ms, setup 0ms, collect 140ms, tests 18ms)
```

Run `coverage` command.

```bash
npm run coverage

> collection-ts@0.0.0 coverage
> vitest run --coverage


 RUN  v0.22.1 /Users/memochou/Projects/collection-js
      Coverage enabled with c8

 ✓ src/modules/map.test.ts (1)

Test Files  1 passed (1)
     Tests  1 passed (1)
  Start at  23:03:08
  Duration  1.35s (transform 447ms, setup 0ms, collect 50ms, tests 3ms)

 % Coverage report from c8
----------|---------|----------|---------|---------|-------------------
File      | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s 
----------|---------|----------|---------|---------|-------------------
All files |     100 |      100 |     100 |     100 |                   
 index.ts |     100 |      100 |     100 |     100 |                   
 map.ts   |     100 |      100 |     100 |     100 |                   
----------|---------|----------|---------|---------|-------------------
```

Update `.gitignore` file.

```env
# ...
coverage
```

Write a new commit message.

```bash
git add .
git commit -m "Implement map function"
```

## Part III

### The three rules of TDD

Robert C. Martin provides [a concise set of rules](http://butunclebob.com/ArticleS.UncleBob.TheThreeRulesOfTdd) for practicing TDD.

1. You are not allowed to write any production code unless it is to make a failing unit test pass.
2. You are not allowed to write any more of a unit test than is sufficient to fail; and compilation failures are failures.
3. You are not allowed to write any more production code than is sufficient to pass the one failing unit test.

### Write a test case for “filter” function

Create a `filter.test.ts` file in `modules` folder, and write a test case for `filter` function.

```ts
import { test, expect } from 'vitest';
import { filter } from './index';

test('filter', () => {
  const actual = filter([1, 2, 3, 4, 5], (v: number) => v > 2);
  const expected = [3, 4, 5];

  expect(actual).toStrictEqual(expected);
});
```

Run `test` command.

```bash
npm run test

🔴 FAIL  src/modules/filter.test.ts > filter
TypeError: filter is not a function
```

### Implement the “filter” function

Update `index.ts` file in `modules` folder.

```ts
// ...
import filter from './filter';

export {
  // ...
  filter,
};
```

Create a `filter.ts` file in `modules` folder, and implement the `filter` function.

```ts
const filter = (items: Array<any>, callable: Function) => {
  const res = [];
  for (let i = 0; i < items.length; i++) {
    if (callable(items[i])) {
      res.push(items[i]);
    }
  }
  return res;
};

export default filter;
```

Run `test` command.

```bash
npm run test

🟢 PASS  Waiting for file changes...
```

### Implement more higher-order functions with TDD

- [ ] every
- [x] filter
- [ ] find
- [ ] forEach
- [x] map
- [ ] reduce
- [ ] reject
- [ ] some

## Part IV

### Example of method chaining

- JavaScript: <https://lodash.com/docs/4.17.15#chain>
- PHP: <https://laravel.com/docs/9.x/collections>

```js
collect([1, 2, 3])
  .map((v: number) => v * 2)
  .filter((v: number) => v < 5)
  .toArray();
```

### Create a test case for "map" function

Create an `index.test.ts` file in `src` folder.

```js
import { test, expect } from 'vitest';
import { collect } from './index';

test('method chaining', () => {
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

### Implement a "Collection" class

Create an `index.ts` file in `src` folder.

```js
class Collection {
  private items;

  constructor(items: Array<any>) {
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
  private items;

  constructor(items: Array<any>) {
    this.items = items;
  }

  map(callable: Function) {
    this.items = map(this.items, callable);
    return this;
  }
}
```

Implement a `toArray` function for the class, and return the `items` array.

```js
class Collection {
  // ...

  toArray() {
    return this.items;
  }
}
```

Create a `collect` helper function, and return an initialized `Collection` instance.

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

### Implement more functions for the class

- [ ] every
- [ ] filter
- [ ] find
- [ ] forEach
- [ ] includes
- [x] map
- [ ] reduce
- [ ] reject
- [ ] size
- [ ] some

Run `coverage` command finally.

```bash
npm run coverage
```

## Repositories

- [memochou1993/js-array-methods](https://github.com/memochou1993/js-array-methods)
- [memochou1993/collection-js](https://github.com/memochou1993/collection-js)
