Twingl.LoadingRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'main/loading',
      outlet: 'main'
