Twingl.NavigationController = Ember.Controller.extend
  ###
  # This Controller is responsible for setting and clearing the necessary state
  # so we can mutate the tree correctly based on the events emitted by the
  # <webview>
  ###

  needs: ['webview']
  webview: Ember.computed.alias "controllers.webview"

  url: ''
  loading: false

  actions:
    navigateUrl:            -> @get('webview').navigate(@url)
    navigateHistoryBack:    -> @get('webview').navigateBack()
    navigateHistoryForward: -> @get('webview').navigateForward()
    navigateReload:         -> @get('webview').reload()

    jumpToUrl: (url) ->
      console.log "[STUB] jumpToUrl: #{url}"
