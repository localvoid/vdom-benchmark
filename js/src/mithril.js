var m = require('mithril');

function mithrilBuildTree(nodes) {
  var children = [];
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i];
    if (n.container === true) {
      children.push({tag: 'div', attrs: {key: n.key}, children: mithrilBuildTree(n.children)});
    } else {
      children.push({tag: 'span', attrs: {key: n.key}, children: n.key.toString()});
    }
  }
  return children;
}

function Benchmark(a, b, container) {
  this._a = a;
  this._b = b;
  this._container = container;

  this._module = null;
}

Benchmark.prototype.setUp = function() {
};

Benchmark.prototype.tearDown = function() {
  m.render(this._container, '', true);
};

Benchmark.prototype.render = function() {
  m.render(this._container, {tag: 'div', attrs: {key: 0}, children: mithrilBuildTree(this._a)});
};

Benchmark.prototype.update = function() {
  m.render(this._container, {tag: 'div', attrs: {key: 0}, children: mithrilBuildTree(this._b)});
};

module.exports = Benchmark;
