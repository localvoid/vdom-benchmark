import 'dart:html' as html;
import 'dart:js';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom_benchmark/vdom.dart' as vdom;

final contestants = ['VDom[Dart]', 'React[js]', 'Mithril[js]', 'VirtualDom[js]'];

// upload to data to javascript
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

void main() {
  html.querySelector('#notification button').onClick.listen((_) {
    final model = g.generate();
    initJS(model);

    html.querySelector('#notification')..style.display = 'none';
    html.querySelector('#benchmark')..style.display = 'block';

    final vdomRunButton = html.querySelector('#runVDomDart');
    final reactJsRunButton = html.querySelector('#runReactJs');
    final mithrilJsRunButton = html.querySelector('#runMithrilJs');
    final virtualDomJsRunButton = html.querySelector('#runVirtualDomJs');

    final container = html.querySelector('#data');
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
        row.addCell()..append(new html.Element.tag('code')..text = name);
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
          results.add(fn(a, b, container).report());
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
      runBenchmark(0, 'VDom', (a, b, c) => new vdom.Benchmark(a, b, c));
    });

    reactJsRunButton.onClick.listen((_) {
      runJsBenchmark(1, 'React');
    });

    mithrilJsRunButton.onClick.listen((_) {
      runJsBenchmark(2, 'Mithril');
    });

    virtualDomJsRunButton.onClick.listen((_) {
      runJsBenchmark(3, 'VirtualDom');
    });
  });
}
