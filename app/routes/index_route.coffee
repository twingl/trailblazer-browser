Twingl.IndexRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'browser/main',
      outlet: 'main'
      controller: 'webview'

    @render 'navigation/browser',
      outlet: 'navigation'
      controller: 'navigation'

    @render 'alt/tree',
      outlet: 'alt'
      controller: 'tree'
