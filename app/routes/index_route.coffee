Twingl.IndexRoute = Ember.Route.extend
  # Transition to the assignments route which will trigger the login template
  # if there is no valid authentication, otherwise rendering the assignments
  # index
  beforeModel: ->
    @transitionTo 'assignments'
