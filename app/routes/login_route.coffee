Twingl.LoginRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'main/auth/login',
      outlet: 'main'
      controller: 'login'
