---
title: 在 React 專案使用 Three.js 套件渲染 3D 模型
date: 2023-10-04 23:44:41
tags: ["程式設計", "JavaScript", "React", "Three.js"]
categories: ["程式設計", "JavaScript", "React"]
---

## 建立專案

建立專案

```bash
npm create vite@latest
cd three-react-example
```

安裝套件。

```bash
npm install three @types/three @react-three/fiber
```

## 實作

修改 `App.jsx` 檔。

```js
import { useRef, useState } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'

function Box(props) {
  // 創建一個對 3D 物體的引用
  const meshRef = useRef()
  // 追蹤滑鼠是否懸停在方塊上
  const [hovered, setHover] = useState(false)
  // 追蹤方塊是否被點擊
  const [active, setActive] = useState(false)
  // 更新 3D 物體的旋轉
  useFrame((state, delta) => {
    meshRef.current.rotation.x += delta;
  })
  return (
    <mesh
      {...props}
      ref={meshRef}
      scale={active ? 1.5 : 1}
      onClick={() => setActive(!active)}
      onPointerOver={() => setHover(true)}
      onPointerOut={() => setHover(false)}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color={hovered ? 'hotpink' : 'orange'} />
    </mesh>
  )
}

export default function App() {
  return (
    <Canvas>
      <ambientLight />
      <pointLight position={[10, 10, 10]} />
      <Box position={[-1.2, 0, 0]} />
      <Box position={[1.2, 0, 0]} />
    </Canvas>
  )
}
```

修改 `index.css` 檔。

```css
html,
body,
#root {
  width: 100%;
  height: 100%;
  margin: 0;
}
```

啟動服務。

```bash
npm run dev
```

## 程式碼

- [three-react-example](https://github.com/memochou1993/three-react-example)

## 參考資料

- [React Three Fiber](https://docs.pmnd.rs/react-three-fiber)
