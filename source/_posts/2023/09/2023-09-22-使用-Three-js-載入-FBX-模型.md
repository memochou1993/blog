---
title: 使用 Three.js 載入 FBX 模型
date: 2023-09-22 00:38:02
tags: ["程式設計", "JavaScript", "Three.js"]
categories: ["程式設計", "JavaScript", "其他"]
---

## 建立專案

建立專案。

```bash
npm create vite@latest
cd three-fbx-example
```

安裝套件。

```bash
npm install three@latest
```

## 實作

修改 `style.css` 檔。

```css
body {
  margin: 0;
}
```

修改 `main.js` 檔。

```js
import './style.css'
import * as THREE from 'three'
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { FBXLoader } from 'three/addons/loaders/FBXLoader.js';
import Stats from 'three/addons/libs/stats.module';

// 建立場景
const scene = new THREE.Scene()
scene.add(new THREE.AxesHelper(5)) // 添加坐標輔助線

// 添加照明
const light = new THREE.PointLight(0xffffff, 20)
light.position.set(0.8, 1.4, 1.0)
scene.add(light)

// 添加環境光
const ambientLight = new THREE.AmbientLight(0xffffff, 5)
scene.add(ambientLight)

// 創建相機
const camera = new THREE.PerspectiveCamera(
  100, // 視野角度
  window.innerWidth / window.innerHeight, // 寬高比
  0.1, // 近裁剪面
  1000 // 遠裁剪面
)
camera.position.set(0.8, 0.6, 1.0) // 設置相機位置

// 創建渲染器
const renderer = new THREE.WebGLRenderer({ alpha: true }) // 將背景設成透明
renderer.setSize(window.innerWidth, window.innerHeight)
document.body.appendChild(renderer.domElement)

// 創建 OrbitControls 控制器，用戶可以控制相機
const controls = new OrbitControls(camera, renderer.domElement)
controls.enableDamping = true
controls.target.set(0, 0.6, 0)

// 使用 FBXLoader 載入3D模型
const fbxLoader = new FBXLoader()
fbxLoader.load(
  'models/example.fbx', // 載入模型
  (object) => {
    object.scale.set(.005, .005, .005)
    scene.add(object)
  },
  (xhr) => {
    console.log((xhr.loaded / xhr.total) * 100 + '% loaded')
  },
  (error) => {
    console.log(error)
  }
)

// 監聽窗口大小變化事件，並調整相機和渲染器大小
window.addEventListener('resize', onWindowResize, false)
function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize(window.innerWidth, window.innerHeight)
  render()
}

// 創建性能統計模組
const stats = new Stats()
document.body.appendChild(stats.dom)

// 定義動畫函數，不斷更新渲染
function animate() {
  // 使用 requestAnimationFrame 實現平滑的動畫
  requestAnimationFrame(animate)
  // 更新控制器
  controls.update()
  // 渲染場景
  render()
  // 更新性能統計
  stats.update()
}

// 渲染函數
function render() {
  // 使用渲染器渲染場景
  renderer.render(scene, camera)
}

// 開始動畫循環
animate()
```

啟動服務。

```bash
npm run dev
```

## 瀏覽網頁

前往 <http://127.0.0.1:3000> 瀏覽。

## 程式碼

- [three-fbx-example](https://github.com/memochou1993/three-fbx-example)

## 參考文件

- [Three.js - FBX Model Loader](https://sbcode.net/threejs/loaders-fbx/)
