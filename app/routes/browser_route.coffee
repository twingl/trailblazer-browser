Twingl.BrowserRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  renderTemplate: ->
    @render 'main/webview',
      outlet: 'main'
      controller: 'webview'

    @render 'navigation/browser',
      outlet: 'navigation'
      controller: 'navigation'

    @render 'alt/tree',
      outlet: 'alt'
      controller: 'tree'

    @render 'windowNavigation/projects',
      outlet: 'windowNavigation'
      controller: 'application'
