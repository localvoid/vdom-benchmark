import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom_benchmark/vdom.dart' as vdom;

final contestants = ['VDom', 'React', 'Mithril', 'VirtualDom'];

void initJS(g.Model model) {
  final groups = model.groups;
  for (final g in groups) {
    final a = new js.JsObject.jsify(g.a.map((i) => i.toJson()).toList());
    final bs = new js.JsObject.jsify(g.bs.map((k) => k.map((i) => i.toJson()).toList()).toList());
    final names = new js.JsObject.jsify(g.names);
    js.context['VDomBenchmark'].callMethod('pushGroup', [a, bs, names]);
  }

  js.context['VDomBenchmark'].callMethod('init');
}

void main() {
  html.querySelector('#notification button').onClick.listen((_) {
    html.querySelector('#notification')..style.display = 'none';
    html.querySelector('#generating-data')..style.display = 'block';

    new Future.delayed(new Duration()).then((_) {
      final model = g.generate();
      initJS(model);

      html.querySelector('#generating-data')..style.display = 'none';
      html.querySelector('#benchmark')..style.display = 'block';

      final container = html.querySelector('#data');
      final resultsHead = html.querySelector('#results > thead');
      final resultsBody = html.querySelector('#results > tbody');
      final runningOverlay = html.querySelector('#running');

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

      setStateRunning(v) {
        if (v) {
          runningOverlay.style.display = 'block';
        } else {
          runningOverlay.style.display = 'none';
        }
      }

      updateResults(name, testNum, result) {
        final pos = contestants.indexOf(name);
        final cell = resultsBody.childNodes[testNum].childNodes[pos + 1];
        cell.children.clear();
        cell
        ..append(new html.DivElement()..text = result.renderTime.toStringAsFixed(3))
        ..append(new html.DivElement()..text = result.updateTime.toStringAsFixed(3));
      }

      runBenchmark(name, fn) {
        setStateRunning(true);

        return new Future.delayed(new Duration()).then((_) {
          var i = 0;
          return Future.forEach(model.tests, (test) {
            final result = fn(test.a, test.b, container);
            updateResults(name, i, result);
            i++;
            return new Future.delayed(new Duration());
          });
        }).then((_) {
          setStateRunning(false);
        });
      }

      runJsBenchmark(name) {
        setStateRunning(true);

        return new Future.delayed(new Duration()).then((_) {
          var i = 0;
          return Future.forEach(model.tests, (test) {
            final result = js.context['benchmarks'].callMethod(name, [i]);
            updateResults(name, i, new Result(result['renderTime'], result['updateTime']));
            i++;
            return new Future.delayed(new Duration());
          });
        }).then((_) {
          setStateRunning(false);
        });
      }

      html.querySelector('#runVDomDart').onClick.listen((_) {
        runBenchmark('VDom', (a, b, c) => new vdom.Benchmark(a, b, c).report());
      });

      html.querySelector('#runReactJs').onClick.listen((_) {
        runJsBenchmark('React');
      });

      html.querySelector('#runMithrilJs').onClick.listen((_) {
        runJsBenchmark('Mithril');
      });

      html.querySelector('#runVirtualDomJs').onClick.listen((_) {
        runJsBenchmark('VirtualDom');
      });

    });
  });
}
