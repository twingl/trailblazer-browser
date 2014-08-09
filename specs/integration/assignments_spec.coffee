module "Integration: Login process",
  setup: ->
    Ember.$.mockjax.responseTime = 0

    Ember.$.mockjax
      url: "#{window.ENV['spec_api_host']}/#{window.ENV['api_namespace']}/assignments"
      responseText:
        assignments: [{
          id: 1
          title: "An Assignment"
          description: "A description"
          started_at: "2014-07-24T05:05:20.181Z"
          completed_at: undefined
          current_node_id: 1
          user_id: 1
        },
        {
          id: 2
          title: "An Assignment"
          description: "A description"
          started_at: undefined
          completed_at: undefined
          current_node_id: undefined
          user_id: 1
        }]

    Ember.$.mockjax
      url: "#{window.ENV['spec_api_host']}/#{window.ENV['api_namespace']}/assignments/1/nodes"
      responseText:
        nodes: [{
          id: 1
          user_id: 1
          arrived_at: "2014-07-25T02:44:00.989Z"
          departed_at: undefined
          created_at: "2014-07-25T02:44:00.989Z"
          updated_at: "2014-07-25T02:44:00.989Z"
          idle: false
          parent_id: undefined
          title: "Google"
          url: "https://www.google.co.nz/?gfe_rd=cr&ei=D5TQU-roBaWN8QfD5IG4Bw&gws_rd=ssl"
        }]

    Ember.$.mockjax
      url: "#{window.ENV['spec_api_host']}/#{window.ENV['api_namespace']}/assignments/2/nodes"
      responseText:
        nodes: []
    authenticateSession()

  teardown: ->
    Ember.$.mockjaxClear()
    Twingl.reset()


test 'the assignments route shows a list of assignments', ->
  expect(2)

  visit('assignments').then ->
    equal(currentRouteName(), 'assignments', "'assignments' is the current route")
    equal(find("#tb-assignments li.assignment").length, 2, "Two assignments are visible")

test 'choosing a previous assignment transitions to the tree view', ->
  expect(1)

  visit('assignments') .then -> click("li.assignment:first")

  andThen ->
    #FIXME this will change with the visual refresh
    #equal(find('#tb-pane-alt').is(':visible'), true, "The alt pane is visible")
    equal(currentRouteName(), 'browser', "'browser' is the current route")

test 'choosing a new assignment transitions to the webview', ->
  expect(1)

  visit('assignments') .then -> click("li.assignment:last")

  andThen ->
    #FIXME this will change with the visual refresh
    #equal(find('#tb-pane-main').is(':visible'), true, "The main pane is visible")
    #equal(find('#tb-pane-alt').is(':visible'), false, "The alt pane is hidden")
    equal(currentRouteName(), 'browser', "'browser' is the current route")
