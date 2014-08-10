Twingl.NavigationController = Ember.Controller.extend

  needs: ['webview', 'tree', 'application']
  webview:  Ember.computed.alias "controllers.webview"
  tree:     Ember.computed.alias "controllers.tree"

  loading: Ember.computed.alias "controllers.application.loading"

  resetState: ->
    @set 'loading', false
    @set 'url', ''
    $('#tb-pane-alt').hide()
    $('#tb-pane-main').removeClass('blur')
    $('.tb-navigation-element-main').show()
    $('.tb-navigation-element-alt').hide()

  # This is bound to a read-only view, but may be used for URL input if
  # @navigateUrl is called after setting
  url: ''

  actions:
    ###
    # User instigated events - UI elements
    ###

    # Navigates to a specified URL
    navigateUrl: ->
      @get('webview').navigate(@get('url'))

    navigateSearch: ->
      @get('webview').navigate(window.ENV['search_page'])

    # Reloads the current page
    navigateReload: ->
      @get('webview').reload()

    navigateHistoryBack: ->
      if parent = @get('tree').parentNode()
        @get('tree').updateCurrentNode(parent)
        @get('webview').navigate parent.url, false

    # Hides the browser and shows the trail view
    historyShow: ->
      @set 'loading', false
      $('#tb-pane-alt').show()
      $('#tb-pane-main').addClass('blur')
      $('.tb-navigation-element-main').hide()
      $('.tb-navigation-element-alt').show 0, =>
        @get('tree').send('drawTree')

    # Hides the trail view and shows the browser
    browserShow: ->
      $('#tb-pane-alt').hide()
      $('#tb-pane-main').removeClass('blur')
      $('.tb-navigation-element-main').show()
      $('.tb-navigation-element-alt').hide()

