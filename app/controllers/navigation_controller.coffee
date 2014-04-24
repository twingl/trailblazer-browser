Twingl.NavigationController = Ember.Controller.extend
  ###
  # This Controller is responsible for setting and clearing the necessary state
  # so we can mutate the tree correctly based on the events emitted by the
  # <webview>
  ###

  needs: ['webview', 'tree']
  webview: Ember.computed.alias "controllers.webview"
  tree: Ember.computed.alias "controllers.tree"

  url: ''
  loading: false

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
      # and click the link to twitter.com - when you history.back() it will "go
      # back" to twitter.com then "advance" to the google search, which was the
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
    # User instigated events
    ###
    navigateUrl: ->
      @set 'state', @states.nav_url
      @get('webview').navigate(@get('url'))

    navigateHistoryBack: ->
      @set 'state', @states.hist_back
      @get('webview').navigateBack()

    navigateHistoryForward: ->
      @set 'state', @states.hist_forward
      @get('webview').navigateForward()

    navigateReload: ->
      @get('webview').reload()

    navigateNode: (url) ->
      @set 'state', @states.nav_tree
      @get('webview').navigate(url)

    historyShow: ->
      @set 'loading', false
      @set 'state', @states.nav_tree
      $('#t-pane-alt').show()
      $('.t-navigation-element-main').hide()
      $('.t-navigation-element-alt').show 0, =>
        @get('tree').send('drawTree')


    browserShow: ->
      @set 'state', @states.nav_browser
      $('#t-pane-alt').hide()
      $('.t-navigation-element-main').show()
      $('.t-navigation-element-alt').hide()

    ###
    # Filtered <webview> instigated events
    ###
    loadCommit: (e) ->
      @updateTree e.originalEvent
      @set 'url', e.originalEvent.url

    loadRedirect: (e) ->
      @set 'url', e.originalEvent.url

    newWindow: (e) ->
      @get('tree').send 'newChild', e.originalEvent.targetUrl
