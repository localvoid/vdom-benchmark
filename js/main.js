var VDomBenchmark = require('./src/init');

global.benchmarks = {
  React: function(a, b, c) {
    return VDomBenchmark.runBenchmark(require('./src/react'), a, b, c);
  },
  Mithril: function(a, b, c) {
    return VDomBenchmark.runBenchmark(require('./src/mithril'), a, b, c);
  },
  VirtualDom: function(a, b, c) {
    return VDomBenchmark.runBenchmark(require('./src/virtual-dom'), a, b, c);
  }
};
