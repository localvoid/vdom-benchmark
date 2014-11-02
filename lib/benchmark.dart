library vdom_benchmark.benchmark;

import 'dart:html' as html;
import 'dart:math' as math;

class Result {
  final double renderTime;
  final double updateTime;

  double get fullTime => renderTime + updateTime;

  const Result(this.renderTime, this.updateTime);
}

abstract class BenchmarkBase {
  final String name;

  BenchmarkBase(this.name);

  void setup();
  void teardown();

  void render();
  void update();

  Result report() {
    // warmup
    setup();
    render();
    update();
    teardown();

    var renderTime = 1 << 31;
    var updateTime = 1 << 31;
    for (var i = 0; i < 3; i++) {
      setup();

      var t0 = html.window.performance.now();
      render();
      renderTime = math.min((html.window.performance.now() - t0), renderTime);

      t0 = html.window.performance.now();
      update();
      updateTime = math.min((html.window.performance.now() - t0), updateTime);

      teardown();
    }

    return new Result(renderTime * 1000, updateTime * 1000);
  }
}