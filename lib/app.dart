library vdom_benchmar.app;

import 'dart:html' as html;
import 'dart:js' as js;
import 'package:charted/charted.dart';
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;

const benchmarkDataSelector = '#benchmark-data';

class ResultsTable {
  List<List<Result>> data;

  ResultsTable(int m, int n) : data = new List(m) {
    for (var i = 0; i < data.length; i++) {
      data[i] = new List(n);
    }
  }
}

class Application {
  List contestants;
  String state = 'initial';
  g.Model model;
  ResultsTable results;

  Application(this.contestants, this.model) {
    results = new ResultsTable(model.tests.length, contestants.length);
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

  void renderResultsCharts() {
    final results = html.querySelector('#results-charts');

    for (final t in model.tests) {
      final panel = new html.DivElement()..classes.addAll(const ['panel', 'panel-default']);
      final head = new html.DivElement()..classes.add('panel-heading')..append(new html.Element.tag('code')..text = t.name);
      final body = new html.DivElement()..classes.add('panel-body');
      final table = new html.TableElement()..classes.add('results-chart');
      for (final c in contestants) {
        final row = table.addRow();
        row.addCell()..classes.add('name')..text = c;
        row.addCell()..classes.add('bars');
      }

      results.append(new html.DivElement()..classes.add('row')..append(panel..append(head)..append(body..append(table))));
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

  void updateResultsCharts() {
    final m = max(results.data.map((r) => max(r.where((i) => i != null).map((i) => i.fullTime))));
    final scale = new LinearScale([0, m], [0, 100]);

    final rows = new SelectionScope.selector('#results-charts').selectAll('.results-chart').data(results.data);

    final cells = rows.selectAll('.bars').dataWithCallback((d, i, e) => d);
    final bars = cells.selectAll('.bar').dataWithCallback((d, i, e) => d == null ? [] : [d.renderTime, d.updateTime])
    ..styleWithCallback('width', (d, i, e) => '${scale.apply(d)}%')
    ..attrWithCallback('title', (d, i, e) => d.toStringAsFixed(1));

    bars.enter.append('div')
    ..classed('bar')
    ..classedWithCallback('render-time', (d, i, e) => i == 0)
    ..classedWithCallback('update-time', (d, i, e) => i == 1)
    ..styleWithCallback('width', (d, i, e) => '${scale.apply(d)}%')
    ..attrWithCallback('title', (d, i, e) => d.toStringAsFixed(1));

    bars.exit.remove();
  }
}
