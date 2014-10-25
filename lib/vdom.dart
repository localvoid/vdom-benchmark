library vdom_benchmark.vdom;

import 'dart:html' as html;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom/vdom.dart' as v;

List<v.Node> vdomBuildTree(List<g.Node> nodes) {
  final children = [];
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.container) {
      children.add(new v.Element(n.key, 'div', vdomBuildTree(n.children)));
    } else {
      children.add(new v.Element(n.key, 'span', [new v.Text(0, n.key.toString())]));
    }
  }
  return children;
}

class Benchmark extends BenchmarkBase {
  List<g.Node> a;
  List<g.Node> b;
  html.Element _container;

  v.Element _vRoot;
  html.Element _root;

  Benchmark(this.a, this.b, this._container);

  void render() {
    _vRoot = new v.Element(0, 'div', vdomBuildTree(a));
    _root = _vRoot.render();
    _container.append(_root);
  }

  void update() {
    final vNewRoot = new v.Element(0, 'div', vdomBuildTree(b));
    final patch = _vRoot.diff(vNewRoot);
    if (patch != null) {
      patch.apply(_root);
    }
  }

  void setup() {
  }

  void teardown() {
    _root.remove();
  }
}