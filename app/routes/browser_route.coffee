# Authenticated route - hitting this without a valid session will transition
# the application to the login screen
Twingl.BrowserRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  model: (params) ->
    # Retrieve the assignment from the store
    @store.find 'assignment', params.assignment_id

  renderTemplate: ->
    # Invoke the default rendering behaviour (renders templates/browser.hbs
    # into the application outlet according to Ember conventions)
    @_super()

    # Render the navigation widgets we need into the navigation outlet
    @render 'navigation/browser', outlet: 'navigation'
