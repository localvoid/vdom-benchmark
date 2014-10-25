import 'dart:html' as html;
import 'dart:js';
import 'package:vdom/vdom.dart' as v;
import 'package:vsync/vsync.dart' as vs;
import 'package:vdom_benchmark/generator.dart' as g;

class Result {
  double renderTime = 0.0;
  double updateTime = 0.0;

  void avg(int n) {
    renderTime /= n;
    updateTime /= n;
  }
}

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

List<vs.Node> vsyncBuildTree(List<g.Node> nodes) {
  final children = [];
  for (final n in nodes) {
    if (n.container) {
      children.add(new vs.Element(n.key, 'div', vsyncBuildTree(n.children)));
    } else {
      children.add(new vs.Element(n.key, 'span', [new vs.Text(0, n.key.toString())]));
    }
  }
  return children;
}

abstract class Benchmark {
  String name;

  Benchmark(this.name);

  void setup();
  void teardown();

  void render();
  void update();

  Result report() {
    final result = new Result();
    for (var i = 0; i < 3; i++) {
      setup();

      var t0 = html.window.performance.now();
      render();
      result.renderTime += (html.window.performance.now() - t0) * 1000;

      t0 = html.window.performance.now();
      update();
      result.updateTime += (html.window.performance.now() - t0) * 1000;

      teardown();
    }
    return result..avg(3);
  }
}

class VDomBenchmark extends Benchmark {
  List<g.Node> a;
  List<g.Node> b;
  html.Element _container;

  v.Element _vRoot;
  html.Element _root;

  VDomBenchmark(this.a, this.b, this._container) : super('VDom');

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

class VSyncBenchmark extends Benchmark {
  List<g.Node> a;
  List<g.Node> b;
  html.Element _container;

  vs.Element _vRoot;
  html.Element _root;

  VSyncBenchmark(this.a, this.b, this._container) : super('VSync');

  void render() {
    _vRoot = new vs.Element(0, 'div', vsyncBuildTree(a));
    _root = _vRoot.render();
    _container.append(_root);
  }

  void update() {
    final vNewRoot = new vs.Element(0, 'div', vsyncBuildTree(b));
    _vRoot.sync(vNewRoot, _root);
  }

  void setup() {
  }

  void teardown() {
    _container.children.clear();
  }
}

void initJS(g.Model model) {
  final groups = model.groups;
  for (final g in groups) {
    final a = new JsObject.jsify(g.a.map((i) => i.toJson()).toList());
    final bs = new JsObject.jsify(g.bs.map((k) => k.map((i) => i.toJson()).toList()).toList());
    final names = new JsObject.jsify(g.names);
    context['VDomBenchmark'].callMethod('pushGroup', [a, bs, names]);
  }

  context['VDomBenchmark'].callMethod('init');
}

final contestants = ['VDom[Dart]', 'VSync[Dart]', 'React[js]', 'Mithril[js]', 'VirtualDom[js]'];

void main() {
  final model = g.generate();
  initJS(model);

  final vdomRunButton = html.querySelector('#runVDomDart');
  final vsyncRunButton = html.querySelector('#runVSyncDart');
  final reactJsRunButton = html.querySelector('#runReactJs');
  final mithrilJsRunButton = html.querySelector('#runMithrilJs');
  final virtualDomJsRunButton = html.querySelector('#runVirtualDomJs');

  final container = html.document.getElementById('data');
  final resultsHead = html.querySelector('#results > thead');
  final resultsBody = html.querySelector('#results > tbody');

  // print results table
  final contestantsRow = new html.TableRowElement();
  contestantsRow.append(new html.Element.th());
  for (final c in contestants) {
    contestantsRow.append(new html.Element.th()..text = c);
  }
  resultsHead.append(contestantsRow);

  for (final g in model.groups) {
    for (var i = 0; i < g.bs.length; i++) {
      final b = g.bs[i];
      final name = g.names[i];
      final row = new html.TableRowElement();
      row.addCell()..text = name;
      for (var i = 0; i < contestants.length; i++) {
        row.addCell();
      }
      resultsBody.append(row);
    }
  }

  runBenchmark(pos, name, fn) {
    var i = 0;
    final results = [];
    for (final g in model.groups) {
      final a = g.a;
      final bs = g.bs;
      for (final b in bs) {
        results.add(fn(a, b).report());
      }
    }

    for (final result in results) {
      final cell = resultsBody.childNodes[i++].childNodes[pos + 1];
      cell.children.clear();
      cell
      ..append(new html.DivElement()..text = result.renderTime.toStringAsFixed(3))
      ..append(new html.DivElement()..text = result.updateTime.toStringAsFixed(3));
    }
  }

  runJsBenchmark(pos, name) {
    var i = 0;
    final results = context['benchmarks'].callMethod(name);

    for (final result in results) {
      final cell = resultsBody.childNodes[i++].childNodes[pos + 1];
      cell.children.clear();
      cell
      ..append(new html.DivElement()..text = result['renderTime'].toStringAsFixed(3))
      ..append(new html.DivElement()..text = result['updateTime'].toStringAsFixed(3));
    }
  }

  vdomRunButton.onClick.listen((_) {
    runBenchmark(0, 'VDom', (a, b) => new VDomBenchmark(a, b, container));
  });

  vsyncRunButton.onClick.listen((_) {
    runBenchmark(1, 'VSync', (a, b) => new VSyncBenchmark(a, b, container));
  });

  reactJsRunButton.onClick.listen((_) {
    runJsBenchmark(2, 'React');
  });

  mithrilJsRunButton.onClick.listen((_) {
    runJsBenchmark(3, 'Mithril');
  });

  virtualDomJsRunButton.onClick.listen((_) {
    runJsBenchmark(4, 'VirtualDom');
  });
}
