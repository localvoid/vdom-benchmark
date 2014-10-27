function Node(key, children, container) {
  this.key = key;
  this.children = children;
  this.container = container;
}

function Group(a, bs, names) {
  this.a = a;
  this.bs = bs;
  this.names = names;
}

function Test(a, b) {
  this.a = a;
  this.b = b;
}

function Model() {
  this.groups = [];
  this.tests = [];
}

Model.prototype.pushGroup = function(a, bs, names) {
  this.groups.push(new Group(a, bs, names));
};

Model.prototype.buildTests = function() {
  for (var i = 0; i < this.groups.length; i++) {
    var g = this.groups[i];
    for (var k = 0; k < g.bs.length; k++) {
      this.tests.push(new Test(g.a, g.bs[k]));
    }
  }
};

var model = new Model();
var containerElement;

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

function pushGroup(a, bs, names) {
  var bs2 = [];
  bs.forEach(function(b) {
    bs2.push(convertToNative(b));
  });
  model.pushGroup(convertToNative(a), bs2, names);
}

function init(benchmarkDataSelector) {
  model.buildTests();
  containerElement = document.querySelector(benchmarkDataSelector);
}

function Result() {
  this.renderTime = 0;
  this.updateTime = 0;
}

Result.prototype.avg = function(n) {
  this.renderTime /= n;
  this.updateTime /= n;
};

function runBenchmark(benchmark, i) {
  var test = model.tests[i];

  var benchmarkInstance = new benchmark(test.a, test.b, containerElement);

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
  pushGroup: pushGroup,
  init: init,
  runBenchmark: runBenchmark
};
