var m = require('mithril');

var emptyModule = {};
emptyModule.controller = function() {};
emptyModule.view = function() {};

function mithrilBuildTree(nodes) {
  var children = [];
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i];
    if (n.container === true) {
      children.push(m('div', {key: n.key}, mithrilBuildTree(n.children)));
    } else {
      children.push(m('span', {key: n.key}, n.key.toString()));
    }
  }
  return children;
}

function MithrilModule(nodes) {
  this.nodes = nodes;
}

MithrilModule.prototype.controller = function() {};
MithrilModule.prototype.view = function() {
  return [m('div', {}, mithrilBuildTree(this.nodes))];
};

function Benchmark(a, b, container) {
  this._a = a;
  this._b = b;
  this._container = container;

  this._module = null;
}

Benchmark.prototype.setUp = function() {
};

Benchmark.prototype.tearDown = function() {
  m.module(this._container, emptyModule);
  m.redraw(true);
};

Benchmark.prototype.render = function() {
  this._module = new MithrilModule(this._a);
  m.module(this._container, this._module);
  m.redraw(true);
};

Benchmark.prototype.update = function() {
  this._module.nodes = this._b;
  m.redraw(true);
};

module.exports = Benchmark;
