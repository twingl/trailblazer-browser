Twingl.NavigationController = Ember.Controller.extend
  url: ''

  actions:
    navigateUrl: ->
      @controllerFor('webview').set('url', @url)

    navigateHistoryBack: ->
      console.log "navigation::navigateHistoryBack"

    navigateHistoryForward: ->
      console.log "navigation::navigateHistoryForward"
