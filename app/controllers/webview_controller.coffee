Twingl.WebviewController = Ember.Controller.extend
  ###
  # This Controller is responsible for actioning navigation events and catching
  # the events emitted by the <webview>, filtering, and bubbling on appropriate
  # events to NavigationController so that it can manage the state effectively.
  ###

  needs: ['navigation']
  navigation: Ember.computed.alias "controllers.navigation"

  url: ''

  navigate:  (url) -> @set 'url', url

  navigateForward: -> $('webview')[0].forward()
  navigateBack:    -> $('webview')[0].back()
  reload:          -> $('webview')[0].reload()

  actions:
    loadStart: (e) -> @get('navigation').set 'loading', true
    loadStop:  (e) -> @get('navigation').set 'loading', false

    loadRedirect: (e) ->
      if e.originalEvent.isTopLevel
        @get('navigation').send 'loadRedirect', e

    loadCommit: (e) ->
      if e.originalEvent.isTopLevel
        $('webview')[0].executeScript code: "document.title", (r) =>
          document.title = r[0]
          e.originalEvent.title = r[0]
          @get('navigation').send 'loadCommit', e

    newWindow: (e) ->
      @get('navigation').send 'newWindow', e
