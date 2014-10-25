library vdom_benchmark.benchmark;

import 'dart:html' as html;

class Result {
  double renderTime = 0.0;
  double updateTime = 0.0;

  void avg(int n) {
    renderTime /= n;
    updateTime /= n;
  }
}

abstract class BenchmarkBase {
  void setup();
  void teardown();

  void render();
  void update();

  Result report() {
    final result = new Result();
    // warmup
    setup();
    render();
    update();
    teardown();

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