Twingl.WebviewController = Ember.Controller.extend
  ###
  # This Controller is responsible for actioning navigation events and catching
  # the events emitted by the <webview>, filtering, and bubbling on appropriate
  # events to NavigationController so that it can manage the state effectively.
  ###

  needs: ['navigation', 'tree']
  navigation: Ember.computed.alias "controllers.navigation"
  tree:       Ember.computed.alias "controllers.tree"

  resetState: ->
    @set 'url', ''
    @set 'state',   undefined

  # A state register is used to handle situations where there are many events
  # emitted by the webview that represent a single logical web transaction.
  # e.g. running a Google search and it redirects 3 times before showing the
  # results.
  #
  # State is set when a user interaction occurs (clicking a link, navigating
  # through history/tree) and is cleared when a loadCommit event occurs.
  # The intent is to capture all of the activity that happens between user
  # interaction and the page being ready, and use this to render a new history
  # item use this to render a new history item in the trail.
  state: undefined

  states:
    default     : 0
    nav_url     : 1
    nav_tree    : 2
    nav_browser : 3


  updateTree: (node) ->
    switch @state
      when @states.nav_url
        console.log("nav_url")
        @get('tree').send 'newRoot', { url: node.url, title: node.title }
        @state = @states.default

      when @states.nav_tree
        console.log("nav_tree")
        @state = @states.default

      when @states.nav_browser
        console.log("nav_browser")
        @state = @states.default

      else #default
        console.log("nav_default")
        @get('tree').send 'advance', { url: node.url, title: node.title }
        @state = @states.default

  currentNode: Ember.computed.alias "controllers.tree.currentNode"

  url: ''

  navigate:  (url) -> @set 'url', url

  navigateForward: -> $('webview')[0].forward()
  navigateBack:    -> $('webview')[0].back()
  reload:          -> $('webview')[0].reload()

  # These are events emitted by the webview element as the user browses the
  # web.
  actions:
    # Notify NavigationController that we're loading something.
    loadStart: (e) ->
      @get('navigation').set 'loading', true

    # Notify NavigationController that we've finished loading.
    loadStop:  (e) ->
      @get('navigation').set 'loading', false

    # Updates the trail with a new node based on the commit event emitted by
    # the web view.
    # Notify NavigationController of a new URL to display.
    # Only effected on top-level events.
    loadCommit: (e) ->
      if e.originalEvent.isTopLevel and @get('currentNode').url != e.originalEvent.url
        $('webview')[0].executeScript code: "document.title", (r) =>
          document.title = r[0]
          e.originalEvent.title = r[0]
          @updateTree e.originalEvent
          console.log "loadCommit", @get('tree').get('currentNode'), @get 'state'
          @get('navigation').set 'url', e.originalEvent.url

    # Updates the URL that is displayed without tracking this redirect in the
    # trail.
    # Notify NavigationController of a new URL to display.
    # Only effected on top-level events.
    loadRedirect: (e) ->
      if e.originalEvent.isTopLevel
        @get('navigation').set 'url', e.originalEvent.url

    # Emitted when a new window/tab is opened - i.e. when a person middle
    # clicks on a link
    newWindow: (e) ->
      @get('tree').send 'newChild', { url: e.originalEvent.targetUrl, title: e.originalEvent.targetUrl }
