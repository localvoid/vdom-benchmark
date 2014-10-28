global.VDomBenchmark = require('./src/init');

global.benchmarks = {
  React: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/react/dom'), i);
  },
  Mithril: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/mithril/dom'), i);
  },
  VirtualDom: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/virtual-dom/dom'), i);
  }
};
