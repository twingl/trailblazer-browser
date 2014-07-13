Twingl.IndexRoute = Ember.Route.extend
  beforeModel: ->
    @transitionTo 'login'
