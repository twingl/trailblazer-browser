module "Integration: Login process",
  setup: ->
    $.mockjax
      url: "#{window.ENV['spec_api_host']}/#{window.ENV['api_namespace']}/assignments"
      responseText: { "assignments": [] }

  teardown: ->
    $.mockjaxClear()
    Twingl.reset()


test 'successful login transitions to the assignments index', ->
  expect(1)
  window.ChromeAuth.authenticate = (resolve, reject) -> resolve()

  visit('login')
  click('#tb-login button')

  andThen ->
    equal(currentRouteName(), 'assignments')


test 'failed login remains on the login page', ->
  expect(1)
  window.ChromeAuth.authenticate = (resolve, reject) -> reject()

  visit('login')
  click('#tb-login button')

  andThen ->
    equal(currentRouteName(), 'login')
