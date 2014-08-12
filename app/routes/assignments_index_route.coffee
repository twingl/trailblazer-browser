Twingl.AssignmentsIndexRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  model: ->
    console.log "route hit"
    @store.findAll('assignment')

  renderTemplate: ->
    console.log "template hit"
    @render 'main/assignments/index',
      outlet: 'main'
      controller: 'assignments.index'

    @render 'navigation/assignments',
      outlet: 'navigation'
      controller: 'navigation'
