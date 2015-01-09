library vdom_benchmark.liquid;

import 'dart:html' as html;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:liquid/vdom.dart' as v;
import 'package:liquid/liquid.dart';

final nodeComponent = v.componentFactory(NodeComponent);
class NodeComponent extends Component<html.DivElement> {
  @property(required: true) g.Node node;

  v.VRoot build() {
    final result = [];
    final children = node.children;
    if (children != null) {
      for (var i = 0; i < children.length; i++) {
        final c = children[i];
        if (c.children == null) {
          result.add(leafComponent(key: c.key, node: c));
        } else {
          result.add(nodeComponent(key: c.key, node: c));
        }
      }
    }
    return v.root()(result);
  }

  bool shouldComponentUpdate() => node.dirty;
}

final leafComponent = v.componentFactory(LeafComponent);
class LeafComponent extends Component<html.SpanElement> {
  @property(required: true) g.Node node;

  void create() { element = new html.SpanElement(); }

  v.VRoot build() => v.root()(node.key.toString());

  bool shouldComponentUpdate() => node.dirty;
}


class App extends Component {
  List<g.Node> nodes;

  set node(List<g.Node> newNodes) {
    nodes = newNodes;
    dirty = true;
    internalUpdate();
  }

  v.VRoot build() {
    return v.root()([nodeComponent(key: 0, node: new g.Node(0, true, nodes))]);
  }
}


class Benchmark extends BenchmarkBase {
  List<g.Node> a;
  List<g.Node> b;
  html.Element _container;

  App _app;

  Benchmark(this.a, this.b, this._container) : super('VComponent');

  void render() {
    _app = new App()..nodes = a;
    _app.create();
    _container.append(_app.element);
    _app.attach();
    _app.internalUpdate();
  }

  void update() {
    _app.node = b;
  }

  void setup() {
  }

  void teardown() {
    _app.element.remove();
  }
}
