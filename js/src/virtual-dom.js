var VNode = require('vtree/vnode');
var VText = require('vtree/vtext');
var vDiff = require('virtual-dom/diff');
var vPatch = require('virtual-dom/patch');
var vCreateElement = require('vdom/create-element');

function virtualDomBuildTree(nodes) {
  var children = [];
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i];
    if (n.container === true) {
      children.push(new VNode('div', null, virtualDomBuildTree(n.children), n.key));
    } else {
      children.push(new VNode('span', null, [new VText(n.key.toString())], n.key));
    }
  }
  return children;
}

function Benchmark(a, b, container) {
  this._a = a;
  this._b = b;
  this._container = container;

  this._vRoot = null;
  this._root = null;
}

Benchmark.prototype.setUp = function() {
};

Benchmark.prototype.tearDown = function() {
  this._root.remove();
};

Benchmark.prototype.render = function() {
  this._vRoot = new VNode('div', null, virtualDomBuildTree(this._a), 0);
  this._root = vCreateElement(this._vRoot);
  this._container.appendChild(this._root);
};

Benchmark.prototype.update = function() {
  var newVroot = new VNode('div', null, virtualDomBuildTree(this._b), 0);
  var patches = vDiff(this._vRoot, newVroot);
  this._root = vPatch(this._root, patches);
};

module.exports = Benchmark;
