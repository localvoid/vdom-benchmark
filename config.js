benchmarkConfig({
  "name": "VDom Benchmark",
  "description": "Comparing performance of the diff/patch operations in various virtual dom libraries.",
  "data": {
    "type": "script",
    "url": "http://localvoid.github.io/vdom-benchmark/generator.js"
  },
  "contestants": [
    {
      "name": "kivi",
      "benchmarkUrl": "http://localvoid.github.io/vdom-benchmark-kivi/"
    },
    {
      "name": "cito.js",
      "benchmarkUrl": "http://localvoid.github.io/vdom-benchmark-cito/"
    },
    {
      "name": "Bobril",
      "benchmarkUrl": "http://localvoid.github.io/vdom-benchmark-bobril/"
    }
  ]
});
