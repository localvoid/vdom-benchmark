function Node(key, children, container) {
  this.key = key;
  this.children = children;
  this.container = container;
}

function convertToNative(nodes) {
  if (nodes === null) {
    return null;
  }
  var result = [];
  nodes.forEach(function(n) {
    result.push(new Node(n.key, convertToNative(n.children), n.container));
  });
  return result;
}

function Result() {
  this.renderTime = 0;
  this.updateTime = 0;
}

Result.prototype.avg = function(n) {
  this.renderTime /= n;
  this.updateTime /= n;
};

function runBenchmark(benchmark, a, b, c) {
  var a2 = convertToNative(a);
  var b2 = convertToNative(b);
  var c2 = document.getElementById(c);

  var benchmarkInstance = new benchmark(a2, b2, c2);

  // warmup
  benchmarkInstance.setUp();
  benchmarkInstance.render();
  benchmarkInstance.update();
  benchmarkInstance.tearDown();

  var r = new Result();
  for (var j = 0; j < 3; j++) {
    benchmarkInstance.setUp();

    var t0 = window.performance.now();
    benchmarkInstance.render();
    var t1 = window.performance.now();
    r.renderTime += (t1 - t0) * 1000;

    t0 = window.performance.now();
    benchmarkInstance.update();
    t1 = window.performance.now();
    r.updateTime += (t1 - t0) * 1000;

    benchmarkInstance.tearDown();
  }
  r.avg(3);

  return r;
}

module.exports = {
  runBenchmark: runBenchmark
};
