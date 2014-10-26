import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom_benchmark/vdom.dart' as vdom;

final contestants = ['VDom', 'React', 'Mithril', 'VirtualDom'];

void main() {
  html.querySelector('#notification button').onClick.listen((_) {
    html.querySelector('#notification')..style.display = 'none';
    html.querySelector('#generating-data')..style.display = 'block';

    new Future.delayed(new Duration()).then((_) {
      final model = g.generate();

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

      jsBenchmark(name) {
        return (a, b, c) {
          final a2 = new js.JsObject.jsify(a.map((i) => i.toJson()).toList());
          final b2 = new js.JsObject.jsify(b.map((i) => i.toJson()).toList());
          final r = js.context['benchmarks'].callMethod(name, [a2, b2, c.id]);
          return new Result(r['renderTime'], r['updateTime']);
        };
      }

      html.querySelector('#runVDomDart').onClick.listen((_) {
        runBenchmark('VDom', (a, b, c) => new vdom.Benchmark(a, b, c).report());
      });

      html.querySelector('#runReactJs').onClick.listen((_) {
        runBenchmark('React', jsBenchmark('React'));
      });

      html.querySelector('#runMithrilJs').onClick.listen((_) {
        runBenchmark('Mithril', jsBenchmark('Mithril'));
      });

      html.querySelector('#runVirtualDomJs').onClick.listen((_) {
        runBenchmark('VirtualDom', jsBenchmark('VirtualDom'));
      });

    });
  });
}
