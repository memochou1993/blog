---
title: 在 TypeScript 專案使用 Ajv 套件實現 JSON Schema 驗證
date: 2024-11-09 02:57:48
tags: ["Programming", "JavaScript", "TypeScript", "JSON Schema"]
categories: ["Programming", "JavaScript", "TypeScript"]
---

## 實作

安裝套件。

```bash
npm install ajv
```

新增 `validate.ts` 檔。

```ts
import Ajv, { ValidateFunction } from 'ajv';

const ajv = new Ajv();

const schemaCache = new Map<string, ValidateFunction>();

const validate = (schema: Record<string, unknown>) => {
  const validate = compileSchema(schema);
  return (input: unknown): boolean | string => {
    if (!input) return false;
    if (typeof input === 'string') {
      try {
        input = JSON.parse(input);
      } catch (err) {
        console.warn(err);
        return false;
      }
    }
    if (validate(input)) return true;
    const { errors } = validate;
    if (Array.isArray(errors)) {
      const [error] = errors;
      const { instancePath, message } = error;
      return instancePath
        ? `The property at path "${instancePath}" ${message}.`
        : `The json schema field ${message}.`;
    }
    return false;
  };
};

const compileSchema = (schema: Record<string, unknown>): ValidateFunction => {
  const cacheKey = JSON.stringify(schema);
  const cached = schemaCache.get(cacheKey);
  if (cached) return cached;
  try {
    const validate = ajv.compile(schema);
    schemaCache.set(cacheKey, validate);
    return validate;
  } catch (err) {
    throw new Error(`Invalid schema: ${(err as Error).message.replace('schema is invalid: ', '')}`);
  }
};

export default validate;
```

新增 `index.ts` 檔。

```ts
import validate from './validate';

const schema = {
  type: 'object',
  properties: {
    name: {
      type: 'string',
    },
    age: {
      type: 'number',
    },
  },
};

const input = { name: 'Memo Chou', age: true };

const result = validate(schema)(input);

console.log(result);
```

執行腳本。

```bash
bun index.ts
```

輸出如下：

```bash
The property at path "/age" must be number.
```

## 參考資料

- [Ajv - JSON schema validator](https://ajv.js.org/)
