import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:vdom_benchmark/benchmark.dart';
import 'package:vdom_benchmark/generator.dart' as g;
import 'package:vdom_benchmark/vdom.dart' as vdom;
import 'package:vdom_benchmark/app.dart';

const contestants = const ['VDom', 'React', 'Mithril', 'VirtualDom', 'Bobril', 'VSync'];

g.Model generateTests() {
  final groups = [];
  var r;

  r = [5000];
  groups.add(new g.Group(
      g.generateTree(r, [g.skip]),
      g.transformers.map((t) => g.generateTree(r, [t])).toList(),
      g.transformerNames.map((n) => '$r [$n]').toList()
      ));

  r = [100, 50];
  groups.add(new g.Group(
      g.generateTree(r, [g.skip, g.skip]),
      g.transformers.map((t) => g.generateTree(r, [t, g.skip])).toList(),
      g.transformerNames.map((n) => '$r [$n, skip]').toList()
      ));

  r = [1000, 5];
  groups.add(new g.Group(
      g.generateTree(r, [g.skip, g.skip]),
      g.transformers.map((t) => g.generateTree(r, [t, g.skip])).toList(),
      g.transformerNames.map((n) => '$r [$n, skip]').toList()
      ));

  r = [100, 50];
  groups.add(new g.Group(
      g.generateTree(r, [g.skip, g.skip]),
      g.transformers.map((t) => g.generateTree(r, [g.skip, t])).toList(),
      g.transformerNames.map((n) => '$r [skip, $n]').toList()
      ));

  r = [1000, 5];
  groups.add(new g.Group(
      g.generateTree(r, [g.skip, g.skip]),
      g.transformers.map((t) => g.generateTree(r, [g.skip, t])).toList(),
      g.transformerNames.map((n) => '$r [skip, $n]').toList()
      ));

  return new g.Model(groups);
}

void main() {
  html.querySelector('#state-initial button').onClick.listen((_) {
    final app = new Application(contestants, generateTests());
    app.setState('generating-data');

    new Future.delayed(new Duration()).then((_) {
      app.initJS();
      app.setState('ready');
      app.renderResultsTable();
      app.renderResultsCharts();

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
          app.updateResultsCharts();
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
          app.updateResultsCharts();
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

      html.querySelector('#runBobrilJs').onClick.listen((_) {
        runJsBenchmark('Bobril');
      });
    });
  });
}
