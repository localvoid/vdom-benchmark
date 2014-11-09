# Virtual DOM diff/patch benchmark

Comparing performance of the diff/patch operations in various virtual
dom libraries.

- [VDom](https://github.com/localvoid/vdom) (Dart)
- [React](http://facebook.github.io/react/) (JavaScript)
- [Mithril](http://lhorie.github.io/mithril/index.html) (JavaScript)
- [VirtualDom](https://github.com/Matt-Esch/virtual-dom) (JavaScript)
- [Bobril](https://github.com/Bobris/Bobril) (TypeScript)

## [Run benchmark](http://localvoid.github.io/vdom-benchmark/)

## Dev

### Dependencies

- [Dart SDK](https://www.dartlang.org/tools/sdk/)
- [Node.js](http://nodejs.org/)
- [npm](https://www.npmjs.org/)
- [gulp](http://gulpjs.com/)

### Build instructions

```sh
$ npm install
$ NODE_ENV=production gulp
$ pub build --mode=release
```

### Dev server

```sh
$ pub serve --mode=release
```