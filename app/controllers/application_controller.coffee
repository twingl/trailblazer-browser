Twingl.ApplicationController = Ember.Controller.extend
  needs: ['tree', 'webview', 'navigation']

  actions:
    resetState: ->
      for c in @needs
        @get("controllers.#{c}").resetState()
      @transitionToRoute 'login'

    minimizeWindow: ->
      chrome.app.window.current().minimize()

    maximizeWindow: ->
      if chrome.app.window.current().isMaximized()
        chrome.app.window.current().restore()
      else
        chrome.app.window.current().maximize()

    closeWindow: ->
      chrome.app.window.current().close()
