function Group(a, bs, names) {
  this.a = a;
  this.bs = bs;
  this.names = names;
}

function Model() {
  this.groups = [];
}

Model.prototype.pushGroup = function(a, bs, names) {
  this.groups.push(new Group(a, bs, names));
};

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

var model = new Model();
var details = {
};

function pushGroup(a, bs, names) {
  var bs2 = [];
  bs.forEach(function(b) {
    bs2.push(convertToNative(b));
  });
  model.pushGroup(convertToNative(a), bs2, names);
}

function init() {
  details.containerElement = document.getElementById('data');
  console.log('js environment initialized');
}

function Result() {
  this.renderTime = 0;
  this.updateTime = 0;
}

Result.prototype.avg = function(n) {
  this.renderTime /= n;
  this.updateTime /= n;
};

function runBenchmark(benchmark) {
  var groups = VDomBenchmark.model.groups;
  var results = [];
  for (var k = 0; k < groups.length; k++) {
    var g = groups[k];
    var a = g.a;
    var bs = g.bs;
    for (var i = 0; i < bs.length; i++) {
      var b = bs[i];

      var benchmarkInstance = new benchmark(a, b, VDomBenchmark.details.containerElement);

      var r = new Result();
      for (var j = 0; j < 3; j++) {
        benchmarkInstance.setUp();

        var t0 = window.performance.now();
        benchmarkInstance.render();
        var t1 = window.performance.now();
        r.renderTime = (t1 - t0) * 1000;

        t0 = window.performance.now();
        benchmarkInstance.update();
        t1 = window.performance.now();
        r.updateTime = (t1 - t0) * 1000;

        benchmarkInstance.tearDown();
      }
      r.avg(3);
      results.push(r);
    }
  }

  return results;
}

module.exports = {
  init: init,
  pushGroup: pushGroup,
  model: model,
  details: details,
  runBenchmark: runBenchmark
};