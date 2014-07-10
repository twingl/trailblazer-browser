Twingl.WebviewController = Ember.Controller.extend
  ###
  # This Controller is responsible for actioning navigation events and catching
  # the events emitted by the <webview>, filtering, and bubbling on appropriate
  # events to NavigationController so that it can manage the state effectively.
  ###

  needs: ['navigation', 'tree']
  navigation: Ember.computed.alias "controllers.navigation"

  resetState: ->
    @set 'url', ''

  currentNode: Ember.computed.alias "controllers.tree.currentNode"

  url: ''

  navigate:  (url) -> @set 'url', url

  navigateForward: -> $('webview')[0].forward()
  navigateBack:    -> $('webview')[0].back()
  reload:          -> $('webview')[0].reload()

  # These are events emitted by the webview element. Some are filtered before
  # being forwarded to other components.
  actions:
    loadStart: (e) ->
      console.log "loadstart"
      @get('navigation').set 'loading', true

    loadStop:  (e) ->
      console.log "loadstop"
      @get('navigation').set 'loading', false

    # We only want to forward top level redirects
    loadRedirect: (e) ->
      if e.originalEvent.isTopLevel
        @get('navigation').send 'loadRedirect', e

    # We only want to forward top level commits, not commits that are emitted
    # by other resources loaded as part of the top level page.
    # Injects a small script to get the page title and inserts this into the
    # event object.
    loadCommit: (e) ->
      if e.originalEvent.isTopLevel and @get('currentNode').url != e.originalEvent.url
        $('webview')[0].executeScript code: "document.title", (r) =>
          document.title = r[0]
          e.originalEvent.title = r[0]
          @get('navigation').send 'loadCommit', e

    newWindow: (e) ->
      @get('navigation').send 'newWindow', e
