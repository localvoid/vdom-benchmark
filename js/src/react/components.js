// Node {
//   int key;
//   bool dirty;
//   List<Node> children;
// }
//
// When Node doesn't have any children, it should be rendered
// as a LeafComponent, otherwise it should be rendered as a
// NodeComponent.

var React = require('react');
var Node = require('../init').Node;
var DOM = React.DOM;

var LeafComponent = React.createClass({
  shouldComponentUpdate: function(nextProps, nextState) {
    return nextProps.node.dirty === true;
  },

  render: function() {
    var key = this.props.node.key;
    return DOM.span({key: key}, key.toString());
  }
});

var NodeComponent = React.createClass({
  shouldComponentUpdate: function(nextProps, nextState) {
    return nextProps.node.dirty === true;
  },

  render: function() {
    var result = [];
    var node = this.props.node;
    var children = node.children;
    if (children !== null) {
      for (var i = 0; i < children.length; i++) {
        var c = children[i];
        if (c.children === null) {
          result.push(LeafComponent({key: c.key, node: c}));
        } else {
          result.push(NodeComponent({key: c.key, node: c}));
        }
      }
    }
    return DOM.div({key: node.key}, result);
  }
});

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
  React.renderComponent(NodeComponent({node: new Node(0, false, this._a)}), this._container);
};

Benchmark.prototype.update = function() {
  React.renderComponent(NodeComponent({node: new Node(0, true, this._b)}), this._container);
};

module.exports = Benchmark;