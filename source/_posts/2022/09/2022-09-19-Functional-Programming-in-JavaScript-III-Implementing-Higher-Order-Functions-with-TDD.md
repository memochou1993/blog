---
title: >-
  Functional Programming in JavaScript (III): Implementing Higher-Order
  Functions with TDD
date: 2022-09-19 23:19:13
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

### The three rules of TDD

Robert C. Martin provides a concise set of rules for practicing Test-Driven Development. [[?]](http://butunclebob.com/ArticleS.UncleBob.TheThreeRulesOfTdd)

1. You are not allowed to write any production code unless it is to make a failing unit test pass.
2. You are not allowed to write any more of a unit test than is sufficient to fail; and compilation failures are failures.
3. You are not allowed to write any more production code than is sufficient to pass the one failing unit test.

### Create test case for “filter” function

Create a `filter.test.ts` file in `modules` folder, and create a test case for `filter` function.

```ts
import { test, expect } from 'vitest';
import { filter } from './index';

test('filter should work', () => {
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

### Implement “filter” function

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

### Implement more functions

Implement more higher-order functions with TDD:

- map ✅
- filter ✅
- every
- find
- forEach
- reduce
- reject
- some

Finally, run `coverage` command.

```bash
npm run coverage
```

### Publish to NPM

Update `index.ts` file in `src` folder.

```ts
export * from './modules';
```

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
  "version": "1.0.0",
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

## Source Code

- [functional-programming-workshop](https://github.com/memochou1993/functional-programming-workshop)
- [js-array-methods](https://github.com/memochou1993/js-array-methods)
- [collection-js](https://github.com/memochou1993/collection-js)
