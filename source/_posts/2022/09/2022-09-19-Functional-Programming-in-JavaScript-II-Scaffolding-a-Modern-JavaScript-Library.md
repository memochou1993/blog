---
title: >-
  Functional Programming in JavaScript (II): Scaffolding a Modern JavaScript
  Library
date: 2022-09-19 23:19:12
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

### Initialize a project with Vite

Create a new project. [[?]](https://vitejs.dev/guide/#scaffolding-your-first-vite-project)

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

Open VS Code editor. [[?]](https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line)

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

Create a `vite.config.js` file. [[?]](https://vitejs.dev/guide/build.html#library-mode)

```js
import { resolve } from 'path';
import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'CollectionJS',
      fileName: (format) => `collection-js.${format}.js`,
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
npm install @types/node --save-dev
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
  "main": "./dist/collection-js.umd.js",
  "module": "./dist/collection-js.es.js",
  "exports": {
    ".": {
      "import": "./dist/collection-js.es.js",
      "require": "./dist/collection-js.umd.js"
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
    <script src="/dist/collection-js.umd.js"></script>
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
    <script type="module">
      import { hello } from '/dist/collection-js.es.js';
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
  </body>
</html>
```

Write a new commit message.

```bash
git add .
git commit -m "Add build config"
```

### Initialize ESLint and EditorConfig

Create a `.editorconfig` file. [[?]](https://editorconfig.org/)

```editorconfig
root = true

[*]
indent_size = 2
```

Initialize ESLint and install dependencies. [[?]](https://eslint.org/docs/latest/user-guide/getting-started)

```bash
npm init @eslint/config
✔ How would you like to use ESLint? · syntax
✔ What type of modules does your project use? · esm
✔ Which framework does your project use? · none
✔ Does your project use TypeScript? · No / Yes
✔ Where does your code run? · browser, node
✔ What format do you want your config file to be in? · JavaScript
✔ Would you like to install them now? · No / Yes
✔ Which package manager do you want to use? · npm
```

Install Airbnb ESLint config and install dependencies. [[?]](https://www.npmjs.com/package/eslint-config-airbnb)

```bash
npm install eslint-config-airbnb-typescript \
    eslint-plugin-import \
    --save-dev
```

Update `.eslintrc.cjs` file. [[?]](https://eslint.org/docs/latest/user-guide/configuring/configuration-files#how-do-overrides-work)

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

### Implement a "map" function

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

Install dependencies. [[?](https://vitest.dev/guide/)]

```bash
npm install vitest @vitest/coverage-c8 --save-dev
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

Create a `map.test.ts` file in `modules` folder, and create a test case for the `map` function.

```ts
import { test, expect } from 'vitest';
import { map } from './index';

test('map should work', () => {
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

## Source Code

- [functional-programming-workshop](https://github.com/memochou1993/functional-programming-workshop)
- [js-array-methods](https://github.com/memochou1993/js-array-methods)
- [collection-js](https://github.com/memochou1993/collection-js)
