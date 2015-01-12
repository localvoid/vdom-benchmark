// performance.now() polyfill
// https://gist.github.com/paulirish/5438650
// prepare base perf object
if (typeof window.performance === 'undefined') {
  window.performance = {};
}

if (!window.performance.now){

  var nowOffset = Date.now();

  if (performance.timing && performance.timing.navigationStart){
    nowOffset = performance.timing.navigationStart
  }

  window.performance.now = function now(){
    return Date.now() - nowOffset;
  };
}


function Node(key, dirty, children) {
  this.key = key;
  this.dirty = dirty;
  this.children = children;
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
    result.push(new Node(n.key, n.dirty, convertToNative(n.children)));
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

function Result(renderTime, updateTime) {
  this.renderTime = renderTime;
  this.updateTime = updateTime;
}

function runBenchmark(benchmark, i) {
  var t0;
  var test = model.tests[i];

  var benchmarkInstance = new benchmark(test.a, test.b, containerElement);

  // warmup
  benchmarkInstance.setUp();
  benchmarkInstance.render();
  benchmarkInstance.update();
  benchmarkInstance.tearDown();

  var renderTime = Number.MAX_VALUE;
  var updateTime = Number.MAX_VALUE;

  for (var j = 0; j < 3; j++) {
    benchmarkInstance.setUp();

    t0 = window.performance.now();
    benchmarkInstance.render();
    renderTime = Math.min((window.performance.now() - t0), renderTime);

    t0 = window.performance.now();
    benchmarkInstance.update();
    updateTime = Math.min((window.performance.now() - t0), updateTime);

    benchmarkInstance.tearDown();
  }

  return new Result(renderTime * 1000, updateTime * 1000);
}

module.exports = {
  Node: Node,
  pushGroup: pushGroup,
  init: init,
  runBenchmark: runBenchmark
};
