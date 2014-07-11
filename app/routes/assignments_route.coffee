Twingl.AssignmentsRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  model: ->
    @store.findAll('assignment')

  renderTemplate: ->
    @render 'assignments/index',
      outlet: 'main'
      controller: 'assignments'

    @render 'navigation/browser',
      outlet: 'navigation'
      controller: 'navigation'
