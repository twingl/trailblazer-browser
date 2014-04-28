Twingl.LoginRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'auth/main/login',
      outlet: 'main',
      controller: 'login'
