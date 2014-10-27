import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom_benchmark/vdom.dart' as vdom;
import 'package:charted/charted.dart';

const contestants = const ['VDom', 'React', 'Mithril', 'VirtualDom'];
const benchmarkDataSelector = '#benchmark-data';

class ResultsTable {
  List<List<Result>> data;

  ResultsTable(g.Model model) : data = new List(model.tests.length) {
    reset();
  }

  void reset() {
    for (var i = 0; i < data.length; i++) {
      data[i] = new List(contestants.length);
    }
  }
}

class Application {
  String state = 'initial';
  g.Model model;
  ResultsTable results;

  Application() {
    model = g.generate();
    results = new ResultsTable(model);
  }

  void setState(String newState) {
    html.querySelector('#state-$state').style.display = 'none';
    html.querySelector('#state-$newState').style.display = '';
    state = newState;
  }

  void initJS() {
    final groups = model.groups;
    for (final g in groups) {
      final a = new js.JsObject.jsify(g.a.map((i) => i.toJson()).toList());
      final bs = new js.JsObject.jsify(g.bs.map((k) => k.map((i) => i.toJson()).toList()).toList());
      final names = new js.JsObject.jsify(g.names);
      js.context['VDomBenchmark'].callMethod('pushGroup', [a, bs, names]);
    }

    js.context['VDomBenchmark'].callMethod('init', [benchmarkDataSelector]);
  }

  void renderResultsTable() {
    final resultsHead = html.querySelector('#results-table > thead');
    final resultsBody = html.querySelector('#results-table > tbody');

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
          row.addCell()..classes.add('result');
        }
        resultsBody.append(row);
      }
    }
  }

  void toggleButtons(bool v) {
    html.querySelector('#running').style.display = v ? 'none': '';
  }

  void updateResult(String name, int testNum, Result result) {
    final pos = contestants.indexOf(name);
    results.data[testNum][pos] = result;
    updateResultsTableRow(testNum);
  }

  void updateResultsTableRow(int rowNum) {
    final dataRow = results.data[rowNum];
    final ext = new Extent.items(dataRow.where((i) => i != null).map((i) => i.fullTime));
    final scale = new LinearScale([ext.min, ext.max]);

    final row = new SelectionScope.selector('#results-table tbody tr:nth-child(${rowNum + 1})');
    final cell = row.selectAll('.result').data(dataRow);
    cell.styleWithCallback('background', (d, i, e) => d == null ? '' : 'rgba(220, 100, 100, ${scale.apply(d.fullTime) * 0.5})');

    final r = cell.selectAll('div').dataWithCallback((d, i, e) => d == null ? [] : [d.renderTime, d.updateTime]);
    r.textWithCallback((d, i, e) => d.toStringAsFixed(1));
    r.enter.append('div').textWithCallback((d, i, e) => d.toStringAsFixed(1));
    r.exit.remove();
  }
}

void main() {
  html.querySelector('#state-initial button').onClick.listen((_) {
    final app = new Application();
    app.setState('generating-data');

    new Future.delayed(new Duration()).then((_) {
      app.initJS();
      app.setState('ready');
      app.renderResultsTable();

      final benchmarkDataContainer = html.querySelector(benchmarkDataSelector);

      runBenchmark(name, fn) {
        app.toggleButtons(false);

        return new Future.delayed(new Duration()).then((_) {
          var i = 0;
          return Future.forEach(app.model.tests, (test) {
            final result = fn(test.a, test.b, benchmarkDataContainer);
            app.updateResult(name, i, result);
            i++;
            return new Future.delayed(new Duration());
          });
        }).then((_) {
          app.toggleButtons(true);
        });
      }

      runJsBenchmark(name) {
        app.toggleButtons(false);

        return new Future.delayed(new Duration()).then((_) {
          var i = 0;
          return Future.forEach(app.model.tests, (test) {
            final result = js.context['benchmarks'].callMethod(name, [i]);
            app.updateResult(name, i, new Result(result['renderTime'], result['updateTime']));
            i++;
            return new Future.delayed(new Duration());
          });
        }).then((_) {
          app.toggleButtons(true);
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
