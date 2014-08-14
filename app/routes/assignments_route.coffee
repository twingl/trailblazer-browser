# Authenticated route - hitting this without a valid session will transition
# the application to the login screen
Twingl.AssignmentsRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  renderTemplate: ->
    # Invoke the default rendering behaviour (renders templates/assignments.hbs
    # into the application outlet according to Ember conventions)
    @_super()

    # Render the navigation widgets we need into the navigation outlet
    @render 'navigation/assignments', outlet: 'navigation'
