(function() {
  test("hello world", function() {
    return equal(true, true);
  });

}).call(this);

(function() {
  module("Integration: Login", {
    setup: function() {
      return chrome.identity.launchWebAuthFlow = function(args, cb) {
        return console.log(args, cb);
      };
    },
    teardown: function() {
      return Twingl.reset();
    }
  });

  test('do stuff', function() {
    visit('login');
    click('#tb-login button');
    authenticateSession();
    return andThen(function() {
      console.log("test");
      return equal(currentRouteName(), 'assignments');
    });
  });

}).call(this);
