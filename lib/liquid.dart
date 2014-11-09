library vdom_benchmark.liquid;

import 'dart:html' as html;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom/vdom.dart' as v;
import 'package:liquid/liquid.dart';

class NodeComponent extends VComponent {
  g.Node _node;

  NodeComponent(ComponentBase parent, this._node)
      : super('div', parent);

  v.Element build() {
    final result = [];
    final children = _node.children;
    if (children != null) {
      for (var i = 0; i < children.length; i++) {
        final c = children[i];
        if (c.children == null) {
          result.add(LeafComponent.virtual(c.key, c));
        } else {
          result.add(NodeComponent.virtual(c.key, c));
        }
      }
    }
    return new v.Element(0, 'div', result);
  }

  void updateProperties(g.Node node) {
    _node = node;
    if (_node.dirty) {
      isDirty = true;
      update();
    }
  }

  static VDomComponent virtual(Object key, g.Node node) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new NodeComponent(context, node);
      }
      component.updateProperties(node);
    });
  }

  String toString() => 'Node: [$_node]';
}

class LeafComponent extends VComponent {
  g.Node _node;

  LeafComponent(ComponentBase parent, this._node)
      : super('span', parent);

  void updateProperties(g.Node node) {
    _node = node;
    if (_node.dirty) {
      isDirty = true;
      update();
    }
  }

  static VDomComponent virtual(Object key, g.Node node) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new LeafComponent(context, node);
      }
      component.updateProperties(node);
    });
  }

  v.Element build() {
    return new v.Element(0, 'span',
        [new v.Text(0, _node.key.toString())]);
  }

  String toString() => 'Leaf: [${_node.key}]';
}

class App extends VComponent {
  List<g.Node> _nodes;

  set node(List<g.Node> newNodes) {
    _nodes = newNodes;
    isDirty = true;
    update();
  }

  App(ComponentBase parent, this._nodes) : super('div', parent);

  v.Element build() {
    return new v.Element(0, 'div',
        [NodeComponent.virtual(0, new g.Node(0, true, _nodes))]);
  }
}


class Benchmark extends BenchmarkBase {
  List<g.Node> a;
  List<g.Node> b;
  html.Element _container;

  RootComponent _root;

  App _app;
  html.Element _element;

  Benchmark(this.a, this.b, this._container) : super('VComponent');

  void render() {
    _app = new App(_root, a);
    _root.append(_app);
  }

  void update() {
    _app.node = b;
  }

  void setup() {
    _root = new RootComponent.mount(_container);
  }

  void teardown() {
    _container.children.clear();
  }
}