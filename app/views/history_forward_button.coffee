Twingl.HistoryForwardButton = Ember.Component.extend
  tagName   : 'button'
  classNames: [ 't-history-forward', 't-nav-button' ]
  action    : "navigateHistoryForward"
  layoutName: "button"
  text      : "Forward"

  click: ->
    @sendAction()
