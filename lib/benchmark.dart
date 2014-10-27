library vdom_benchmark.benchmark;

import 'dart:html' as html;

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

    var renderTime = 0.0;
    var updateTime = 0.0;
    for (var i = 0; i < 3; i++) {
      setup();

      var t0 = html.window.performance.now();
      render();
      renderTime += (html.window.performance.now() - t0) * 1000;

      t0 = html.window.performance.now();
      update();
      updateTime += (html.window.performance.now() - t0) * 1000;

      teardown();
    }

    return new Result(renderTime / 3, updateTime / 3);
  }
}