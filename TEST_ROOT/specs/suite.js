(function() {
  module("Integration: Login process", {
    setup: function() {
      Ember.$.mockjax.responseTime = 0;
      Ember.$.mockjax({
        url: "" + window.ENV['spec_api_host'] + "/" + window.ENV['api_namespace'] + "/assignments",
        responseText: {
          assignments: [
            {
              id: 1,
              title: "An Assignment",
              description: "A description",
              started_at: "2014-07-24T05:05:20.181Z",
              completed_at: void 0,
              current_node_id: 1,
              user_id: 1
            }, {
              id: 2,
              title: "An Assignment",
              description: "A description",
              started_at: void 0,
              completed_at: void 0,
              current_node_id: void 0,
              user_id: 1
            }
          ]
        }
      });
      Ember.$.mockjax({
        url: "" + window.ENV['spec_api_host'] + "/" + window.ENV['api_namespace'] + "/assignments/1/nodes",
        responseText: {
          nodes: [
            {
              id: 1,
              user_id: 1,
              arrived_at: "2014-07-25T02:44:00.989Z",
              departed_at: void 0,
              created_at: "2014-07-25T02:44:00.989Z",
              updated_at: "2014-07-25T02:44:00.989Z",
              idle: false,
              parent_id: void 0,
              title: "Google",
              url: "https://www.google.co.nz/?gfe_rd=cr&ei=D5TQU-roBaWN8QfD5IG4Bw&gws_rd=ssl"
            }
          ]
        }
      });
      Ember.$.mockjax({
        url: "" + window.ENV['spec_api_host'] + "/" + window.ENV['api_namespace'] + "/assignments/2/nodes",
        responseText: {
          nodes: []
        }
      });
      return authenticateSession();
    },
    teardown: function() {
      Ember.$.mockjaxClear();
      return Twingl.reset();
    }
  });

  test('the assignments route shows a list of assignments', function() {
    expect(2);
    return visit('assignments').then(function() {
      equal(currentRouteName(), 'assignments', "'assignments' is the current route");
      return equal(find("#tb-assignments li.assignment").length, 2, "Two assignments are visible");
    });
  });

  test('choosing a previous assignment transitions to the tree view', function() {
    expect(1);
    visit('assignments').then(function() {
      return click("li.assignment:first");
    });
    return andThen(function() {
      return equal(currentRouteName(), 'browser', "'browser' is the current route");
    });
  });

  test('choosing a new assignment transitions to the webview', function() {
    expect(1);
    visit('assignments').then(function() {
      return click("li.assignment:last");
    });
    return andThen(function() {
      return equal(currentRouteName(), 'browser', "'browser' is the current route");
    });
  });

}).call(this);

(function() {
  module("Integration: Login process", {
    setup: function() {
      return $.mockjax({
        url: "" + window.ENV['spec_api_host'] + "/" + window.ENV['api_namespace'] + "/assignments",
        responseText: {
          "assignments": []
        }
      });
    },
    teardown: function() {
      $.mockjaxClear();
      return Twingl.reset();
    }
  });

  test('successful login transitions to the assignments index', function() {
    expect(1);
    window.ChromeAuth.authenticate = function(resolve, reject) {
      return resolve();
    };
    visit('login');
    click('#tb-login button');
    return andThen(function() {
      return equal(currentRouteName(), 'assignments');
    });
  });

  test('failed login remains on the login page', function() {
    expect(1);
    window.ChromeAuth.authenticate = function(resolve, reject) {
      return reject();
    };
    visit('login');
    click('#tb-login button');
    return andThen(function() {
      return equal(currentRouteName(), 'login');
    });
  });

}).call(this);
