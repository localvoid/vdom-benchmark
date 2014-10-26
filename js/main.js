global.VDomBenchmark = require('./src/init');

global.benchmarks = {
  React: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/react'), i);
  },
  Mithril: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/mithril'), i);
  },
  VirtualDom: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/virtual-dom'), i);
  }
};
