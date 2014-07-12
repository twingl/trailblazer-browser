Twingl.HistoryForwardButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 'tb-history-forward', 'tb-nav-button' ]
  action    : "navigateHistoryForward"
  layoutName: "button"
  text      : "Forward"

  click: ->
    @sendAction()
