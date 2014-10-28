var React = require('react/lib/React');
var DOM = React.DOM;

function reactBuildTree(nodes) {
  var children = [];
  for (var i = 0; i < nodes.length; i++) {
    var n = nodes[i];
    if (n.children !== null) {
      children.push(DOM.div({key: n.key}, reactBuildTree(n.children)));
    } else {
      children.push(DOM.span({key: n.key}, n.key.toString()));
    }
  }
  return children;
}

function Benchmark(a, b, container) {
  this._a = a;
  this._b = b;
  this._container = container;
}

Benchmark.prototype.setUp = function() {};

Benchmark.prototype.tearDown = function() {
  React.unmountComponentAtNode(this._container);
};

Benchmark.prototype.render = function() {
  React.renderComponent(DOM.div(null, reactBuildTree(this._a)), this._container);
};

Benchmark.prototype.update = function() {
  React.renderComponent(DOM.div(null, reactBuildTree(this._b)), this._container);
};

module.exports = Benchmark;
