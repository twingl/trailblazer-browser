Twingl.ApplicationController = Ember.Controller.extend
  needs: ['tree', 'webview', 'navigation']
  assignment: undefined

  actions:

    # Navigate back to the assignments view
    showAssignments: ->
      @set 'assignment', undefined
      @transitionToRoute('assignments')

    resetState: ->
      for c in @needs
        @get("controllers.#{c}").resetState()
      @transitionToRoute 'login'

    minimizeWindow: ->
      chrome.app.window.current().minimize()

    maximizeWindow: ->
      console.log chrome.app.window.current().isMaximized()
      if chrome.app.window.current().isMaximized()
        chrome.app.window.current().restore()
      else
        chrome.app.window.current().maximize()

    closeWindow: ->
      chrome.app.window.current().close()
