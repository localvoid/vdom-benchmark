var ReactUpdates = require('react/lib/ReactUpdates');
var React = require('react/lib/React');

function reactBuildTree(nodes) {
  var children = [];
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i];
    if (n.container === true) {
      children.push(React.DOM.div({key: n.key}, reactBuildTree(n.children)));
    } else {
      children.push(React.DOM.span({key: n.key}, n.key.toString()));
    }
  }
  return children;
}

function Benchmark(a, b, container) {
  this._a = a;
  this._b = b;
  this._container = container;

  this._view = null;
}

Benchmark.prototype.setUp = function() {};

Benchmark.prototype.tearDown = function() {
  React.unmountComponentAtNode(this._container);
};

Benchmark.prototype.render = function() {
  React.renderComponent(React.DOM.div({key: 0}, reactBuildTree(this._a)), this._container);
};

Benchmark.prototype.update = function() {
  React.renderComponent(React.DOM.div({key: 0}, reactBuildTree(this._b)), this._container);
};

module.exports = Benchmark;
