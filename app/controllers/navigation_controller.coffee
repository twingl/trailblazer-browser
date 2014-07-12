Twingl.NavigationController = Ember.Controller.extend
  # This Controller is responsible for setting and clearing the necessary state
  # so we can mutate the tree correctly based on the events emitted by the
  # <webview>

  needs: ['webview', 'tree']
  webview: Ember.computed.alias "controllers.webview"
  tree: Ember.computed.alias "controllers.tree"

  resetState: ->
    @set 'url',     ''
    @set 'loading', false
    @set 'state',   undefined

  url: ''
  loading: false

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
    hist_back   : 2
    hist_forward: 3
    nav_tree    : 4
    nav_browser : 5

  updateTree: (node) ->
    switch @state
      when @states.nav_url
        @get('tree').send 'newRoot', { url: node.url, title: node.title }
        @state = @states.default

      # This URL equality check is to account for some odd behaviour when
      # history.back() is invoked (repeatable example: google search "twitter"
      # and click the link to twitter.com - when you history.back() it will 'go
      # back' to twitter.com then `advance` to the google search, which was the
      # real history item.
      when @states.hist_back
        unless node.url == @get 'url'
          @get('tree').send 'historyPush'
          @state = @states.default

      when @states.hist_forward
        @get('tree').send 'historyPop'
        @state = @states.default

      when @states.nav_tree
        @state = @states.default

      when @states.nav_browser
        @state = @states.default

      else #default
        @get('tree').send 'advance', { url: node.url, title: node.title }
        @state = @states.default

  actions:
    ###
    # User instigated events - UI elements
    # These set @state which is handled above
    ###

    # Navigates to a specified URL
    navigateUrl: ->
      @set 'state', @states.nav_url
      @get('webview').navigate(@get('url'))

    # Navigates one node back in the history tree [will not be in release]
    navigateHistoryBack: ->
      @set 'state', @states.hist_back
      @get('webview').navigateBack()

    # Navigates one node forward in the history tree [will not be in release]
    navigateHistoryForward: ->
      @set 'state', @states.hist_forward
      @get('webview').navigateForward()

    # Reloads the current page
    navigateReload: ->
      @get('webview').reload()

    # Emitted when a user navigates to a site in their trail
    navigateNode: (url) ->
      @set 'state', @states.nav_tree
      @get('webview').navigate(url)

    # Hides the browser and shows the trail view
    historyShow: ->
      @set 'loading', false
      $('#tb-pane-alt').show()
      $('.tb-navigation-element-main').hide()
      $('.tb-navigation-element-alt').show 0, =>
        @get('tree').send('drawTree')


    # Hides the trail view and shows the browser
    browserShow: ->
      $('#tb-pane-alt').hide()
      $('.tb-navigation-element-main').show()
      $('.tb-navigation-element-alt').hide()

    ###
    # Filtered <webview> instigated events
    ###

    # Updates the trail with a new node based on the commit event emitted by
    # the web view
    loadCommit: (e) ->
      @updateTree e.originalEvent
      console.log @get('tree').get('currentNode'), @get 'state'
      @set 'url', e.originalEvent.url

    # Updates the URL that is displayed without tracking this redirect in the
    # trail
    loadRedirect: (e) ->
      @set 'url', e.originalEvent.url

    # Emitted when a new window/tab is opened - i.e. when a person middle
    # clicks on a link
    newWindow: (e) ->
      @get('tree').send 'newChild', { url: e.originalEvent.targetUrl, title: e.originalEvent.targetUrl }
