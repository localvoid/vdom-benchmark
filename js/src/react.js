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

var ReactView = React.createClass({
  getInitialState: function() {
    return {nodes: this.props.nodes};
  },
  render: function() {
    return React.DOM.div({}, reactBuildTree(this.state.nodes));
  }
});

function Benchmark(a, b, container) {
  this._a = a;
  this._b = b;
  this._container = container;

  this._view = null;
}

Benchmark.prototype.setUp = function() {};

Benchmark.prototype.tearDown = function() {
  React.unmountComponentAtNode(this._container);
  ReactUpdates.flushBatchedUpdates();
};

Benchmark.prototype.render = function() {
  var v = new ReactView({nodes: this._a});
  this._view = React.renderComponent(v, this._container);
  ReactUpdates.flushBatchedUpdates();
};

Benchmark.prototype.update = function() {
  this._view.setState({nodes: this._b});
  ReactUpdates.flushBatchedUpdates();
};

module.exports = Benchmark;
