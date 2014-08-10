Twingl.BrowserBackButton = Ember.Component.extend
  tagName   : "i"
  classNames: [ "tb-history-back", "tb-nav-button", "fa", "fa-arrow-circle-left" ]
  action    : "navigateHistoryBack"

  click: ->
    @sendAction()
