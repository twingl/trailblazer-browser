( function() {
  Twingl.rootElement = "#test-harness";
  Twingl.setupForTesting();
  Twingl.injectTestHelpers();

  emq.globalize();
  setResolver(Ember.DefaultResolver.create({namespace: Twingl}));
}());
