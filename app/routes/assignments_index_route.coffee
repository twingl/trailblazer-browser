# Authenticated route - hitting this without a valid session will transition
# the application to the login screen
Twingl.AssignmentsIndexRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  model: ->
    @store.findAll('assignment')
