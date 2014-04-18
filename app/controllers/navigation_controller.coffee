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


  updateTree: (url) ->
    switch @state
      when @states.nav_url
        @get('tree').send 'newRoot', url
        @state = @states.default

      # This URL equality check is to account for some odd behaviour when
      # history.back() is invoked (repeatable example: google search "twitter"
      # and click the link to twitter.com - when you history.back() it will "go
      # back" to twitter.com then "advance" to the google search, which was the
      # real history item.
      when @states.hist_back
        unless url == @get 'url'
          @get('tree').send 'historyPop'
          @state = @states.default

      when @states.hist_forward
        @get('tree').send 'historyPush'
        @state = @states.default

      when @states.nav_tree
        @state = @states.default

      else #default
        @get('tree').send 'advance', url
        @state = @states.default

  actions:
    ###
    # User instigated events
    ###
    navigateUrl: ->
      @set 'state', @states.nav_url
      @get('webview').navigate(@url)

    navigateHistoryBack: ->
      @set 'state', @states.hist_back
      @get('webview').navigateBack()

    navigateHistoryForward: ->
      @set 'state', @states.hist_forward
      @get('webview').navigateForward()

    navigateReload: ->
      @get('webview').reload()

    jumpToUrl: (url) ->
      console.log "[STUB] jumpToUrl: #{url}"


    ###
    # Filtered <webview> instigated events
    ###
    loadCommit: (e) ->
      @updateTree e.originalEvent.url
      @set 'url', e.originalEvent.url

    loadRedirect: (e) ->
      @set 'url', e.originalEvent.url

    newWindow: (e) ->
      @get('tree').send 'newChild', e.originalEvent.targetUrl
