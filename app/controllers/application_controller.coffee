Twingl.ApplicationController = Ember.Controller.extend
  needs: ['tree', 'webview', 'navigation']
  actions:
    resetState: ->
      for c in @needs
        @get("controllers.#{c}").resetState()
      @transitionToRoute 'login'
