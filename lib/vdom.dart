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
      children.add(new v.Element('div', key: n.key)(vdomBuildTree(n.children)));
    } else {
      children.add(new v.Element('span', key: n.key)([new v.Text(n.key.toString(), key: n.key)]));
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
    _vRoot = new v.Element('div')(vdomBuildTree(a));
    _vRoot.create(const v.Context(true));
    _container.append(_vRoot.ref);
    _vRoot.attached();
    _vRoot.render(const v.Context(true));
  }

  void update() {
    final newVroot = new v.Element('div')(vdomBuildTree(b));
    _vRoot.update(newVroot, const v.Context(true));
  }

  void setup() {
  }

  void teardown() {
    _vRoot.ref.remove();
  }
}