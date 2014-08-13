Twingl.AssignmentsIndexRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  model: ->
    console.log "route hit"
    @store.findAll('assignment')
