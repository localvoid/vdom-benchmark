global.VDomBenchmark = require('./src/init');

global.benchmarks = {
  React: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/react/components'), i);
  },
  Bobril: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/bobril/components'), i);
  }/*,
  Mithril: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/mithril/components'), i);
  },
  VirtualDom: function(i) {
    return VDomBenchmark.runBenchmark(require('./src/virtual-dom/components'), i);
  }*/
};
