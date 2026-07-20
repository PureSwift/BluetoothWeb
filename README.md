# BluetoothWeb
Swift library for Bluetooth Web API (WebAssembly)

Try [demo](https://pureswift.github.io/BluetoothWeb) (only Chrome and Opera are supported).

![demo](https://user-images.githubusercontent.com/3419766/147490037-905dcd3a-97d2-4762-abbc-05b9a39c74b1.gif)

## Requirements

- Swift 6.3 or later with a matching [Swift SDK for WebAssembly](https://www.swift.org/documentation/articles/wasm-getting-started.html)
- Node.js 22 or later
- `wasm-opt` (optional, for optimized release builds)

## Building

The `BluetoothExplorer` demo app is built with [ElementaryUI](https://github.com/elementary-swift/elementary-ui) and bundled with [Vite](https://vite.dev).

```sh
npm install

# Start development server with hot reload
npm run dev

# Build in release and bundle for deployment
npm run build

# Preview the built web app locally
npm run preview
```
