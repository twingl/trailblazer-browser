Twingl.NavigationController = Ember.Controller.extend

  needs: ['webview', 'tree']
  webview:  Ember.computed.alias "controllers.webview"
  tree:     Ember.computed.alias "controllers.tree"

  resetState: ->
    @set 'loading', false
    @set 'url', ''
    $('#tb-pane-alt').hide()
    $('.tb-navigation-element-main').show()
    $('.tb-navigation-element-alt').hide()

  # This is bound to a read-only view, but may be used for URL input if
  # @navigateUrl is called after setting
  url: ''

  loading: false

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
