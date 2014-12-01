library vdom_benchmark.vdom;

import 'dart:html' as html;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom/vdom.dart' as v;

List<v.Node> vdomBuildTree(List<g.Node> nodes) {
  final children = [];
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.children != null) {
      children.add(new v.Element(n.key, 'div')(vdomBuildTree(n.children)));
    } else {
      children.add(new v.Element(n.key, 'span')([new v.Text(0, n.key.toString())]));
    }
  }
  return children;
}

class Benchmark extends BenchmarkBase {
  List<g.Node> a;
  List<g.Node> b;
  html.Element _container;

  v.Element _vRoot;

  Benchmark(this.a, this.b, this._container) : super('VDom');

  void render() {
    _vRoot = new v.Element(0, 'div')(vdomBuildTree(a));
    v.inject(_vRoot, _container, const v.Context(false));
  }

  void update() {
    final newVroot = new v.Element(0, 'div')(vdomBuildTree(b));
    _vRoot.update(newVroot, const v.Context(false));
  }

  void setup() {
  }

  void teardown() {
    _vRoot.ref.remove();
  }
}