Twingl.BrowserRoute = Ember.Route.extend SimpleAuth.AuthenticatedRouteMixin,
  model: (params) ->
    # Retrieve the assignment from the store
    @store.find 'assignment', params.assignment_id

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
