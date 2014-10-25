global.VDomBenchmark = require('./src/init');

global.benchmarks = {
  React: function() {
    return VDomBenchmark.runBenchmark(require('./src/react'));
  },
  Mithril: function() {
    return VDomBenchmark.runBenchmark(require('./src/mithril'));
  },
  VirtualDom: function() {
    return VDomBenchmark.runBenchmark(require('./src/virtual-dom'));
  }
};
